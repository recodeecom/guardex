# dmux pane context menu tasks

## 1. Spec

- [x] 1.1 Define the dmux-style pane menu behavior and safety boundaries.

## 2. Tests

- [x] 2.1 Cover menu rendering, item order, hotkeys, navigation, selection, cancel, disabled status, and compatibility exports.
  - Evidence: `node --test test/cockpit-pane-menu.test.js test/cockpit-menu.test.js test/cockpit-control.test.js test/cockpit-keybindings.test.js` passed (`28/28`).
- [x] 2.2 Cover cockpit shortcut wiring for `m` and `Alt+Shift+M`.
  - Evidence: same focused command passed (`28/28`).
- [x] 2.3 Run existing focused cockpit/tmux/launcher tests.
  - Evidence: `node --test test/cockpit-pane-menu.test.js test/cockpit-menu.test.js test/cockpit-control.test.js test/cockpit-keybindings.test.js test/tmux-session.test.js test/agents-start-dry-run.test.js` passed (`41/41`).

## 3. Implementation

- [x] 3.1 Add reusable pane menu model/rendering module.
- [x] 3.2 Keep `src/cockpit/menu.js` as a compatibility export.
- [x] 3.3 Wire cockpit control/action mapping to the pane menu without bypassing Guardex safety.

## 4. Verification

- [x] 4.1 Run `openspec validate agent-codex-dmux-pane-context-menu-2026-04-30-13-54 --type change --strict`.
  - Evidence: passed.
- [ ] 4.2 Run `npm test`.
  - Evidence: failed (`441/454` passing, `12` failing, `1` skipped). Failures are outside the pane-menu model/rendering proof surface, including `test/agents-launch.test.js`, `test/agents-lifecycle.test.js`, `test/agents-sessions.test.js`, and stale `test/cockpit-command.test.js` expectations.

## 5. Cleanup

- [ ] 5.1 Commit, push, open PR, merge, and cleanup with `gx branch finish --branch agent/codex/dmux-pane-context-menu-2026-04-30-13-54 --base main --via-pr --wait-for-merge --cleanup`.
- [ ] 5.2 Record PR URL, final `MERGED` state, and sandbox cleanup evidence.
  - Blocked for this slice: sibling dirty files exist in the same worktree (`src/cockpit/pane-actions.js`, `src/cockpit/action-runner.js`, `src/agents/selection-panel.js`, and related tests) and are not part of this no-backend menu model task.
