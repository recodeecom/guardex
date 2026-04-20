## ADDED Requirements

### Requirement: Repo-local Guardex toggle
Guardex SHALL treat `GUARDEX_ON` as the repo-level enable/disable switch for Guardex-managed workflow behavior.

#### Scenario: Default remains enabled
- **GIVEN** a repo does not set `GUARDEX_ON` in its process environment or repo root `.env`
- **WHEN** Guardex scripts, hooks, or CLI checks run
- **THEN** Guardex SHALL keep its current workflow behavior enabled
- **AND** existing worktree/OpenSpec enforcement semantics SHALL remain unchanged.

#### Scenario: Repo root `.env` disables Guardex
- **GIVEN** the repo root `.env` contains `GUARDEX_ON=0`
- **WHEN** Guardex git hooks, agent bootstrap scripts, or local Codex/Claude pretool hook guards run inside that repo
- **THEN** they SHALL treat Guardex as disabled for that repo
- **AND** they SHALL NOT require Guardex worktrees, lock claims, or OpenSpec workflow for that repo.

#### Scenario: Disabled repos report disabled state
- **GIVEN** Guardex is disabled for a repo through a falsey `GUARDEX_ON` value
- **WHEN** `guardex scan`, `guardex status`, `guardex doctor`, or `guardex setup` runs against that repo
- **THEN** the CLI SHALL report that Guardex is disabled for the repo instead of surfacing missing-policy findings as failures
- **AND** repo-scoped setup/repair actions SHALL skip re-enabling Guardex-managed enforcement by default.
