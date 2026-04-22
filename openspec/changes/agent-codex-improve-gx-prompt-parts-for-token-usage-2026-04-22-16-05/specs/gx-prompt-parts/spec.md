## ADDED Requirements

### Requirement: `gx prompt` SHALL emit named prompt parts
`gx prompt` SHALL support selecting one or more named checklist slices with
`--part <name>` so callers can request only the needed guidance.

#### Scenario: prompt mode returns only the selected parts
- **GIVEN** the user runs `gx prompt --part task-loop --part finish`
- **WHEN** the CLI renders prompt output
- **THEN** it SHALL include the `task-loop` and `finish` guidance in the order
  requested
- **AND** it SHALL omit unrelated prompt sections such as `cleanup` and
  `review-bot`
- **AND** the default `gx prompt` output without `--part` SHALL remain the full
  checklist.

### Requirement: `gx prompt --exec` SHALL support command-capable parts
Command-only prompt output SHALL allow part selection for sections that have a
shell-safe command form.

#### Scenario: exec mode renders only the requested command-capable parts
- **GIVEN** the user runs `gx prompt --exec --part install --part task-loop`
- **WHEN** the CLI renders command-only output
- **THEN** it SHALL emit only the `install` and `task-loop` commands in the
  order requested
- **AND** it SHALL omit command lines for other sections such as `cleanup`
  unless they were requested.

#### Scenario: exec mode rejects prompt-only parts
- **GIVEN** the user runs `gx prompt --exec --part openspec`
- **WHEN** `openspec` has no shell-safe command-only rendering
- **THEN** the CLI SHALL exit non-zero
- **AND** it SHALL report that the selected part is not available in exec mode.

### Requirement: `gx prompt` SHALL list available parts
The CLI SHALL expose the available prompt part names without requiring source
inspection.

#### Scenario: list parts
- **WHEN** the user runs `gx prompt --list-parts`
- **THEN** the CLI SHALL print the supported part names
- **AND** the list SHALL include both command-capable parts and prompt-only
  parts.
