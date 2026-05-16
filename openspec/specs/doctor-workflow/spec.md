# doctor-workflow Specification

## Purpose
TBD - created by archiving change agent-codex-surface-doctor-hidden-failures-2026-04-22-17-06. Update Purpose after archive.
## Requirements
### Requirement: compact doctor auto-finish output surfaces failures before truncating skips
The human-readable compact `gx doctor` auto-finish sweep SHALL keep failed branch results visible when the detail list is truncated.

#### Scenario: compact output promotes a failed row ahead of skipped rows
- **GIVEN** the auto-finish sweep contains more branch details than the compact visible limit
- **AND** at least one failed branch result appears after several skipped rows in raw branch iteration order
- **WHEN** `gx doctor` prints the compact auto-finish summary
- **THEN** a failed branch detail SHALL still appear in the visible compact rows
- **AND** hidden branch results SHALL be summarized with status counts so remaining hidden failures stay explicit

### Requirement: `gx doctor` keeps recursive progress visible
The human-readable `gx doctor` workflow SHALL keep progress visible while recursive child doctor runs execute, so large nested workspaces do not appear frozen.

#### Scenario: nested doctor targets stream visible progress
- **GIVEN** `gx doctor` is running recursively across multiple git repos
- **WHEN** a nested repo doctor run starts and then completes
- **THEN** the CLI SHALL print a target line for that repo before the child run
- **AND** it SHALL print a completion line with the same target plus elapsed time after that repo finishes

### Requirement: doctor sweep respects `--no-wait-for-merge`
The doctor auto-finish sweep SHALL honor the doctor wait mode when it delegates to `scripts/agent-branch-finish.sh`.

#### Scenario: no-wait mode is forwarded into ready-branch cleanup
- **GIVEN** a ready local `agent/*` branch exists during `gx doctor --no-wait-for-merge`
- **WHEN** doctor invokes the auto-finish sweep for that branch
- **THEN** it SHALL call the finish script with `--no-wait-for-merge`
- **AND** it SHALL not silently fall back to `--wait-for-merge`

### Requirement: doctor sweep output stays compact by default
The human-readable auto-finish sweep SHALL show concise actionable branch results by default and SHALL preserve the raw failure text behind an explicit verbose flag.

#### Scenario: default doctor output summarizes a long finish failure
- **GIVEN** an auto-finish failure emits a long rebase-conflict command trace
- **WHEN** `gx doctor` runs without `--verbose-auto-finish`
- **THEN** the default branch detail line SHALL summarize the actionable reason instead of dumping the full `git -C ... rebase --continue` command

#### Scenario: verbose doctor output keeps the raw finish failure text
- **GIVEN** the same auto-finish failure
- **WHEN** `gx doctor --verbose-auto-finish` runs
- **THEN** the printed branch detail SHALL include the original failure text

### Requirement: doctor sweep classifies manual conflict work as actionable skips
The human-readable `gx doctor` auto-finish sweep SHALL classify recoverable manual conflict states as skip/manual-action rows instead of hard failures.

#### Scenario: auto-finish rebase conflict becomes a skip/manual-action row
- **GIVEN** a ready local `agent/*` branch exists during `gx doctor`
- **AND** `scripts/agent-branch-finish.sh` stops because it needs a human to continue or abort a source-probe rebase
- **WHEN** doctor prints the auto-finish summary
- **THEN** the summary SHALL not count that branch as failed
- **AND** the branch detail SHALL be emitted as a skip/manual-action row with the rebase instructions preserved in verbose mode

#### Scenario: true auto-finish failures remain failures
- **GIVEN** a ready local `agent/*` branch exists during `gx doctor`
- **AND** `scripts/agent-branch-finish.sh` fails for a reason other than a recoverable manual conflict
- **WHEN** doctor prints the auto-finish summary
- **THEN** the summary SHALL still count that branch as failed
- **AND** the branch detail SHALL remain a failed row

