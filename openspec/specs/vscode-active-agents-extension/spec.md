# vscode-active-agents-extension Specification

## Purpose
TBD - created by archiving change agent-codex-vscode-tree-lock-decorations-clean-2026-04-22-11-09. Update Purpose after archive.
## Requirements
### Requirement: Session rows show lock ownership counts

The Active Agents tree MUST append `🔒 N` to each session row, where `N` is the number of lock-registry entries owned by that session's branch.

#### Scenario: session row includes branch lock count

- **WHEN** `.omx/state/agent-file-locks.json` contains entries owned by an active session branch
- **THEN** the rendered session row label includes `🔒 <count>`
- **AND** the session tooltip includes the same lock count

### Requirement: Repo-root changes warn on foreign locks

Repo-root `CHANGES` rows MUST warn when a changed file is claimed by a different branch than the repo worktree's current branch.

#### Scenario: repo-root change is locked by another branch

- **WHEN** a repo-root changed file appears in `.omx/state/agent-file-locks.json`
- **AND** the lock owner branch differs from the repo worktree's current branch
- **THEN** the corresponding `ChangeItem` uses a warning icon
- **AND** the tooltip names the lock owner branch

### Requirement: Lock registry reads are watcher-driven

The Active Agents provider MUST refresh cached lock state from lock-file watcher events and MUST NOT re-read the lock registry on every tree load.

#### Scenario: repeated tree loads do not re-read unchanged lock state

- **WHEN** the tree is loaded multiple times without a lock-file watcher event
- **THEN** the provider reuses cached lock state

#### Scenario: lock-file watcher refreshes cache

- **WHEN** `.omx/state/agent-file-locks.json` changes
- **THEN** the lock watcher refreshes the provider cache before the next tree render

### Requirement: Lock registry file is hidden from repo-root changes

The repo-root `CHANGES` section MUST ignore `.omx/state/agent-file-locks.json`.

#### Scenario: lock registry file is modified

- **WHEN** `.omx/state/agent-file-locks.json` is dirty in the repo root
- **THEN** it does not render as a `ChangeItem`

### Requirement: Active Agents view falls back to live managed worktree telemetry
The GitGuardEx Active Agents VS Code companion SHALL surface managed worktrees that expose a live root-level `AGENT.lock` marker, even when no `.omx/state/active-sessions/*.json` launcher record exists for that worktree.

#### Scenario: Managed worktree lock creates a synthetic live row
- **WHEN** a managed Guardex worktree under `.omx/agent-worktrees/` or `.omc/agent-worktrees/` contains a valid `AGENT.lock`
- **AND** no `.omx/state/active-sessions/*.json` record exists for that same worktree
- **THEN** the Active Agents SCM view shows a live row for that worktree
- **AND** the row still derives `thinking` versus `working` from the worktree git state.

#### Scenario: Wrapper session record wins over lock fallback
- **WHEN** both a valid `.omx/state/active-sessions/*.json` record and a valid root `AGENT.lock` exist for the same managed worktree
- **THEN** the companion renders a single row for that worktree
- **AND** it prefers the launcher-backed session metadata instead of duplicating the row.

#### Scenario: Lock fallback refreshes with worktree telemetry updates
- **WHEN** a managed worktree `AGENT.lock` file is created, changed, or deleted
- **THEN** the Active Agents companion refreshes the affected SCM rows
- **AND** invalid lock payloads are ignored without crashing the view.

### Requirement: Active Agents ships a branded extension icon
The GitGuardex Active Agents extension SHALL package a branded icon that resolves from inside the installed extension directory.

#### Scenario: Local install includes packaged icon asset
- **WHEN** `scripts/install-vscode-active-agents-extension.js` installs the extension
- **THEN** the installed extension directory contains an icon asset derived from the repo `logo.png`
- **AND** `vscode/guardex-active-agents/package.json` points its `icon` field at that packaged asset
- **AND** VS Code can show the branded icon instead of the default placeholder on the extension details page.

### Requirement: Mirrored extension sources stay consistent
User-visible Active Agents extension behavior SHALL stay aligned across the duplicated `vscode/guardex-active-agents/` and `templates/vscode/guardex-active-agents/` trees unless the change intentionally collapses them to one canonical source.

#### Scenario: Branding or runtime changes touch duplicated extension files
- **WHEN** this change updates extension packaging, manifest metadata, runtime behavior, or bundled assets
- **THEN** the same shipped behavior is present in both source trees
- **OR** the change removes one source tree and updates installer/tests to the new single source of truth in the same change
- **AND** focused regression coverage validates the shipped install payload.

### Requirement: Runtime follow-up stays delta-based
This follow-up SHALL preserve the already-shipped Active Agents grouped tree behavior and only add runtime changes that are still missing after audit.

#### Scenario: Runtime brief overlaps already-landed features
- **WHEN** the executor compares the requested runtime brief against the current extension code and prior Active Agents change specs
- **THEN** grouped `ACTIVE AGENTS` and repo `CHANGES` behavior, group ordering, lock awareness, and `AGENT.lock` fallback remain intact
- **AND** only unsatisfied deltas are added to `extension.js`, `session-schema.js`, related docs, or tests
- **AND** the change does not reimplement already-shipped behavior solely because it appeared in the user brief.

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

### Requirement: Active Agents shows managed sandboxes without launcher telemetry

