# Plan Workspace Contract (`openspec/plan`)

Use `openspec/plan/README.md` as the operational runbook and `openspec/plan/PLANS.md` as the planner narrative-writing contract.

Default quick flow:
1. Create/maintain `openspec/plan/<plan-slug>/`.
2. Create/maintain `openspec/plan/<plan-slug>/open-questions.md`.
3. Keep `open-questions.md` current; when Codex/Claude hits an unresolved question, branching decision, or blocker that should survive chat, record it there as an unchecked `- [ ]` item.
4. Keep role `tasks.md` files current (`planner`, `architect`, `critic`, `executor`, `writer`, `verifier`).
5. Keep checklist headings visible: `## 1. Spec`, `## 2. Tests`, `## 3. Implementation`, `## 4. Checkpoints`, plus a final cleanup section (`## 5. Cleanup` or `## 6. Cleanup`).
6. Update checkboxes continuously while work progresses.
7. Execute from approved `planner/plan.md` with role ownership.
8. Verify with evidence before archive/finish.

Helper sub-branch exception:
- When a helper branch targets another `agent/*` owner branch, implementation is allowed in helper lanes, but OpenSpec change/spec/tasks artifacts stay owned by the owner branch.

Scaffold command:

```bash
scripts/openspec/init-plan-workspace.sh <plan-slug>
```
