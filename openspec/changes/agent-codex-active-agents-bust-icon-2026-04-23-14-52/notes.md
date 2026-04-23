# agent-codex-active-agents-bust-icon-2026-04-23-14-52 (minimal / T1)

Branch: `agent/codex/active-agents-bust-icon-2026-04-23-14-52`

Replace the Active Agents Activity Bar icon with a simplified bust-style silhouette so the sidebar reads closer to the sculpted logo direction from the reference image while still fitting VS Code's small monochrome icon constraints.

Scope:
- Replace `vscode/guardex-active-agents/media/active-agents-hivemind.svg` with a bust-style Activity Bar icon.
- Mirror the same SVG update into `templates/vscode/guardex-active-agents/media/active-agents-hivemind.svg`.
- Bump `vscode/guardex-active-agents/package.json` and `templates/vscode/guardex-active-agents/package.json` to `0.0.12` so the workspace install/reload path can pick up the new asset cleanly.
- Keep runtime/session logic untouched.
- Do not fake a red numeric Activity Bar badge in code; the current `TreeView.badge` surface only exposes `value` and `tooltip`, not per-view badge color/severity.

Verification:
- Manual diff check of both mirrored SVG assets.
- Confirm both extension manifests stay in sync at `0.0.12`.
- Confirm the extension still points at the same `media/active-agents-hivemind.svg` path in shipped/template manifests.
- Confirm the current badge code still uses `TreeView.badge` count + tooltip only.

## Handoff

- Handoff: change=`agent-codex-active-agents-bust-icon-2026-04-23-14-52`; branch=`agent/codex/active-agents-bust-icon-2026-04-23-14-52`; scope=`vscode/guardex-active-agents/media/active-agents-hivemind.svg, templates/vscode/guardex-active-agents/media/active-agents-hivemind.svg, paired extension package.json files, T1 notes`; action=`ship the new bust icon, keep manifests mirrored at 0.0.12, and record the VS Code badge color limitation before finish`.
- Copy prompt: Continue `agent-codex-active-agents-bust-icon-2026-04-23-14-52` on branch `agent/codex/active-agents-bust-icon-2026-04-23-14-52`. Work inside the existing sandbox, keep the new icon readable at Activity Bar size, and if finish is requested keep `.vscode/settings.json` out of the commit.

## Cleanup

- [ ] Run: `gx branch finish --branch agent/codex/active-agents-bust-icon-2026-04-23-14-52 --base main --via-pr --wait-for-merge --cleanup`
- [ ] Record PR URL + `MERGED` state in the completion handoff.
- [ ] Confirm sandbox worktree is gone (`git worktree list`, `git branch -a`).
