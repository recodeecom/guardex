# Tasks

## 1. Contract

- [x] 1.1 Update `AGENTS.md` to require `openspec/plan/<plan-slug>/open-questions.md` for unresolved questions.
- [x] 1.2 Update `templates/AGENTS.multiagent-safety.md` with the same open-questions rule.

## 2. OpenSpec Plan Docs

- [x] 2.1 Add `openspec/plan/README.md` with the shared open-questions workflow.
- [x] 2.2 Add `openspec/plan/PLANS.md` with planner-specific question discipline.

## 3. Scaffold

- [x] 3.1 Update `scripts/openspec/init-plan-workspace.sh` to create and reference `open-questions.md`.
- [x] 3.2 Update `templates/scripts/openspec/init-plan-workspace.sh` to stay in template parity.
- [x] 3.3 Regenerate this task's plan workspace and seed the user-provided questions.

## 4. Verification

- [x] 4.1 Read the final diff to confirm the live contract, template contract, and scaffold all mention `open-questions.md`.
- [x] 4.2 Run the plan-workspace scaffold for this task and confirm `open-questions.md` is created.
- [x] 4.3 Run focused shell verification for modified docs/scripts and record results.

## 5. Cleanup

- [x] 5.1 Finish the branch with `gx branch finish --branch agent/codex/record-codex-open-questions-in-plan-work-2026-04-22-18-25 --base main --via-pr --wait-for-merge --cleanup`.
- [x] 5.2 Record PR URL + final `MERGED` state in the handoff. PR `#339`: `https://github.com/recodeee/gitguardex/pull/339`, state `MERGED`, merged at `2026-04-22T16:36:52Z`.
- [x] 5.3 Confirm sandbox cleanup (`git worktree list`, `git branch -a`) or append `BLOCKED:` and stop. Verified from `/home/deadpool/Documents/recodee/gitguardex`: the task branch is gone locally, the source worktree is pruned, and only an unrelated dirty worktree remains preserved.
