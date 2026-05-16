# Workflow (OpenSpec-first)

When Guardex is enabled, this repo uses **OpenSpec as the primary workflow and SSOT** for change-driven development.

## Versioning Rule

- If a change publishes or bumps a package version, the same change must also update the release notes / changelog entries. See [Documentation & Release Notes](#documentation--release-notes) for where to record change notes.

## OpenSpec philosophy (enforced)

- fluid, not rigid
- iterative, not waterfall
- easy to apply, not process-heavy
- built for brownfield and greenfield work
- scalable from solo projects to large teams

## How to work (default)

1. Use the default artifact-guided flow first: `/opsx:propose <idea>` -> `/opsx:apply` -> `/opsx:archive`.
2. For **every** repo change (feature, fix, refactor, chore, test, config, docs), create/update an OpenSpec change in `openspec/changes/**` before editing code.
   Exception: helper agent branches that target another `agent/*` base branch are execution-only assists and must not create standalone OpenSpec change/spec/tasks docs; keep documentation on the owner change branch.
3. Keep artifacts editable throughout implementation (proposal/spec/design/tasks are living docs, not rigid phase gates).
4. Implement from `tasks.md`; keep code and specs in sync (update `spec.md` as behavior changes).
5. Keep `tasks.md` checkpoint status updated continuously during execution; mark items as soon as they complete (do not batch-update at the end).
6. Default `tasks.md` scaffolds and manual task edits must include a final completion/cleanup section that ends with PR merge + sandbox cleanup (`gx branch finish ... --cleanup` or `gx finish --all`) and captures PR URL + final `MERGED` handoff evidence.
7. Validate specs locally: `openspec validate --specs`.
8. Verify before archiving (`/opsx:verify <change>` when applicable); never archive unverified changes.

## OpenSpec tooling freshness (required)

- Keep the global CLI current:
  - `npm install -g @fission-ai/openspec@latest`
- Refresh project-local AI guidance/slash commands after updates:
  - `openspec update`
- If expanded workflow commands are needed (`/opsx:new`, `/opsx:continue`, `/opsx:ff`, `/opsx:verify`, `/opsx:sync`, `/opsx:bulk-archive`, `/opsx:onboard`), select a profile and refresh:
  - `openspec config profile <profile-name>`
  - `openspec update`

## Source of Truth

- **Specs/Design/Tasks (SSOT)**: `openspec/`
  - Active changes: `openspec/changes/<change>/`
  - Main specs: `openspec/specs/<capability>/spec.md`
  - Archived changes: `openspec/changes/archive/YYYY-MM-DD-<change>/`

## Documentation & Release Notes

- **Do not add/update feature or behavior documentation under `docs/`**. Use OpenSpec context docs under `openspec/specs/<capability>/context.md` (or change-level context under `openspec/changes/<change>/context.md`) as the SSOT.
- **Do not edit `CHANGELOG.md` directly.** Leave changelog updates to the release process; record change notes in OpenSpec artifacts instead.

### Documentation Model (Spec + Context)

- `spec.md` is the **normative SSOT** and should contain only testable requirements.
- Use `openspec/specs/<capability>/context.md` for **free-form context** (purpose, rationale, examples, ops notes).
- If context grows, split into `overview.md`, `rationale.md`, `examples.md`, or `ops.md` within the same capability folder.
- Change-level notes live in `openspec/changes/<change>/context.md` or `notes.md`, then **sync stable context** back into the main context docs.

Prompting cue (use when writing docs):
"Keep `spec.md` strictly for requirements. Add/update `context.md` with purpose, decisions, constraints, failure modes, and at least one concrete example."

## Commands (recommended)

- Default flow (recommended): `/opsx:propose <idea>` -> `/opsx:apply` -> `/opsx:archive`
- Expanded flow start: `/opsx:new <kebab-case>`
- Continue artifacts: `/opsx:continue <change>`
- Fast-forward artifacts: `/opsx:ff <change>`
- Verify before archive: `/opsx:verify <change>`
- Sync delta specs → main specs: `/opsx:sync <change>`
- Bulk archive completed changes: `/opsx:bulk-archive`
- Guided onboarding workflow: `/opsx:onboard`
- Create/refresh plan workspace: `/opsx:plan <plan-slug>`
- Update plan checkpoint: `/opsx:checkpoint <plan-slug> <role> <checkpoint-id> <state> <text...> [--phase <phase-id>]` (`--phase` syncs the matching line in `openspec/plan/<slug>/phases.md` using the same `--state`)
- Watch team -> plan checkpoints: `/opsx:watch-plan <team-name> <plan-slug>`
