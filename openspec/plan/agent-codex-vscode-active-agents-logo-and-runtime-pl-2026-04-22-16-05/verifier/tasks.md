# verifier tasks

## 1. Spec

- [x] 1.1 Define the validation matrix for icon packaging, installed payload contents, preserved tree behavior, and finish evidence.
- [x] 1.2 Validate success/failure conditions and evidence requirements before merge.

## 2. Tests

- [x] 2.1 Execute focused verification commands and collect outputs, including `node --test test/vscode-active-agents-session-state.test.js`.
- [x] 2.2 Validate idempotency/re-run behavior for install and cleanup flows plus any runtime error-path handling touched by the change.

## 3. Implementation

- [x] 3.1 Verify completed work against the acceptance criteria in `specs/vscode-active-agents-extension/spec.md`.
- [x] 3.2 Produce pass/fail findings with concrete evidence links.
- [x] 3.3 Publish final verification sign-off through the completion handoff.

## 4. Checkpoints

- [x] [V1] READY - Verification checkpoint

## 5. Collaboration

- [x] 5.1 Owner recorded this lane before edits.
- [x] 5.2 N/A - solo lane.

## 6. Cleanup

- [ ] 6.1 If this lane owns finalization, run `gx branch finish --branch agent/codex/vscode-active-agents-logo-and-runtime-pl-2026-04-22-16-05 --base main --via-pr --wait-for-merge --cleanup`.
- [ ] 6.2 Record PR URL + final `MERGED` state in the handoff.
- [ ] 6.3 Confirm sandbox cleanup (`git worktree list`, `git branch -a`) or append `BLOCKED:` and stop.
