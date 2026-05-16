# agents-interactive-launcher Specification

## Purpose
TBD - created by archiving change agent-codex-interactive-dmux-launcher-panel-2026-04-30-10-55. Update Purpose after archive.
## Requirements
### Requirement: Panel launches interactively on TTY

`gx agents start <task> --panel` SHALL open an interactive terminal launcher when stdin and stdout are TTYs.

#### Scenario: operator changes Codex account count before dry-run launch

- **WHEN** an operator runs `gx agents start "fix auth tests" --panel --codex-accounts 1 --dry-run` in a TTY
- **AND** presses `+`
- **AND** presses Enter
- **THEN** the command SHALL print dry-run plans for two Codex lanes
- **AND** it SHALL NOT create branches, worktrees, session metadata, or agent processes.

#### Scenario: scripted panel output stays static

- **WHEN** `gx agents start "fix auth tests" --panel --codex-accounts 3 --dry-run` runs without a TTY
- **THEN** the command SHALL keep printing the static panel and dry-run plans as before.

#### Scenario: operator cancels interactive panel

- **WHEN** an operator presses ESC or Ctrl-C in the interactive panel
- **THEN** the command SHALL exit with cancellation status
- **AND** it SHALL NOT create branches, worktrees, session metadata, or agent processes.

### Requirement: Launcher Home Pane Management Guidance
The interactive `gx` launcher home SHALL present a bounded pane-management shortcut map that mirrors the existing `gx cockpit`/dmux actions while preserving the agent selection workflow.

#### Scenario: Empty launcher home
- **WHEN** `gx agents start --panel --dry-run` is rendered without a task
- **THEN** the panel shows task-entry guidance
- **AND** the panel shows pane-management shortcuts including terminal, files, and `Alt+Shift+M` pane menu guidance
- **AND** no branch or worktree plan is emitted before a task exists.

#### Scenario: Shortcut help while entering a task
- **WHEN** the launcher is in task-entry mode
- **AND** the user presses `?`
- **THEN** the task text remains unchanged
- **AND** the launcher reports that the shortcut map is visible on the right.

#### Scenario: Cockpit-only pane actions
- **WHEN** the launcher is in agent-selection mode
- **AND** the user presses a cockpit-only pane action such as `t` or `Alt+Shift+M`
- **THEN** the launcher keeps the current selection state
- **AND** reports guidance that the action is available from `gx cockpit`.

### Requirement: Empty panel prompts for task before launch

`gx agents start --panel` SHALL allow the panel to open without a task and collect the task inside the launcher before creating any agent lane.

#### Scenario: TTY panel starts in task input mode

- **WHEN** an operator runs `gx agents start --panel` in a TTY
- **THEN** the GitGuardex launcher SHALL render before any branch/worktree is created
- **AND** the launcher SHALL show a task input prompt
- **AND** printable keys SHALL update the task shown by the launcher
- **AND** Enter SHALL launch only after the task is non-empty.

#### Scenario: scripted panel dry-run renders home without task plans

- **WHEN** `gx agents start --panel --dry-run` runs without a TTY and without a task
- **THEN** the output SHALL render the GitGuardex home panel
- **AND** the output SHALL not render dry-run branch plans until a task exists.

### Requirement: Plain gx opens the interactive launcher home

Plain interactive `gx` SHALL open the same GitGuardex home launcher instead of status output.

#### Scenario: no-argument interactive gx shows home launcher

- **WHEN** an operator runs `gx` with no arguments in a TTY
- **THEN** the command SHALL open the interactive GitGuardex launcher
- **AND** the launcher SHALL ask for the task before launch.

#### Scenario: non-interactive gx keeps status behavior

- **WHEN** `gx` runs with no arguments outside a TTY
- **THEN** the command SHALL keep the existing status behavior.

### Requirement: Panel uses blue dmux-style terminal shell

`gx agents start <task> --panel` SHALL render a full-terminal GitGuardex launcher shell with a blue/cyan visual style, a left project rail, a matrix-style main field, and a centered GitGuardex welcome card.

#### Scenario: scripted panel output includes dmux shell

- **WHEN** `gx agents start "fix auth tests" --panel --codex-accounts 3 --dry-run` runs without a TTY
- **THEN** the output SHALL include a left `gitguardex` rail
- **AND** the output SHALL include a `Welcome` main field
- **AND** the output SHALL include `Press [n] or Enter to create a new agent`
- **AND** the command SHALL keep printing dry-run plans as before.

#### Scenario: TTY panel uses blue ANSI styling

- **WHEN** an operator runs `gx agents start "fix auth tests" --panel --codex-accounts 1 --dry-run` in a TTY
- **THEN** the interactive panel SHALL render with blue/cyan ANSI styling
- **AND** it SHALL preserve keyboard controls for navigation, toggling, Codex account count, launch, and cancel.

#### Scenario: operator launches with new-agent shortcut

- **WHEN** an operator presses `n` in the interactive panel
- **THEN** the command SHALL launch the selected agent plan the same way Enter does.

