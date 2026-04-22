## Definition of Done

This change is complete only when **all** of the following are true:

- Every checkbox below is checked.
- The agent branch reaches `MERGED` state on `origin` and the PR URL + state are recorded in the completion handoff.
- If any step blocks (test failure, conflict, ambiguous result), append a `BLOCKED:` line under section 4 explaining the blocker and **STOP**. Do not tick remaining cleanup boxes; do not silently skip the cleanup pipeline.

## Handoff

- Handoff: change=`agent-codex-improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05`; branch=`agent/codex/improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05`; scope=`src/context.js, src/cli/main.js, test/prompt.test.js, README.md, OpenSpec change docs`; action=`add gx prompt part selection, document the new surface, and keep the full prompt modes backward compatible`.
- Copy prompt: Continue `agent-codex-improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05` on branch `agent/codex/improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05`. Work inside the existing sandbox, review `openspec/changes/agent-codex-improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05/tasks.md`, continue from the current state instead of creating a new sandbox, and when the work is done run `gx branch finish --branch agent/codex/improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05 --base main --via-pr --wait-for-merge --cleanup`.

## 1. Specification

- [x] 1.1 Finalize proposal scope and acceptance criteria for `agent-codex-improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05`.
- [x] 1.2 Define normative requirements in `specs/gx-prompt-parts/spec.md`.

## 2. Implementation

- [x] 2.1 Add named `gx prompt --part` / `--list-parts` support while keeping the existing full prompt, `--exec`, and `--snippet` outputs intact.
- [x] 2.2 Teach `gx prompt --exec --part ...` to emit only command-capable slices and fail clearly when a selected part has no command-only form.
- [x] 2.3 Update focused prompt docs/tests in `README.md` and `test/prompt.test.js`.

## 3. Verification

- [x] 3.1 Run targeted project verification commands (`node --check src/context.js`, `node --check src/cli/main.js`, `node --test test/prompt.test.js`) — passed on `2026-04-22`.
- [x] 3.2 Run `openspec validate agent-codex-improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05 --type change --strict` — passed on `2026-04-22`.
- [x] 3.3 Run `openspec validate --specs` — passed on `2026-04-22` with `No items found to validate.`

## 4. Cleanup (mandatory; run before claiming completion)

- [ ] 4.1 Run the cleanup pipeline: `gx branch finish --branch agent/codex/improve-gx-prompt-parts-for-token-usage-2026-04-22-16-05 --base main --via-pr --wait-for-merge --cleanup`. This handles commit -> push -> PR create -> merge wait -> worktree prune in one invocation.
- [ ] 4.2 Record the PR URL and final merge state (`MERGED`) in the completion handoff.
- [ ] 4.3 Confirm the sandbox worktree is gone (`git worktree list` no longer shows the agent path; `git branch -a` shows no surviving local/remote refs for the branch).
