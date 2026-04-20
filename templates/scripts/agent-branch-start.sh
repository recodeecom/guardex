#!/usr/bin/env bash
set -euo pipefail

TASK_NAME="task"
AGENT_NAME="agent"
BASE_BRANCH=""
BASE_BRANCH_EXPLICIT=0
WORKTREE_ROOT_REL=".omx/agent-worktrees"
OPENSPEC_AUTO_INIT_RAW="${GUARDEX_OPENSPEC_AUTO_INIT:-false}"
OPENSPEC_PLAN_SLUG_OVERRIDE="${GUARDEX_OPENSPEC_PLAN_SLUG:-}"
OPENSPEC_CHANGE_SLUG_OVERRIDE="${GUARDEX_OPENSPEC_CHANGE_SLUG:-}"
OPENSPEC_CAPABILITY_SLUG_OVERRIDE="${GUARDEX_OPENSPEC_CAPABILITY_SLUG:-}"
PLAN_MODE_RAW="${GX_PLAN_MODE:-${GUARDEX_PLAN_MODE:-}}"
PLAN_MODE_EXPLICIT=0
PRINT_NAME_ONLY=0
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      TASK_NAME="${2:-task}"
      shift 2
      ;;
    --agent)
      AGENT_NAME="${2:-agent}"
      shift 2
      ;;
    --base)
      BASE_BRANCH="${2:-}"
      BASE_BRANCH_EXPLICIT=1
      shift 2
      ;;
    --print-name-only)
      PRINT_NAME_ONLY=1
      shift
      ;;
    --plan-mode)
      PLAN_MODE_RAW="true"
      PLAN_MODE_EXPLICIT=1
      shift
      ;;
    --no-plan-mode)
      PLAN_MODE_RAW="false"
      PLAN_MODE_EXPLICIT=1
      shift
      ;;
    --tier)
      # Accepted for CLAUDE.md compatibility; scaffold size is not yet wired
      # through this script. Consume the value so callers can pass it.
      shift 2
      ;;
    --in-place|--allow-in-place)
      echo "[agent-branch-start] In-place branch mode is disabled." >&2
      echo "[agent-branch-start] This command always creates an isolated worktree to keep your active checkout unchanged." >&2
      exit 1
      ;;
    --worktree-root)
      WORKTREE_ROOT_REL="${2:-.omx/agent-worktrees}"
      shift 2
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        POSITIONAL_ARGS+=("$1")
        shift
      done
      break
      ;;
    -*)
      echo "[agent-branch-start] Unknown option: $1" >&2
      echo "Usage: $0 [task] [agent] [base] [--worktree-root <path>] [--plan-mode|--no-plan-mode] [--print-name-only]" >&2
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ "${#POSITIONAL_ARGS[@]}" -gt 3 ]]; then
  echo "[agent-branch-start] Too many positional arguments." >&2
  echo "Usage: $0 [task] [agent] [base] [--worktree-root <path>] [--plan-mode|--no-plan-mode]" >&2
  exit 1
fi

if [[ "${#POSITIONAL_ARGS[@]}" -ge 1 ]]; then
  TASK_NAME="${POSITIONAL_ARGS[0]}"
fi

if [[ "${#POSITIONAL_ARGS[@]}" -ge 2 ]]; then
  AGENT_NAME="${POSITIONAL_ARGS[1]}"
fi

if [[ "${#POSITIONAL_ARGS[@]}" -ge 3 ]]; then
  BASE_BRANCH="${POSITIONAL_ARGS[2]}"
  BASE_BRANCH_EXPLICIT=1
fi

sanitize_slug() {
  local raw="$1"
  local fallback="${2:-task}"
  local slug
  slug="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g')"
  if [[ -z "$slug" ]]; then
    slug="$fallback"
  fi
  printf '%s' "$slug"
}

normalize_positive_int() {
  local raw="$1"
  local fallback="$2"
  if [[ "$raw" =~ ^[0-9]+$ ]] && [[ "$raw" -gt 0 ]]; then
    printf '%s' "$raw"
    return 0
  fi
  printf '%s' "$fallback"
}

shorten_slug() {
  local slug="$1"
  local raw_max="$2"
  local max_len
  max_len="$(normalize_positive_int "$raw_max" "32")"
  if [[ "${#slug}" -le "$max_len" ]]; then
    printf '%s' "$slug"
    return 0
  fi
  local shortened="${slug:0:max_len}"
  shortened="$(printf '%s' "$shortened" | sed -E 's/-+$//')"
  if [[ -z "$shortened" ]]; then
    shortened="${slug:0:max_len}"
  fi
  printf '%s' "$shortened"
}

