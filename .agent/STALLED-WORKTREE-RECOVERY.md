# Stalled Agent Worktree Recovery

The Guardex Codex launcher auto-finishes a branch only when the codex CLI exits cleanly inside it. If the agent is killed, crashes, runs out of budget, or is started directly via `gx branch start` without the launcher, the worktree is left dirty with no commits and no PR — a "stalled" worktree.

`scripts/agent-stalled-report.sh` is a quiet wrapper around `scripts/agent-autofinish-watch.sh --once --dry-run` that surfaces stalled worktrees. It is wired as a `SessionStart` hook in `.claude/settings.json`, so each Claude Code session begins with a one-line summary per stalled branch (and is silent when nothing is stalled).

To act on the report:

- Inspect: `bash scripts/agent-autofinish-watch.sh --once --dry-run`
- Auto-finish once (commit dirty changes, push, create PR, attempt merge): `bash scripts/agent-autofinish-watch.sh --once --auto-merge`
- Run the daemon (poll forever, auto-finish after `--idle-seconds`): `bash scripts/agent-autofinish-watch.sh --daemon --auto-merge`

Defaults: `--idle-seconds=900` (15 min of file silence before auto-commit) and `--branch-prefix=agent/`. The watcher is conservative — it never touches branches outside the configured prefix and only commits worktrees whose files have stopped changing.

## Source-probe temp worktree cleanup

If `gx branch finish --cleanup` reports a worktree held by a `__source-probe-*` temp path, recover with:

```bash
git worktree remove --force .omc/agent-worktrees/agent__claude__<slug>
git worktree prune
git branch -D agent/claude/<slug>
```
