# Token-Efficient Execution

This document captures the token-discipline rules referenced from `AGENTS.md`. The marker-managed `multiagent-safety` section in `AGENTS.md` also restates a "Token / context budget" subsection scoped to multi-agent execution; treat both as additive.

## Planning

- Start each task with a plan of at most 4 bullets.
- Work in phases:
  1. minimal inspection
  2. grouped edits or grouped repo actions
  3. focused verification
  4. compact summary
- Low output alone is not a defect. A bounded run that finishes in roughly <=10 steps is usually fine; low output stretched across 20+ steps with rising input is fragmentation.
- Treat obvious follow-on actions as part of the active phase; do not stop for tiny internal checkpoints.
- If context grows or the session becomes fragmented, write a short working summary and continue from it.
- Checkpoint after each milestone or roughly every 15-25 tool calls: keep only `task`, `done`, `current status`, `next`, and the latest meaningful evidence; drop the raw transcript from active context.

## Token Discipline

- Do not re-read the same file, line range, or command output unless the file changed or new evidence requires it.
- Prefer targeted reads: `rg`, `head`, `tail`, `git diff`, and exact line ranges.
- Keep command output compact and relevant.
- Avoid repeated status checks unless something changed.
- Treat repeated `sed` / `cat` peeks, tiny diagnostic retries, and repeated `write_stdin` as red flags. When they appear, stop the probe loop and reset to one bounded phase.

## Command Discipline

- Batch related shell commands whenever safe.
- Prefer one-shot non-interactive commands, scripts, or exact invocations over interactive loops or repeated stdin driving.
- For diagnosis, gather the relevant evidence in one pass, then summarize once.
- If the session turns fragmented, collapse back to inspect once, patch once, verify once, and summarize once.

## Git And PR Workflow

- Treat local git and PR work as one bounded phase when possible: inspect status, stage intended files, commit, push, and check PR or CI.
- Do not narrate every trivial git step; summarize branch, commit, PR, and CI state once per phase.

## Reporting

- Use this format:
  1. Plan
  2. Actions taken
  3. Verification
  4. Result
- Keep reports concise and focused on blockers, material changes, and verification outcomes.

## Verification

- Always verify before finalizing.
- Choose the smallest verification that meaningfully proves the change.
- Do not run redundant checks.
- Pause only for destructive actions, ambiguous intent, missing credentials or access, or conflicting evidence.

## Token / Context Budget (multi-agent supplement)

The marker-managed `multiagent-safety` section in `AGENTS.md` ("Token / context budget" subsection) adds the following rules when multiple agents are active; reproduced here for discoverability. The canonical copy lives inside the markers in `AGENTS.md`.

Default: less word, same proof.

- For prompts about `token inefficiency`, `reviewer mode`, `minimal token overhead`, or session waste patterns, switch into low-overhead mode.
- Plan in at most 4 bullets.
- Execute by phase.
- Batch related reads and commands.
- Avoid duplicate reads and interactive loops.
- Keep outputs compact.
- Verify once per phase.
- Low output alone is not a defect. A bounded run that finishes in roughly <=10 steps is usually fine.
- Low output spread across 20+ steps with rising per-turn input is fragmentation and should be treated as context growth first.
- Startup / resume summaries stay tiny: `branch`, `task`, `blocker`, `next`, and `evidence`.
- Front-load scaffold/path discovery into one grouped inspection pass. Avoid serial `ls` / `find` / `rg` / `cat` retries that rediscover the same path state.
- Treat repeated `write_stdin`, repeated `sed` / `cat` peeks, and tiny diagnostic follow-up checks as strong negative signals.
- If a session turns fragmented, collapse back to inspect once, patch once, verify once, and summarize once.
- Tool / hook summaries stay tiny: command, status, last meaningful lines only. Drop routine hook boilerplate.
- Keep raw terminal interaction out of long-lived context. For `write_stdin` or interactive babysitting, retain only process, action sent, current result, and next action.
- Keep execution log separate from reasoning context: full commands/stdout belong in logs, while prompt context keeps only the latest 1-2 checkpoints plus the newest tool-result summary.
- Treat local edit/commit, remote publish/PR, CI diagnosis, and cleanup as bounded phases.
- Do not spend fresh narration or approval turns on obvious safe follow-ons inside an already authorized phase unless the risk changes.