# Collapse arbitrary agent identifiers to a clean role token: claude | codex |
# <other-kebab>. Priority: GUARDEX_AGENT_TYPE env override, then the raw
# AGENT_NAME (if it contains 'claude' or 'codex'), then CLAUDECODE=1 sentinel
# (set by Claude Code CLI), else fall back to 'codex'. Any other role name
# (integrator, executor, rust-port, etc.) is preserved as-is after slug
# sanitization.
normalize_role() {
  local raw_agent="$1"
  local override="${GUARDEX_AGENT_TYPE:-}"
  if [[ -n "$override" ]]; then
    sanitize_slug "$override" "agent"
    return 0
  fi
  local lowered
  lowered="$(printf '%s' "$raw_agent" | tr '[:upper:]' '[:lower:]')"
  if [[ "$lowered" == *claude* ]]; then
    printf 'claude'
    return 0
  fi
  if [[ "$lowered" == *codex* ]]; then
    printf 'codex'
    return 0
  fi
  if [[ -n "${CLAUDECODE:-}" && "${CLAUDECODE}" != "0" && "${CLAUDECODE}" != "false" ]]; then
    printf 'claude'
    return 0
  fi
  # Unrecognized raw name (rust-port-lead, some-worker, empty, ...): default to
  # codex. To get a different role (integrator, executor, ...) pass the role
  # explicitly via GUARDEX_AGENT_TYPE, handled above.
  printf 'codex'
}

# Timestamp the branch/worktree/openspec slug so parallel agents never collide
# and names sort chronologically. Format: YYYY-MM-DD-HH-MM (local time).
# Colons are illegal in git refs, so the HH:MM the user sees is stored as
# HH-MM in the slug. Can be overridden for tests via GUARDEX_BRANCH_TIMESTAMP.
compose_branch_timestamp() {
  if [[ -n "${GUARDEX_BRANCH_TIMESTAMP:-}" ]]; then
    printf '%s' "$GUARDEX_BRANCH_TIMESTAMP"
    return 0
  fi
  date +%Y-%m-%d-%H-%M
}

compose_branch_descriptor() {
  local task_slug="$1"
  local stamp="$2"
  local task_max task_part
  task_max="$(normalize_positive_int "${GUARDEX_BRANCH_TASK_SLUG_MAX:-40}" "40")"
  task_part="$(shorten_slug "$task_slug" "$task_max")"
  printf '%s-%s' "$task_part" "$stamp"
}

normalize_bool() {
  local raw="${1:-}"
  local fallback="${2:-0}"
  local lowered
  lowered="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  case "$lowered" in
    1|true|yes|on) printf '1' ;;
    0|false|no|off) printf '0' ;;
    '') printf '%s' "$fallback" ;;
    *) printf '%s' "$fallback" ;;
  esac
}

is_plan_permission_mode() {
  local raw lowered
  for raw in \
    "${GUARDEX_PERMISSION_MODE:-}" \
    "${OMX_PERMISSION_MODE:-}" \
    "${CODEX_PERMISSION_MODE:-}" \
    "${CLAUDE_PERMISSION_MODE:-}" \
    "${CLAUDE_CODE_PERMISSION_MODE:-}"; do
    lowered="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
    if [[ "$lowered" == "plan" ]]; then
      return 0
    fi
  done
  return 1
}

has_ralplan_keyword_signal() {
  local combined lowered
  combined="${GUARDEX_WORKFLOW_KEYWORD:-} ${OMX_WORKFLOW_KEYWORD:-} ${OMX_ACTIVE_SKILL:-} ${GUARDEX_ACTIVE_SKILL:-}"
  lowered="$(printf '%s' "$combined" | tr '[:upper:]' '[:lower:]')"
  [[ "$lowered" == *ralplan* ]]
}

recent_active_ralplan_state_exists() {
  local root="$1"
  local sessions_dir="${root}/.omx/state/sessions"
  local now path mtime
  if [[ ! -d "$sessions_dir" ]]; then
    return 1
  fi

  now="$(date +%s)"
  while IFS= read -r -d '' path; do
    if ! grep -Eq '"active"[[:space:]]*:[[:space:]]*true' "$path"; then
      continue
    fi

    mtime="$(stat -c %Y "$path" 2>/dev/null || stat -f %m "$path" 2>/dev/null || echo 0)"
    if [[ "$mtime" =~ ^[0-9]+$ ]] && (( now - mtime <= 21600 )); then
      return 0
    fi
  done < <(find "$sessions_dir" -maxdepth 2 -type f -name 'ralplan-state.json' -print0 2>/dev/null)

  return 1
}

