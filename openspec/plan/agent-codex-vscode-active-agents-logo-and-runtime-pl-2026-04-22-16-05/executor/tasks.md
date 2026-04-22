# executor tasks

## 1. Spec

- [x] 1.1 Audit the current extension against the requested brief and mark which behaviors already ship before editing code.
- [x] 1.2 Freeze the touched-file list before coding starts: derived `icon.png`, `package.json`, mirrored READMEs, focused tests, and OpenSpec task boards.

## 2. Tests

- [x] 2.1 Add or update focused tests for the packaged icon asset and any runtime delta that survives the audit.
- [x] 2.2 Define the smoke path: local install, installed payload inspection, and focused Node test execution.

## 3. Implementation

- [x] 3.1 Ship the branded icon lane first.
- [x] 3.2 Apply runtime/provider changes only for missing deltas proven by the audit. Result: no runtime/provider code changes were necessary.
- [x] 3.3 Sync mirrored sources, docs, and focused verification evidence before handoff.

## 4. Checkpoints

- [x] [E1] READY - Execution start checkpoint

## 5. Collaboration

- [x] 5.1 Owner recorded this lane before edits.
- [x] 5.2 N/A - solo lane.

## 6. Cleanup

- [ ] 6.1 If this lane owns finalization, run `gx branch finish --branch agent/codex/vscode-active-agents-logo-and-runtime-pl-2026-04-22-16-05 --base main --via-pr --wait-for-merge --cleanup`.
- [ ] 6.2 Record PR URL + final `MERGED` state in the handoff.
- [ ] 6.3 Confirm sandbox cleanup (`git worktree list`, `git branch -a`) or append `BLOCKED:` and stop.
