# Show Active Agents in a second VS Code window

## Why

The Active Agents view already discovers nested repos when a parent workspace is open, but a second VS Code window opened directly on a Guardex worktree or a subfolder inside that repo can miss the owning repo's active-session state. Operators need the second window to show the same repo-local Active Agents view without leaking unrelated parent-workspace agents.

## What Changes

- Resolve each workspace folder to its owning Guardex repo root instead of assuming the folder path itself is the repo root.
- Keep the Active Agents view scoped to the resolved repo root so a `gitguardex` window only shows `gitguardex` agents.
- Add focused regression coverage for a second VS Code window opened on a linked Guardex worktree.

## Impact

This only changes repo discovery for the VS Code Active Agents companion. It does not change Guardex branch creation, locking, or finish behavior.