resolve_plan_mode_enabled() {
  local root="$1"
  if [[ "$PLAN_MODE_EXPLICIT" -eq 1 ]]; then
    normalize_bool "$PLAN_MODE_RAW" "0"
    return 0
  fi

  if [[ -n "$PLAN_MODE_RAW" ]]; then
    normalize_bool "$PLAN_MODE_RAW" "0"
    return 0
  fi

  if is_plan_permission_mode || has_ralplan_keyword_signal || recent_active_ralplan_state_exists "$root"; then
    printf '1'
    return 0
  fi

  printf '0'
}

OPENSPEC_AUTO_INIT="$(normalize_bool "$OPENSPEC_AUTO_INIT_RAW" "1")"

resolve_openspec_plan_slug() {
  local branch_name="$1"
  local task_slug="$2"
  if [[ -n "$OPENSPEC_PLAN_SLUG_OVERRIDE" ]]; then
    sanitize_slug "$OPENSPEC_PLAN_SLUG_OVERRIDE" "$task_slug"
    return 0
  fi
  sanitize_slug "${branch_name//\//-}" "$task_slug"
}

resolve_openspec_change_slug() {
  local branch_name="$1"
  local task_slug="$2"
  if [[ -n "$OPENSPEC_CHANGE_SLUG_OVERRIDE" ]]; then
    sanitize_slug "$OPENSPEC_CHANGE_SLUG_OVERRIDE" "$task_slug"
    return 0
  fi
  sanitize_slug "${branch_name//\//-}" "$task_slug"
}

resolve_openspec_capability_slug() {
  local task_slug="$1"
  if [[ -n "$OPENSPEC_CAPABILITY_SLUG_OVERRIDE" ]]; then
    sanitize_slug "$OPENSPEC_CAPABILITY_SLUG_OVERRIDE" "$task_slug"
    return 0
  fi
  sanitize_slug "$task_slug" "general-behavior"
}

has_local_changes() {
  local root="$1"
  if ! git -C "$root" diff --quiet; then
    return 0
  fi
  if ! git -C "$root" diff --cached --quiet; then
    return 0
  fi
  if [[ -n "$(git -C "$root" ls-files --others --exclude-standard)" ]]; then
    return 0
  fi
  return 1
}

resolve_protected_branches() {
  local root="$1"
  local raw
  raw="${GUARDEX_PROTECTED_BRANCHES:-$(git -C "$root" config --get multiagent.protectedBranches || true)}"
  if [[ -z "$raw" ]]; then
    raw="dev main master"
  fi
  raw="${raw//,/ }"
  printf '%s' "$raw"
}

is_protected_branch_name() {
  local branch="$1"
  local protected_raw="$2"
  for protected_branch in $protected_raw; do
    if [[ "$branch" == "$protected_branch" ]]; then
      return 0
    fi
  done
  return 1
}

