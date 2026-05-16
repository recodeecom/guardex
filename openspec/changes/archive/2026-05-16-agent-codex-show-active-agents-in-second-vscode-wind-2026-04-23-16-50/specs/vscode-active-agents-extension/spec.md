## ADDED Requirements

### Requirement: Second-window repo-root resolution

The VS Code `gitguardex.activeAgents` view MUST resolve an opened workspace folder to its owning Guardex repo root before reading Active Agents session state, so a second VS Code window opened on a linked worktree or repo subfolder still shows the owning repo's sessions.

#### Scenario: Linked worktree window still shows the owning repo sessions

- **GIVEN** a Guardex repo root has active-session records under `.omx/state/active-sessions/`
- **AND** a second VS Code window is opened on a linked worktree under `.omx/agent-worktrees/...`
- **WHEN** the Active Agents view scans workspace folders for repo candidates
- **THEN** it resolves the owning repo root from the linked worktree git metadata
- **AND** it reads sessions from that owning repo root instead of the worktree path.

### Requirement: Repo-scoped second-window filtering

The VS Code `gitguardex.activeAgents` view MUST keep the tree scoped to the resolved repo root for the currently opened repo, so a `gitguardex` window only shows `gitguardex` agents even when the parent workspace has other Guardex repos.

#### Scenario: Nested repo window only shows nested repo agents

- **GIVEN** a parent workspace contains multiple Guardex repos
- **AND** a second VS Code window is opened directly on the nested `gitguardex` repo or one of its linked worktrees
- **WHEN** the Active Agents view renders the top-level repo rows
- **THEN** it only renders the resolved `gitguardex` repo root for that window
- **AND** it does not add unrelated parent-repo agent sessions to that tree.
