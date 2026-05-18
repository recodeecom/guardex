# AGENTS

This document is the agent contract for this repo. It applies identically to Codex, Claude Code, and any other agentic CLI working here. `CLAUDE.md` is a symlink to this file — do not edit them independently.

## Objective

- Optimize for task completion with low token use.
- Prefer phase-based execution over conversational micro-steps.

## Claude Code quickstart

If you are a Claude Code session arriving in this repo for the first time:

1. **Branch awareness** — `skill_guard.py` accepts `agent/*`, `claude/*`,
   `codex/*`, and `cursor/*` as agent-managed branch namespaces by default.
   Your harness-assigned `claude/<...>` branch is recognized; you don't need
   to set `GUARDEX_AGENT_BRANCH_PREFIXES`. If you ever do need to lock down
   namespaces, set `GUARDEX_AGENT_BRANCH_PREFIXES_ONLY=1` plus an explicit
   list.
2. **Slash commands** — `/gx-status`, `/gx-doctor`, `/gx-pivot`,
   `/gx-pr`, `/gx-finish`, `/gx-setup`, `/gx-act` are available out of the
   box. See `.claude/commands/`. `/gx-act` wraps
   [nektos/act](https://github.com/nektos/act) so CI workflows run locally
   before the remote PR run, letting you squash-merge on the first green
   round-trip.
3. **PR flow** — when you need explicit PR control, use `gx pr open`,
   `gx pr status`, `gx pr sync`, or `gx pr watch`. For end-of-task
   commit + push + PR + merge + cleanup, still use the non-negotiable
   `gx branch finish --via-pr --wait-for-merge --cleanup`.
4. **Repo wiring** — `gx claude install` writes `.claude/settings.json`,
   hooks, slash commands, and the gitguardex skill into a target repo.
   `gx claude check` diagnoses drift without writing; `gx claude doctor`
   diagnoses and repairs.

## ExecPlans

When writing complex features or significant refactors, use an ExecPlan (as described in `.agent/PLANS.md`) from design to implementation.

## Quick rules (non-negotiables)

- Never edit, stage, or commit on `dev` / `main`. Open an `agent/*` branch + worktree first.
- Claim files before edits: `gx locks claim --branch "<agent-branch>" <file...>` (or Colony `task_claim_file` on an active task).
- Finish completed work with `gx branch finish --branch "<agent-branch>" --via-pr --wait-for-merge --cleanup`. Never stop at bare `--via-pr`.
- Commit, push, and open/update a PR for completed work unless the user explicitly says to keep it local.
- Use OpenSpec for change-driven work; create/update `openspec/changes/<slug>/` before editing code (helper agent sub-branches excepted).
- Keep outputs compact: less word, same proof.
- Do not commit ephemeral runtime artifacts or local settings: `.dev-ports.json`, `apps/logs/*.log`, `.codex/settings.local.json`, `.claude/settings.local.json`, `.omc/project-memory.json`, `.omc/state/**`, `.omx/state/**`.
- Do not embed stale memory dumps, PR transcripts, session history, or long logs in this file.
- Frontend/UI/UX requests: load `.codex/skills/ui-ux-pro-max/SKILL.md` first.
- The `multiagent-safety` marker section below is machine-managed. Do not edit between markers.

## Workflow cheatsheet

```bash
# 1. Start a sandbox worktree (tier sizes OpenSpec scaffolding):
ALLOW_BASH_ON_NON_AGENT_BRANCH=1 \
  gx branch start [--tier T0|T1|T2|T3] "<task>" "claude-<name>"

# 2. Work inside the printed worktree path:
cd .omc/agent-worktrees/gitguardex__claude-<name>__<slug>
gx locks claim --branch "agent/claude-<name>/<slug>" <file...>
# implement + commit inside this worktree

# 3. Validate specs (before archive / finish on T2/T3):
openspec validate --specs

# 4. Finish via PR + cleanup (the non-negotiable default):
gx branch finish \
  --branch "agent/claude-<name>/<slug>" \
  --base main --via-pr --wait-for-merge --cleanup

# Branch protection blocks merge? Enable auto-merge once PR URL is known:
gh pr merge <PR-NUMBER> --repo <owner>/<repo> --auto --squash

# Sweep multiple finished lanes in one shot:
gx finish --all
```

Tier guide (sized by blast radius; default is `T3` if `--tier` is omitted):

| Tier | Use for | Scaffolding | Gates |
|------|---------|-------------|-------|
| `T0` | typos, dep bumps, format-only | none | tasks gate skipped |
| `T1` | ≤5 files, 1 capability, no API/schema | notes.md only | tasks gate skipped |
| `T2` | behavior change, API/schema, multi-module | full change workspace | full gates |
| `T3` | cross-cutting, multi-agent, plan-driven | change + plan workspace | full gates |

See [`.agent/CLAUDE-CODE-WORKFLOW.md`](.agent/CLAUDE-CODE-WORKFLOW.md) for full tier examples, finish flow, and `skill_guard` notes.

## Environment

- Python: `.venv/bin/python` (uv, CPython 3.13.3)
- GitHub auth for git/API is available via env vars: `GITHUB_USER`, `GITHUB_TOKEN` (PAT). Do not hardcode or commit tokens.
- For authenticated git over HTTPS in automation, use: `https://x-access-token:${GITHUB_TOKEN}@github.com/<owner>/<repo>.git`

## Code Conventions

The `/project-conventions` skill is auto-activated on code edits (PreToolUse guard).

| Convention              | Location                              | When                         |
| ----------------------- | ------------------------------------- | ---------------------------- |
| Code Conventions (Full) | `/project-conventions` skill          | On code edit (auto-enforced) |
| Git Workflow            | `.codex/conventions/git-workflow.md` | Commit / PR                  |

## Source of Truth (OpenSpec)

- **Specs/Design/Tasks (SSOT)**: `openspec/`
  - Active changes: `openspec/changes/<change>/`
  - Main specs: `openspec/specs/<capability>/spec.md`
  - Archived changes: `openspec/changes/archive/YYYY-MM-DD-<change>/`
- `spec.md` is normative (testable requirements only); free-form context lives in `openspec/specs/<capability>/context.md`.
- Do not add feature/behavior docs under `docs/`. Do not edit `CHANGELOG.md` directly.
- Validate: `openspec validate --specs`. Verify before archive: `/opsx:verify <change>`.
- Full OpenSpec workflow, philosophy, command list, and documentation model: [`.agent/OPENSPEC-WORKFLOW.md`](.agent/OPENSPEC-WORKFLOW.md).

## Versioning Rule

If a change publishes or bumps a package version, the same change must also update the release notes / changelog entries (record change notes in OpenSpec artifacts, not `CHANGELOG.md`).

## Extracted contracts (subdocs)

| Subdoc | What's inside |
|---|---|
| [`.agent/TOKEN-DISCIPLINE.md`](.agent/TOKEN-DISCIPLINE.md) | Token-efficient execution: planning phases, token/command/git discipline, reporting format, verification, and multi-agent token budget supplement. |
| [`.agent/GUARDEX-TOGGLE.md`](.agent/GUARDEX-TOGGLE.md) | `GUARDEX_ON` toggle semantics in repo-root `.env` (disable / re-enable Guardex workflow). |
| [`.agent/CLAUDE-CODE-WORKFLOW.md`](.agent/CLAUDE-CODE-WORKFLOW.md) | Full Claude Code workflow: tiering table with examples, sandbox + lock + finish steps, default Claude finish (non-negotiable), `skill_guard` notes. |
| [`.agent/OPENSPEC-WORKFLOW.md`](.agent/OPENSPEC-WORKFLOW.md) | OpenSpec-first workflow, philosophy, tooling-freshness commands, source-of-truth layout, documentation model (spec + context), and `/opsx:*` command list. |
| [`.agent/MULTI-AGENT-CONTRACT.md`](.agent/MULTI-AGENT-CONTRACT.md) | Repo-specific supplements to the marker-managed multiagent-safety contract: local base safety, ownership/lock discipline (incl. `main.rs` lock), shared behavior protection, integrator finalization gate. |
| [`.agent/PLAN-WORKSPACE.md`](.agent/PLAN-WORKSPACE.md) | `openspec/plan/` workspace contract: default quick flow, role tasks files, checklist headings, helper sub-branch exception, scaffold command. |
| [`.agent/STALLED-WORKTREE-RECOVERY.md`](.agent/STALLED-WORKTREE-RECOVERY.md) | How `scripts/agent-stalled-report.sh` and `scripts/agent-autofinish-watch.sh` recover stalled `agent/*` worktrees; `__source-probe-*` cleanup steps. |

<!-- multiagent-safety:START -->
## Multi-Agent Execution Contract: Guardex + Colony

### Repo toggle

Guardex is enabled by default.

If the repo-root `.env` sets any of these values, treat this entire Guardex contract as disabled for the repo:

```text
GUARDEX_ON=0
GUARDEX_ON=false
GUARDEX_ON=no
GUARDEX_ON=off
```

When disabled, do not require Guardex worktrees, lock claims, completion flow, or OpenSpec workflow until `GUARDEX_ON` is re-enabled.

To explicitly enable:

```text
GUARDEX_ON=1
```

### Core rules

- Work from an `agent/*` branch and worktree, never directly on the protected base branch.
- Claim files before edits.
- Use Colony for coordination before falling back to OMX state/notepad.
- Prefer fff MCP tools for file search whenever available; do not route file search through RTK when fff can answer it.
- Use OpenSpec for durable behavior contracts and change-driven work.
- Keep outputs compact: less word, same proof.
- Commit, push, and open/update a PR for completed work unless the user explicitly says to keep it local.
- Do not embed stale memory dumps, generated status snapshots, PR transcripts, session history, or long logs in this file.

### Task-size routing

Small tasks stay direct and caveman-only.

For typos, single-file tweaks, one-liners, version bumps, comment-only changes, or similarly bounded asks, solve directly and do not escalate into heavy orchestration just because a keyword appears.

Treat these prefixes as explicit lightweight escape hatches:

- `quick:`
- `simple:`
- `tiny:`
- `minor:`
- `small:`
- `just:`
- `only:`

Promote to full Guardex / OMX orchestration only when scope grows into:

- multi-file behavior change
- API/schema work
- refactor
- migration
- architecture
- cross-cutting scope
- long prompt
- multi-agent execution

### Colony coordination loop

Use Colony as the primary coordination surface.

On every startup, resume, follow-up, or "continue" request, run this order:

1. `mcp__colony__hivemind_context`
2. `mcp__colony__attention_inbox`
3. `mcp__colony__task_ready_for_agent`
4. `mcp__colony__search` only when prior decisions, earlier lanes, file history, or error context matter.

Rules:

- Use `task_ready_for_agent` to choose work.
- Use `task_list` only for browsing/debugging. Do not use `task_list` as the normal work picker.
- If an agent reaches for `task_list` repeatedly while choosing work, stop and call `task_ready_for_agent` instead. `task_list` is an inventory tool, not a scheduler.
- Before editing files on an active task, call `task_claim_file` for each touched file.
- Use `task_post` for task-thread notes, decisions, blockers, and working-state updates.
- Use `task_message` / `task_messages` for directed agent-to-agent communication.
- Use `get_observations` only after compact Colony tools return IDs worth hydrating.

Fallback:

- Colony is considered unavailable only when the MCP namespace is missing, the tool call fails, or the installed Colony server does not expose the required tool.
- If `attention_inbox` or `task_ready_for_agent` is missing, fall back to `hivemind_context`, then `task_list`, then hydrate only the relevant task IDs.
- Do not skip Colony just because OMX state exists. OMX is fallback, not the first coordination source.
- Read `.omx/state` and `.omx/notepad.md` only when Colony is unavailable, missing the needed state, or the task explicitly depends on legacy OMX state.
- Keep `.omx/notepad.md` lean: live handoffs only.

### Working-state notes

Colony is preferred over generic notepad state.

A working-state note should be task-scoped, searchable, and useful to another agent resuming the lane.

When saving progress, use a task-scoped Colony note when possible:

```text
task_post kind=note
content="branch=<branch>; task=<task>; blocker=<blocker>; next=<next>; evidence=<path|command|PR|spec>"
```

Use exactly these fields for handoff-style notes:

- `branch`
- `task`
- `blocker`
- `next`
- `evidence`

Do not store long proof dumps, stale narrative, or full logs in notepads. Put bulky proof in OpenSpec artifacts, PRs, or command output.

### Token / context budget

Default: less word, same proof.

- For prompts about `token inefficiency`, `reviewer mode`, `minimal token overhead`, or session waste patterns, switch into low-overhead mode.
- Plan in at most 4 bullets.
- Execute by phase.
- Batch related reads and commands.
- Avoid duplicate reads and interactive loops.
- Keep outputs compact.
- Verify once per phase.
- Low output alone is not a defect. A bounded run that finishes in roughly <=10 steps is usually fine.
- Low output spread across 20+ steps with rising per-turn input is fragmentation and should be treated as context growth first.
- Startup / resume summaries stay tiny: `branch`, `task`, `blocker`, `next`, and `evidence`.
- Front-load scaffold/path discovery into one grouped inspection pass. Avoid serial `ls` / `find` / `rg` / `cat` retries that rediscover the same path state.
- Treat repeated `write_stdin`, repeated `sed` / `cat` peeks, and tiny diagnostic follow-up checks as strong negative signals.
- If a session turns fragmented, collapse back to inspect once, patch once, verify once, and summarize once.
- Tool / hook summaries stay tiny: command, status, last meaningful lines only. Drop routine hook boilerplate.
- Keep raw terminal interaction out of long-lived context. For `write_stdin` or interactive babysitting, retain only process, action sent, current result, and next action.
- Keep execution log separate from reasoning context: full commands/stdout belong in logs, while prompt context keeps only the latest 1-2 checkpoints plus the newest tool-result summary.
- Treat local edit/commit, remote publish/PR, CI diagnosis, and cleanup as bounded phases.
- Do not spend fresh narration or approval turns on obvious safe follow-ons inside an already authorized phase unless the risk changes.

### FFF file search

Use the fff MCP tools for all file search operations instead of default tools, including RTK shell wrappers.

If fff MCP tools are unavailable in the current client, fall back to `rtk grep`, `rtk find`, `rtk ls`, or `rg` and keep output compact.

### Caveman style

Commentary and progress updates use smart-caveman `ultra` by default:

- Answer order stays fixed: answer first, cause next, fix or next step last.
- drop filler
- use fragments when clear
- answer first
- cause next
- fix or next step last

Keep exact literals unchanged:

- code
- commands
- file paths
- flags
- env vars
- URLs
- numbers
- timestamps
- error text

Switch back to `lite` or normal wording for:

- security warnings
- irreversible actions
- privacy/compliance notes
- ordered instructions where fragments may confuse
- confused users
- commits
- PR text
- specs
- logs
- blocker evidence

Never caveman-compress commands, file paths, specs, logs, or blocker evidence.

### Isolation

Every task runs on a dedicated `agent/*` branch and worktree.

Start with:

```bash
gx branch start "<task>" "<agent-name>"
```

Treat the base branch (`main` / `dev`) as read-only while an agent branch is active.

For every new task, including follow-up work in the same chat/session, if an assigned agent sub-branch/worktree is already open, continue in that sub-branch instead of creating a fresh lane unless the user explicitly redirects scope.

Never implement directly on the local/base branch checkout. Keep it unchanged and perform all edits in the agent sub-branch/worktree.

### Primary-tree lock

On the primary checkout, do not run:

```bash
git checkout <ref>
git switch <ref>
git switch -c ...
git checkout -b ...
git worktree add <path> <existing-agent-branch>
```

Allowed on primary:

```bash
git fetch
git pull --ff-only
```

To work on any `agent/*` branch, run `gx branch start ...` first, then `cd` into the printed worktree path and run every subsequent git command from inside that worktree.

If you are about to type `git checkout agent/...` or `git switch agent/...` from the primary checkout, stop. That is the mistake that flips primary onto an agent branch.

### Dirty-tree rule

Finish or stash edits inside the worktree they belong to before any branch switch on primary.

The post-checkout guard may auto-stash a dirty primary tree as:

```text
guardex-auto-revert <ts> <prev>-><new>
```

That is a safety net, not a workflow. Do not rely on it routinely.

Recover stashed changes with:

```bash
git stash list | grep 'guardex-auto-revert'
```

### Ownership

Before editing, claim files.

Preferred Colony path when on an active task:

```text
mcp__colony__task_claim_file
```

Guardex lock path:

```bash
gx locks claim --branch "<agent-branch>" <file...>
```

Before deleting, confirm the path is in your claim.

Do not edit outside your scope unless reassigned.

If another agent owns or recently touched nearby code:

1. read latest Colony context
2. post a handoff or question
3. avoid reverting unrelated changes
4. report conflicts instead of overwriting

### Handoff gate

Before editing, post a one-line handoff note through Colony `task_post` when a task is active.

Use `.omx/notepad.md` only when Colony is unavailable or the lane explicitly depends on legacy OMX state.

Handoff shape:

```text
branch=<branch>; task=<task>; blocker=<blocker>; next=<next>; evidence=<path|command|PR|spec>
```

Re-read latest Colony context before replacing another agent's code.

### Completion

Finish with:

```bash
gx branch finish --branch "<agent-branch>" --via-pr --wait-for-merge --cleanup
```

or:

```bash
gx finish --all
```

Task is complete only when:

1. changes are committed
2. branch is pushed
3. PR URL is recorded
4. PR state is `MERGED`
5. sandbox worktree is pruned
6. final handoff records proof

If anything blocks, append a `BLOCKED:` note and stop. Do not half-finish.

OMX completion policy: when a task is done, the agent must run `gx branch finish --branch "<agent-branch>" --via-pr --wait-for-merge --cleanup` (or `gx finish --all`) instead of standalone `git push` / `gh pr` commands. The finish flow owns commit, push, PR creation/update, merge wait, and sandbox cleanup.

External approval boundary:

- Guardex cannot bypass Codex host approval prompts or external-remote policy decisions.
- When the host blocks a publish or finish command, request approval for the narrow `gx branch finish ...` command, or for the exact session wrapper that invokes it, and continue after approval.
- Do not replace the finish flow with repeated standalone `git push` / `gh pr` attempts. That increases approval churn and can strand PR, merge, or cleanup state.

### Parallel safety

Assume other agents edit nearby.

- Never revert unrelated changes.
- Never simplify or delete critical shared paths without explicit request and regression coverage.
- Report conflicts in the handoff.
- Prefer compatibility-preserving changes over endpoint-specific rewrites when other agents may be changing adjacent systems.

### Reporting

Every completion handoff includes:

```text
branch
task
files changed
behavior touched
verification commands/results
PR URL
merge state
sandbox cleanup state
risks/follow-ups
```

If blocked, use:

```text
BLOCKED:
branch=<branch>
task=<task>
blocker=<blocker>
next=<next>
evidence=<path|command|PR|spec>
```

### Open questions

If Codex/Claude hits an unresolved question, branching decision, or blocker that should survive chat, record it in:

```text
openspec/plan/<plan-slug>/open-questions.md
```

as an unchecked item:

```md
- [ ] Question or blocker...
```

Resolve it in-place when answered instead of burying it in chat-only notes.

### OpenSpec

OpenSpec is the source of truth for change-driven repo work.

For change-driven tasks, keep:

```text
openspec/changes/<slug>/tasks.md
```

current during work, not batched at the end.

Task scaffolds and manual task edits must include a final completion/cleanup section that ends with PR merge + sandbox cleanup and records PR URL + final `MERGED` evidence.

Validate specs before archive:

```bash
openspec validate --specs
```

Never archive unverified work.

For `T0` / small `T1` lanes, use the compact Colony spec path when available. One Colony handoff plus `colony-spec.md` is enough. Do not create proposal/spec/tasks unless the task grows.

For `T2` / `T3` lanes, keep proposal, spec, design, and tasks live while implementing.

### Version bumps

If a change bumps a published version, the same PR records release notes in the appropriate OpenSpec artifact or release-note mechanism for the repo.

Do not edit `CHANGELOG.md` directly unless the repo explicitly requires manual changelog edits.

### Verification gates

Before claiming completion, run the narrowest meaningful verification for the touched area.

Examples:

```bash
pnpm test
pnpm typecheck
pnpm lint
```

If a command cannot run, record:

```text
command
reason it could not run
risk
next
```

Do not claim green verification without command output evidence.

### What not to put in this file

Do not embed:

- stale memory dumps
- PR transcripts
- long logs
- generated status snapshots
- session history
- full OpenSpec examples
- repeated copies of long workflow docs

Keep this section as the hard multi-agent contract. Put long examples and recovery docs in repo-specific workflow docs.

<!-- multiagent-safety:END -->

<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
<!-- SPECKIT END -->