The GitGuardex Active Agents VS Code companion SHALL surface real managed `agent/*` git worktrees under `.omx/agent-worktrees/` and `.omc/agent-worktrees/` even when no `.omx/state/active-sessions/*.json` launcher record and no worktree `AGENT.lock` telemetry exists.

#### Scenario: Plain managed worktree is visible

- **GIVEN** a repository has a managed worktree under `.omx/agent-worktrees/`
- **AND** that worktree is checked out on an `agent/*` branch
- **AND** there is no active-session JSON file or worktree `AGENT.lock`
- **WHEN** the Active Agents view refreshes
- **THEN** the view shows that worktree as an active agent row
- **AND** dirty files inside the worktree drive the row activity state and changed-file count

#### Scenario: Telemetry remains preferred

- **GIVEN** a managed worktree has valid `AGENT.lock` telemetry
- **WHEN** the Active Agents view refreshes
- **THEN** the view uses the richer telemetry-backed session data for that worktree instead of the plain fallback row

### Requirement: Active session records expose live heartbeat freshness
Guardex SHALL write active-session records with a heartbeat timestamp that the extension can use to distinguish live sessions from crashed or abandoned launcher records.

#### Scenario: Session start creates heartbeat fields
- **WHEN** the active-session helper starts a session record
- **THEN** the JSON record includes `startedAt`
- **AND** the JSON record includes `lastHeartbeatAt`
- **AND** the JSON record includes an advisory `state` value.

#### Scenario: Heartbeat refreshes an existing record
- **WHEN** `gx internal heartbeat --branch <branch>` is run in a Guardex repo with an active-session record for that branch
- **THEN** the matching record's `lastHeartbeatAt` advances
- **AND** existing task, branch, pid, and worktree metadata are preserved.

### Requirement: Active Agents keeps repo-root changes separate from sandbox changes
The extension SHALL show repo-root `CHANGES` only for dirty files that belong to the guarded repo root, not files under managed agent worktrees or session-state internals.

#### Scenario: Managed worktree files are dirty under the repo root
- **WHEN** `git status --porcelain` reports changes under `.omx/agent-worktrees/` or `.omc/agent-worktrees/`
- **THEN** those paths are omitted from the repo-root `CHANGES` section.

#### Scenario: Session state files are dirty
- **WHEN** `.omx/state/active-sessions/*.json` or `.omx/state/agent-file-locks.json` is dirty
- **THEN** those state files are omitted from repo-root `CHANGES`.

### Requirement: Active Agents shows touched files under each live session
The extension SHALL render changed-file rows beneath each session row when a sandbox worktree has touched files.

#### Scenario: Session worktree has dirty files
- **WHEN** a session derives `working` state from dirty worktree paths
- **THEN** the session row is expandable
- **AND** its children list the touched worktree-relative files.

#### Scenario: Touched file is locked by another branch
- **WHEN** a session touched file intersects `.omx/state/agent-file-locks.json` with an owner branch different from the session branch
- **THEN** that file row uses a warning icon
- **AND** its tooltip names the lock owner.

### Requirement: Active Agents publishes context keys for surrounding UI
The extension SHALL publish context keys that describe whether agents and lock conflicts are currently visible.

#### Scenario: Provider refresh observes sessions and conflicts
- **WHEN** the Active Agents provider refreshes
- **THEN** it sets `guardex.hasAgents` to true if at least one session is present
- **AND** it sets `guardex.hasConflicts` to true if any visible touched file or repo-root change is locked by another branch.

### Requirement: Active Agents exposes terminal-first inline session controls
The VS Code Active Agents companion SHALL prioritize jumping into the live session terminal over opening a per-file diff from the session row.

#### Scenario: Session row offers terminal access instead of diff access
- **WHEN** the extension contributes inline actions for a `gitguardex.session` row
- **THEN** it contributes a `Show Terminal` action for that row
- **AND** it does NOT contribute the old `Open Diff` inline action for that row.

### Requirement: Show Terminal focuses the live session terminal when possible
The VS Code Active Agents companion SHALL reveal the live integrated terminal that owns the selected session whenever the session metadata can be matched to a VS Code terminal process.

#### Scenario: Session `pid` matches an open terminal
- **GIVEN** a session record has a positive integer `pid`
- **AND** VS Code already has an integrated terminal whose `processId` resolves to that same pid
- **WHEN** the operator triggers `Show Terminal`
- **THEN** the extension reveals that existing terminal with focus
- **AND** it does NOT open a replacement terminal for the session.

#### Scenario: No live terminal match exists yet
- **WHEN** the operator triggers `Show Terminal` for a session without a matching live terminal
- **THEN** the extension opens a new integrated terminal rooted at the session worktree
- **AND** it focuses that terminal so the operator lands in the task sandbox immediately.

### Requirement: Stop signals the terminal before falling back to the CLI stopper
The VS Code Active Agents companion SHALL stop live sessions through the matched terminal first so the operator sees and controls the running task directly.

#### Scenario: Stop uses terminal interrupt when a live terminal is known
- **GIVEN** the selected session matches an open integrated terminal by `pid`
- **WHEN** the operator confirms `Stop`
- **THEN** the extension reveals that terminal
- **AND** it sends `Ctrl+C` to that terminal instead of spawning a separate `gx agents stop --pid` process.

#### Scenario: Stop falls back when no terminal can be matched
- **WHEN** the operator confirms `Stop` for a session without a matching live terminal
- **THEN** the extension falls back to `gx agents stop --pid <pid>`
- **AND** it preserves the existing repo-targeted stop behavior for that fallback path.

