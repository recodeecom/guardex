## ADDED Requirements

### Requirement: Nested subproject Active Agents discovery

The VS Code `gitguardex.activeAgents` view MUST discover nested repository roots under the open workspace when those nested repositories have managed agent worktrees under `.omx/agent-worktrees` or `.omc/agent-worktrees`, even when those worktrees only expose a worktree `.git` file and do not expose active-session JSON or `AGENT.lock` telemetry.

#### Scenario: Top-level view includes a nested repo with plain managed worktrees

- **GIVEN** a workspace folder such as `recodee`
- **AND** a nested repository such as `recodee/gitguardex`
- **AND** the nested repository has a managed worktree under `.omx/agent-worktrees`
- **WHEN** the Active Agents view scans the workspace
- **THEN** it includes the nested repository in the top-level repo list
- **AND** it reads the nested repository sessions from that nested repository root.

### Requirement: Workspace-relative nested repo labels

The VS Code `gitguardex.activeAgents` view MUST label nested repository roots relative to the open workspace folder so operators can see the workspace-to-subproject path at the top level.

#### Scenario: Nested repo label shows workspace and subproject

- **GIVEN** the open workspace folder is `recodee`
- **AND** the discovered active repo root is `recodee/gitguardex`
- **WHEN** the Active Agents view renders the repo row
- **THEN** the repo row label is `recodee -> gitguardex`.

### Requirement: Managed worktree discovery refresh

The VS Code `gitguardex.activeAgents` view MUST refresh when managed worktree `.git` files are created, changed, or deleted under `.omx/agent-worktrees` or `.omc/agent-worktrees`.

#### Scenario: New plain managed worktree appears without active-session telemetry

- **GIVEN** a nested repository has no active-session JSON and no `AGENT.lock` telemetry
- **WHEN** a managed worktree `.git` file appears under `.omx/agent-worktrees`
- **THEN** the Active Agents view schedules a refresh
- **AND** the nested repository becomes visible if it has readable managed worktree sessions.
