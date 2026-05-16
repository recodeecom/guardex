## Why

- `gx prompt` currently emits either the full setup checklist, the full
  command-only block, or the AGENTS managed snippet.
- Agents and humans often need only one slice of that guidance
  (`task-loop`, `finish`, `openspec`, etc.), so they either paste the whole
  checklist or copy those lines into other docs/prompts by hand.
- That wastes tokens in agent handoffs and keeps prompt-facing docs more
  repetitive than they need to be.

## What Changes

- Add named prompt parts to `gx prompt` so callers can request only the needed
  guidance with `--part <name>`.
- Add `gx prompt --list-parts` so the available slices are discoverable without
  reading source or README prose.
- Support `gx prompt --exec --part ...` for command-capable parts only, with a
  clear error when a selected part has no shell-safe command form.
- Update README/help text and focused prompt tests around the new surface.

## Impact

- Existing `gx prompt`, `gx prompt --exec`, and `gx prompt --snippet` behavior
  stays intact for callers that do not request parts.
- Agent/token usage improves because handoffs can fetch just the required
  prompt slices instead of the entire checklist.
- The change is limited to CLI prompt rendering, prompt docs, and focused
  tests; no branch/lock/doctor workflow behavior changes.
