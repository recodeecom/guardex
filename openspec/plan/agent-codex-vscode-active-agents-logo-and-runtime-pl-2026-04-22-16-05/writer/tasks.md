# writer tasks

## 1. Spec

- [x] 1.1 Validate the docs audience: operators installing the local VS Code companion and developers maintaining the duplicated extension sources.
- [x] 1.2 Keep terminology consistent across plan artifacts, extension README copy, and any root README changes.

## 2. Tests

- [x] 2.1 Define a docs verification checklist covering icon packaging, install commands, reload guidance, and scope notes about runtime deltas.
- [x] 2.2 Validate command/help text examples against the actual installer and finish flow.

## 3. Implementation

- [x] 3.1 Update `vscode/guardex-active-agents/README.md` and mirrored template README for the branding change.
- [x] 3.2 Add or refine operator expectations for install, reload, and branded extension metadata.
- [x] 3.3 Publish a final docs change summary with references through the completion handoff.

## 4. Checkpoints

- [x] [W1] READY - Docs update checkpoint

## 5. Collaboration

- [x] 5.1 Owner recorded this lane before edits.
- [x] 5.2 N/A - solo lane.

## 6. Cleanup

- [ ] 6.1 If this lane owns finalization, run `gx branch finish --branch agent/codex/vscode-active-agents-logo-and-runtime-pl-2026-04-22-16-05 --base main --via-pr --wait-for-merge --cleanup`.
- [ ] 6.2 Record PR URL + final `MERGED` state in the handoff.
- [ ] 6.3 Confirm sandbox cleanup (`git worktree list`, `git branch -a`) or append `BLOCKED:` and stop.
