# critic tasks

## 1. Spec

- [x] 1.1 Validate that the plan stays delta-based and does not reopen already-landed Active Agents features without evidence.
- [x] 1.2 Validate that risks, consequences, and mitigations are explicit for asset packaging, mirrored sources, and finish-flow cleanup.

## 2. Tests

- [x] 2.1 Validate that every acceptance criterion maps to a concrete proof surface: installed asset, focused tests, OpenSpec validation, or merge evidence.
- [x] 2.2 Validate that the verification steps are concrete and reproducible from the sandbox worktree.

## 3. Implementation

- [x] 3.1 Produce a verdict (`APPROVE`) on the plan and call out unnecessary runtime work: no provider/session rewrite was needed.
- [x] 3.2 Confirm revised drafts resolve prior findings before approval.
- [x] 3.3 Publish final quality/risk sign-off notes through the phase board and implementation notes.

## 4. Checkpoints

- [x] [C1] READY - Quality gate checkpoint

## 5. Collaboration

- [x] 5.1 Owner recorded this lane before edits.
- [x] 5.2 N/A - solo lane.

## 6. Cleanup

- [ ] 6.1 If this lane owns finalization, run `gx branch finish --branch agent/codex/vscode-active-agents-logo-and-runtime-pl-2026-04-22-16-05 --base main --via-pr --wait-for-merge --cleanup`.
- [ ] 6.2 Record PR URL + final `MERGED` state in the handoff.
- [ ] 6.3 Confirm sandbox cleanup (`git worktree list`, `git branch -a`) or append `BLOCKED:` and stop.
