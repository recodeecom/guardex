## Why

- Repo owners need a simple repo-local off switch for Guardex when they want to stop using the multi-agent workflow without uninstalling the generated files by hand.
- Today Guardex assumes it is always on once the repo has been bootstrapped, so AGENTS guidance, git hooks, branch-start helpers, and CLI status/doctor flows still push worktrees/OpenSpec even when the repo owner wants to opt out.

## What Changes

- Add a repo-level `GUARDEX_ON` toggle with truthy-by-default semantics.
- Treat `GUARDEX_ON=0|false|no|off` in the repo root `.env` file as an explicit opt-out that disables Guardex workflow enforcement for that repo.
- Update Guardex-managed AGENTS text to document that disabled mode turns off Guardex-specific requirements such as worktrees, lock claims, and OpenSpec workflow.
- Teach Guardex scripts, git hooks, local Codex/Claude hook guards, and CLI reporting to detect the toggle consistently.

## Impact

- Affected surfaces: `AGENTS.md`, Guardex AGENTS template, git hooks, agent bootstrap scripts, Codex/Claude pretool hook guards, CLI setup/scan/status/doctor output, and regression tests.
- Risk is moderate because the change touches several enforcement entry points; missing one would leave disabled repos in a partially-enforced state.
- Existing repos keep current behavior unless they explicitly set `GUARDEX_ON` to a falsey value.
