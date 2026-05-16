## 1. Specification

- [x] 1.1 Finalize proposal scope and acceptance criteria for `agent-codex-guardex-on-repo-toggle-2026-04-20-19-25`.
- [x] 1.2 Define normative requirements in `specs/guardex-on-repo-toggle/spec.md`.

## 2. Implementation

- [x] 2.1 Add `GUARDEX_ON` disabled-mode guidance to this repo's `AGENTS.md` and the managed AGENTS template.
- [x] 2.2 Implement repo-local `GUARDEX_ON` detection across Guardex scripts and enforcement hooks.
- [x] 2.3 Update CLI scan/status/doctor/setup behavior so disabled repos report as disabled instead of misconfigured.
- [x] 2.4 Add/update focused regression coverage for disabled-mode behavior.

## 3. Verification

- [x] 3.1 Run targeted project verification commands.
  Evidence: `node --check bin/multiagent-safety.js`; `bash -n scripts/agent-branch-start.sh scripts/codex-agent.sh scripts/guardex-env.sh templates/scripts/agent-branch-start.sh templates/scripts/codex-agent.sh templates/scripts/guardex-env.sh templates/githooks/pre-commit templates/githooks/pre-push templates/githooks/post-merge templates/githooks/post-checkout .githooks/pre-commit .githooks/pre-push .githooks/post-merge .githooks/post-checkout`; `python3 -m py_compile .codex/hooks/skill_guard.py .claude/hooks/skill_guard.py`; `node --test test/install.test.js`.
- [x] 3.2 Run `openspec validate agent-codex-guardex-on-repo-toggle-2026-04-20-19-25 --type change --strict`.
- [x] 3.3 Run `openspec validate --specs`.
