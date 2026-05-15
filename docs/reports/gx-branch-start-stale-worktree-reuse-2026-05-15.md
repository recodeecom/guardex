# `gx branch start` can reuse a stale worktree of an already-merged-and-cleaned branch

- **Reported:** 2026-05-15
- **Filed by:** Claude Code, during a 12-lane parallel TUI improvements dispatch in `recodeee/codex-fleetui`
- **Severity:** Low individually, but a real footgun in autonomous multi-agent dispatches

## Repro

Two agents ran sequentially on the same primary checkout of `recodeee/codex-fleetui`, minutes apart:

1. **Agent A** runs `gx branch start "tui-plan-watcher-validator" "tui-lane-5"` from primary.
   → creates worktree `.omc/agent-worktrees/...__tui-plan-watcher-validator-2026-05-15-23-38/` on branch `agent/claude/tui-plan-watcher-validator-2026-05-15-23-38`.
2. Agent A finishes with `gx branch finish --branch <br> --via-pr --cleanup`. PR merges into main; gx logs:
   ```
   [agent-branch-finish] Merged '...' into 'main' via pr flow and cleaned source branch/remote.
   ```
3. The worktree directory remains on disk because Agent A's shell cwd is inside it (normal deferred-cleanup behavior — gx prints `Leave this directory, then run: gx cleanup --base main`). Fine on its own.
4. **Agent B** runs `gx branch start "tui-plan-validator" "tui-lane-4"` from primary for a different task.
5. **Bug:** gx's worktree lookup matches the Lane-5 worktree from step 1 (still on disk, still keyed under an "agent" path), and returns it as the worktree for Lane 4. Agent B's intended fresh branch is actually pointing at Lane 5's merged HEAD in a stale directory.

## Workaround that surfaced the bug

Agent B noticed the mismatch (its diff included Lane 5's already-merged changes), saved its in-progress file to `/tmp`, ran `gx branch start` a second time from primary, got a clean fresh branch on the second try, and copied the file in. Final PR ([recodeee/codex-fleetui#131](https://github.com/recodeee/codex-fleetui/pull/131)) was clean, but only because the agent caught the reuse manually.

## Expected behavior

`gx branch start` should treat a worktree whose branch has been merged-and-cleaned as ineligible for reuse — or at minimum should not silently return it as the answer to a fresh `gx branch start` call. Two reasonable options:

1. **Prune-eligible on lookup** — when `gx branch start` finds a candidate stale worktree, check `git branch --merged <base>` for its branch; if merged, prune the worktree (and its branch ref) before reissuing a fresh one.
2. **Skip-and-create** — leave the stale worktree alone, but skip it during the lookup so the next `gx branch start` creates a brand new worktree+branch pair.

Option 1 is cleaner long-term (frees disk). Option 2 is safer if there's any risk the stale worktree contains uncommitted artifacts the user wanted to inspect later.

## Likely fix area

The worktree-matching logic inside `gx branch start`. A `git branch --merged <base>` filter before considering a worktree as reusable would catch the case where the branch has already landed.

## Severity rationale

- **Individually low:** the diff mismatch is visible to the user/agent on first edit, so a careful operator catches it before any PR damage.
- **Real footgun in fleets:** in autonomous multi-agent dispatches where N agents in rapid succession share the same primary checkout, the second agent may not notice it's been handed a stale worktree until a PR-time conflict surfaces. In the 12-lane run that surfaced this, agents finished cleanup work in parallel, so the "Agent A still cwd'd in the worktree" window was longer than typical.

## Context

Reported by Claude Code while running a 12-lane parallel TUI improvements dispatch in `recodeee/codex-fleetui`. All 12 PRs ([#121–#132](https://github.com/recodeee/codex-fleetui/pulls?q=is%3Apr+is%3Aclosed)) merged successfully. This issue is the only paper-cut surfaced by that run that lives outside the codex-fleet repo itself.

Filed as a doc-report rather than a GitHub issue because issues are disabled on `recodeee/gitguardex` (`has_issues: false` per the GitHub API).
