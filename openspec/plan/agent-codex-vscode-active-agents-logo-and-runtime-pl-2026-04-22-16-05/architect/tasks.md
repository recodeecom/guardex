# architect tasks

## 1. Spec

- [x] 1.1 Keep `vscode/guardex-active-agents/` and `templates/vscode/guardex-active-agents/` mirrored for this lane; do not widen scope into source-tree canonicalization.
- [x] 1.2 Lock the packaged-icon strategy to a committed `icon.png` inside each extension tree, derived from the existing repo `logo.png`.

## 2. Tests

- [x] 2.1 Define compatibility checks for VS Code manifest `icon` metadata, installer payload copying, and mirrored-source parity.
- [x] 2.2 Validate that the runtime follow-up preserves grouped `ACTIVE AGENTS` / `CHANGES`, lock-aware rows, and `AGENT.lock` fallback behavior by leaving `extension.js` and `session-schema.js` untouched.

## 3. Implementation

- [x] 3.1 Compare the viable options: in-place patch, source-tree canonicalization, or installer-time asset injection.
- [x] 3.2 Record the chosen architecture and guardrails in `planner/plan.md`.
- [x] 3.3 Publish architecture sign-off notes through the phase board and implementation notes.

## 4. Checkpoints

- [x] [A1] READY - Architecture review checkpoint

## 5. Collaboration

- [x] 5.1 Owner recorded this lane before edits.
- [x] 5.2 N/A - solo lane.

## 6. Cleanup

- [ ] 6.1 If this lane owns finalization, run `gx branch finish --branch agent/codex/vscode-active-agents-logo-and-runtime-pl-2026-04-22-16-05 --base main --via-pr --wait-for-merge --cleanup`.
- [ ] 6.2 Record PR URL + final `MERGED` state in the handoff.
- [ ] 6.3 Confirm sandbox cleanup (`git worktree list`, `git branch -a`) or append `BLOCKED:` and stop.