hydrate_local_helper_in_worktree() {
  local repo="$1"
  local worktree="$2"
  local relative_path="$3"
  local worktree_target="${worktree}/${relative_path}"
  local source_path=""

  if [[ -e "$worktree_target" ]]; then
    return 0
  fi

  if [[ -f "${repo}/${relative_path}" ]]; then
    source_path="${repo}/${relative_path}"
  elif [[ -f "${repo}/templates/${relative_path}" ]]; then
    source_path="${repo}/templates/${relative_path}"
  fi

  if [[ -z "$source_path" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$worktree_target")"
  cp "$source_path" "$worktree_target"
  if [[ -x "$source_path" ]]; then
    chmod +x "$worktree_target"
  fi

  echo "[agent-branch-start] Hydrated local helper in worktree: ${relative_path}"
}

hydrate_dependency_dir_symlink_in_worktree() {
  local repo="$1"
  local worktree="$2"
  local relative_path="$3"
  local source_path="${repo}/${relative_path}"
  local target_path="${worktree}/${relative_path}"

  if [[ ! -d "$source_path" ]]; then
    return 0
  fi

  if [[ -e "$target_path" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$target_path")"
  ln -s "$source_path" "$target_path"
  echo "[agent-branch-start] Linked dependency dir in worktree: ${relative_path}"
}

initialize_openspec_plan_workspace() {
  local repo="$1"
  local worktree="$2"
  local plan_slug="$3"

  hydrate_local_helper_in_worktree "$repo" "$worktree" "scripts/openspec/init-plan-workspace.sh"

  if [[ "$OPENSPEC_AUTO_INIT" -ne 1 ]]; then
    return 0
  fi

  local openspec_script="${worktree}/scripts/openspec/init-plan-workspace.sh"
  if [[ ! -f "$openspec_script" ]]; then
    echo "[agent-branch-start] OpenSpec init script is missing in sandbox worktree." >&2
    echo "[agent-branch-start] Run 'gx setup --target \"$repo\"' to repair templates, then retry." >&2
    return 1
  fi
  if [[ ! -x "$openspec_script" ]]; then
    chmod +x "$openspec_script" 2>/dev/null || true
  fi

  local init_output=""
  if ! init_output="$(
    cd "$worktree"
    bash "scripts/openspec/init-plan-workspace.sh" "$plan_slug" 2>&1
  )"; then
    printf '%s\n' "$init_output" >&2
    echo "[agent-branch-start] OpenSpec workspace initialization failed for plan '${plan_slug}'." >&2
    return 1
  fi

  if [[ -n "$init_output" ]]; then
    printf '%s\n' "$init_output"
  fi
  echo "[agent-branch-start] OpenSpec plan workspace: ${worktree}/openspec/plan/${plan_slug}"
}

initialize_openspec_change_workspace() {
  local repo="$1"
  local worktree="$2"
  local change_slug="$3"
  local capability_slug="$4"

  hydrate_local_helper_in_worktree "$repo" "$worktree" "scripts/openspec/init-change-workspace.sh"

  if [[ "$OPENSPEC_AUTO_INIT" -ne 1 ]]; then
    return 0
  fi

  local openspec_script="${worktree}/scripts/openspec/init-change-workspace.sh"
  if [[ ! -f "$openspec_script" ]]; then
    echo "[agent-branch-start] OpenSpec change init script is missing in sandbox worktree." >&2
    echo "[agent-branch-start] Run 'gx setup --target \"$repo\"' to repair templates, then retry." >&2
    return 1
  fi
  if [[ ! -x "$openspec_script" ]]; then
    chmod +x "$openspec_script" 2>/dev/null || true
  fi

  local init_output=""
  if ! init_output="$(
    cd "$worktree"
    bash "scripts/openspec/init-change-workspace.sh" "$change_slug" "$capability_slug" 2>&1
  )"; then
    printf '%s\n' "$init_output" >&2
    echo "[agent-branch-start] OpenSpec workspace initialization failed for change '${change_slug}'." >&2
    return 1
  fi

  if [[ -n "$init_output" ]]; then
    printf '%s\n' "$init_output"
  fi
  echo "[agent-branch-start] OpenSpec change workspace: ${worktree}/openspec/changes/${change_slug}"
}

PLAN_MODE_FILE_REL_PATH=""

initialize_plan_mode_markdown() {
  local worktree="$1"
  local task_name="$2"
  local task_slug="$3"
  local branch_name="$4"
  local base_branch="$5"

  if [[ "$PLAN_MODE" -ne 1 ]]; then
    return 0
  fi

  local plans_dir="${worktree}/.omx/plans"
  local date_prefix file_name candidate_path suffix

  mkdir -p "$plans_dir"

  date_prefix="$(date +%Y-%m-%d)"
  file_name="${date_prefix}-${task_slug}.md"
  candidate_path="${plans_dir}/${file_name}"
  suffix=2
  while [[ -e "$candidate_path" ]]; do
    file_name="${date_prefix}-${task_slug}-${suffix}.md"
    candidate_path="${plans_dir}/${file_name}"
    suffix=$((suffix + 1))
  done

  cat >"$candidate_path" <<EOF
# PRD: ${task_name}

> 4 phases · estimate pending · persists across sessions
> Branch: \`${branch_name}\`
> Base: \`${base_branch}\`

## 1. Problem

Describe the concrete problem and current failure/symptom.

## 2. Goal

Deliver a safe, reversible implementation plan that can be executed phase-by-phase.

## 3. Scope

1. Define the behavior and boundaries for this change.
2. List the code paths/modules expected to change.
3. Record verification expectations before implementation begins.

## 4. Non-Goals

1. Avoid unrelated refactors while in plan mode.
2. Do not cut over destructive changes until shadow validation passes.

## 5. Phased Backlog

### Phase 1 — Discovery + Read-only Mapping (45m · 3 files)

- Map current implementation and dependent callers.
- Capture constraints and rollout guardrails.

### Phase 2 — Plan Skeleton + Flags (30m · 2 files)

- Define switch/feature-flag strategy and fallback path.
- Document acceptance checks per caller surface.

### Phase 3 — Shadow Validation (24h observe · 1 file)

- Run old/new paths in parallel and log output diffs.
- Load-test critical path (for example: 100 concurrent reads).

### Phase 4 — Cutover + Cleanup (1h · 4 files) [deferred]

- Flip default path after shadow window is clean.
- Remove deprecated fallback implementation in a follow-up PR.

## 6. Acceptance Criteria

1. Plan includes explicit phase boundaries and success signals.
2. Verification steps are concrete and runnable.
3. Rollback path is documented before cutover.

## 7. Risks and Mitigations

1. Risk: drift between plan and execution.
Mitigation: revise this file before each phase starts.
2. Risk: hidden dependency callers.
Mitigation: add caller inventory during phase 1.

## 8. Rollout Strategy

1. Keep execution behind explicit approvals for each phase.
2. Keep phase 4 deferred until validation evidence is green.
3. Capture final evidence and lessons learned in the completion handoff.
EOF

  PLAN_MODE_FILE_REL_PATH=".omx/plans/${file_name}"
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[agent-branch-start] Not inside a git repository." >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"

if [[ "$BASE_BRANCH_EXPLICIT" -eq 1 && -z "$BASE_BRANCH" ]]; then
  echo "[agent-branch-start] --base requires a non-empty branch name." >&2
  exit 1
fi

PLAN_MODE="$(resolve_plan_mode_enabled "$repo_root")"
task_slug="$(sanitize_slug "$TASK_NAME" "task")"
agent_slug="$(normalize_role "$AGENT_NAME")"
if [[ "$PLAN_MODE" -eq 1 ]]; then
  agent_slug="plan"
fi
branch_timestamp="$(compose_branch_timestamp)"
branch_descriptor="$(compose_branch_descriptor "$task_slug" "$branch_timestamp")"
branch_name_base="agent/${agent_slug}/${branch_descriptor}"

branch_name="$branch_name_base"
if [[ "$PRINT_NAME_ONLY" -eq 1 ]]; then
  printf '%s\n' "$branch_name"
  exit 0
fi

if [[ "$BASE_BRANCH_EXPLICIT" -eq 0 ]]; then
  current_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  protected_branches_raw="$(resolve_protected_branches "$repo_root")"
  if [[ -n "$current_branch" && "$current_branch" != "HEAD" ]] && is_protected_branch_name "$current_branch" "$protected_branches_raw"; then
    BASE_BRANCH="$current_branch"
  else
    configured_base="$(git -C "$repo_root" config --get multiagent.baseBranch || true)"
    if [[ -n "$configured_base" ]]; then
      BASE_BRANCH="$configured_base"
    elif [[ -n "$current_branch" && "$current_branch" != "HEAD" ]]; then
      BASE_BRANCH="$current_branch"
    else
      BASE_BRANCH="dev"
    fi
  fi
fi

if git show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}"; then
  git fetch origin "${BASE_BRANCH}" --quiet
  start_ref="origin/${BASE_BRANCH}"
else
  if ! git show-ref --verify --quiet "refs/heads/${BASE_BRANCH}"; then
    echo "[agent-branch-start] Base branch not found locally or on origin: ${BASE_BRANCH}" >&2
    exit 1
  fi
  start_ref="${BASE_BRANCH}"
fi

timestamp="$(date +%Y%m%d-%H%M%S)"
branch_suffix=2
while git show-ref --verify --quiet "refs/heads/${branch_name}"; do
  branch_name="${branch_name_base}-${branch_suffix}"
  branch_suffix=$((branch_suffix + 1))
done

worktree_root="${repo_root}/${WORKTREE_ROOT_REL}"
mkdir -p "$worktree_root"
worktree_path="${worktree_root}/${branch_name//\//__}"
openspec_plan_slug="$(resolve_openspec_plan_slug "$branch_name" "$task_slug")"
openspec_change_slug="$(resolve_openspec_change_slug "$branch_name" "$task_slug")"
openspec_capability_slug="$(resolve_openspec_capability_slug "$task_slug")"

if [[ -e "$worktree_path" ]]; then
  echo "[agent-branch-start] Worktree path already exists: ${worktree_path}" >&2
  exit 1
fi

auto_transfer_stash_ref=""
auto_transfer_message=""
auto_transfer_source_branch=""
current_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
protected_branches_raw="$(resolve_protected_branches "$repo_root")"
if [[ -n "$current_branch" && "$current_branch" != "HEAD" ]] && is_protected_branch_name "$current_branch" "$protected_branches_raw"; then
  if has_local_changes "$repo_root"; then
    auto_transfer_message="guardex-auto-transfer-${timestamp}-${agent_slug}-${task_slug}"
    if git -C "$repo_root" stash push --include-untracked --message "$auto_transfer_message" >/dev/null 2>&1; then
      auto_transfer_stash_ref="$(
        git -C "$repo_root" stash list \
          | awk -v msg="$auto_transfer_message" '$0 ~ msg { ref=$1; sub(/:$/, "", ref); print ref; exit }'
      )"
      if [[ -n "$auto_transfer_stash_ref" ]]; then
        auto_transfer_source_branch="$current_branch"
        echo "[agent-branch-start] Detected local changes on protected branch '${current_branch}'. Moving them to '${branch_name}'..."
      fi
    fi
  fi
fi

git -C "$repo_root" worktree add -b "$branch_name" "$worktree_path" "$start_ref"
git -C "$repo_root" config "branch.${branch_name}.guardexBase" "$BASE_BRANCH" >/dev/null 2>&1 || true

if git -C "$repo_root" show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}"; then
  git -C "$worktree_path" branch --set-upstream-to="origin/${BASE_BRANCH}" "$branch_name" >/dev/null 2>&1 || true
fi

if [[ -n "$auto_transfer_stash_ref" ]]; then
  if git -C "$worktree_path" stash apply "$auto_transfer_stash_ref" >/dev/null 2>&1; then
    git -C "$repo_root" stash drop "$auto_transfer_stash_ref" >/dev/null 2>&1 || true
    transfer_label="${auto_transfer_source_branch:-$BASE_BRANCH}"
    echo "[agent-branch-start] Moved local changes from '${transfer_label}' into '${branch_name}'."
  else
    echo "[agent-branch-start] Failed to auto-apply moved changes in new worktree." >&2
    transfer_label="${auto_transfer_source_branch:-$BASE_BRANCH}"
    echo "[agent-branch-start] Changes are preserved in ${auto_transfer_stash_ref} on ${transfer_label}." >&2
    echo "[agent-branch-start] Apply manually with: git -C \"$worktree_path\" stash apply \"${auto_transfer_stash_ref}\"" >&2
    exit 1
  fi
fi

hydrate_local_helper_in_worktree "$repo_root" "$worktree_path" "scripts/codex-agent.sh"
hydrate_dependency_dir_symlink_in_worktree "$repo_root" "$worktree_path" "node_modules"
hydrate_dependency_dir_symlink_in_worktree "$repo_root" "$worktree_path" "apps/frontend/node_modules"
hydrate_dependency_dir_symlink_in_worktree "$repo_root" "$worktree_path" "apps/backend/node_modules"
if ! initialize_openspec_change_workspace "$repo_root" "$worktree_path" "$openspec_change_slug" "$openspec_capability_slug"; then
  exit 1
fi
if ! initialize_openspec_plan_workspace "$repo_root" "$worktree_path" "$openspec_plan_slug"; then
  exit 1
fi
initialize_plan_mode_markdown "$worktree_path" "$TASK_NAME" "$task_slug" "$branch_name" "$BASE_BRANCH"

echo "[agent-branch-start] Created branch: ${branch_name}"
echo "[agent-branch-start] Worktree: ${worktree_path}"
echo "[agent-branch-start] OpenSpec change: openspec/changes/${openspec_change_slug}"
echo "[agent-branch-start] OpenSpec plan: openspec/plan/${openspec_plan_slug}"
if [[ "$PLAN_MODE" -eq 1 ]]; then
  echo "[agent-branch-start] Plan mode: ON (agent/plan/* branch)"
  if [[ -n "$PLAN_MODE_FILE_REL_PATH" ]]; then
    echo "[agent-branch-start] Plan file: ${PLAN_MODE_FILE_REL_PATH}"
  fi
fi
echo "[agent-branch-start] Next steps:"
echo "  cd \"${worktree_path}\""
echo "  python3 scripts/agent-file-locks.py claim --branch \"${branch_name}\" <file...>"
echo "  # implement + commit"
echo "  bash scripts/agent-branch-finish.sh --branch \"${branch_name}\" --base dev --via-pr --wait-for-merge"
