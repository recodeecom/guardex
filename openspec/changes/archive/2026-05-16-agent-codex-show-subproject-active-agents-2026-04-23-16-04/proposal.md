# Show nested Active Agents subprojects

## Why

The Active Agents view can show the parent workspace, such as `recodee`, while hiding active managed worktrees that belong to a nested repo such as `recodee/gitguardex` when that nested repo has plain managed worktrees but no active-session files or `AGENT.lock` files. Operators need the top-level view to show the full workspace path so it is clear that work is happening under `recodee -> gitguardex`.

## What Changes

- Discover nested repo roots from managed worktree `.git` files under `.omx/agent-worktrees` and `.omc/agent-worktrees`.
- Keep workspace roots in the scan even when other session files are found.
- Label nested repo roots relative to their workspace folder, for example `recodee -> gitguardex`.
- Watch managed worktree `.git` files so new plain worktrees refresh the Active Agents view.
- Keep live/template VS Code extension copies and focused tests in sync.

## Impact

This is limited to the VS Code Active Agents companion tree. It does not change Guardex branch creation, locking, or finish behavior.
