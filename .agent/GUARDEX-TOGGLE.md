# Guardex Toggle

- Guardex is enabled for this repo by default.
- If the repo root `.env` sets `GUARDEX_ON=0`, `false`, `no`, or `off`, treat every Guardex-managed workflow requirement in `AGENTS.md` as disabled for that repo.
- Disabled mode means: no required Guardex worktrees, no required Guardex lock-claim flow, no required Guardex PR/cleanup flow, and no required OpenSpec workflow from this contract until `GUARDEX_ON` is set back to a truthy value.
- `GUARDEX_ON=1`, `true`, `yes`, or `on` explicitly re-enables the Guardex workflow.
- Repo-root `.env` examples:
- `GUARDEX_ON=0` disables Guardex for this repo.
- `GUARDEX_ON=1` explicitly enables Guardex for this repo again.

> The marker-managed `multiagent-safety` section in `AGENTS.md` also restates the toggle ("Repo toggle" subsection); both copies must agree.
