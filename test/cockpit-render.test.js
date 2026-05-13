const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const cp = require('node:child_process');

const { renderCockpit } = require('../src/cockpit/render');
const { readCockpitState } = require('../src/cockpit/state');
const { render } = require('../src/cockpit');
const { buildAgentsStatusPayload } = require('../src/agents/status');
const { createAgentSession } = require('../src/agents/sessions');

function initRepo() {
  const repoPath = fs.mkdtempSync(path.join(os.tmpdir(), 'guardex-cockpit-'));
  cp.execFileSync('git', ['init', '-b', 'main'], { cwd: repoPath, stdio: 'ignore' });
  cp.execFileSync('git', ['config', 'multiagent.baseBranch', 'main'], { cwd: repoPath, stdio: 'ignore' });
  return repoPath;
}

test('renderCockpit returns a readable terminal string', () => {
  const output = renderCockpit({
    repoPath: '/repo/example',
    baseBranch: 'main',
    sessions: [
      {
        agentName: 'codex',
        branch: 'agent/codex/example',
        worktreePath: '/repo/example/.omx/agent-worktrees/example',
        worktreeExists: true,
        status: 'working',
        task: 'implement cockpit',
        lastHeartbeatAt: '2026-04-29T19:00:00.000Z',
        locks: ['src/cockpit/render.js', 'src/cockpit/state.js', 'test/cockpit-render.test.js', 'README.md'],
        metadata: {
          'colony.plan': 'queen-plan',
          'colony.subtask': '1',
        },
      },
    ],
  });

  assert.match(output, /GitGuardex Cockpit/);
  assert.match(output, /repo: \/repo\/example/);
  assert.match(output, /base: main/);
  assert.match(output, /active sessions: 1/);
  assert.match(output, /summary: working=1 thinking=0 blocked=0 done=0 stale=0/);
  assert.match(output, /WORKING NOW \(1\)/);
  assert.match(output, /progress: Spec ok \| Code active \| Tests todo \| PR todo \| Merge todo \| Cleanup todo/);
  assert.match(output, /branch: agent\/codex\/example/);
  assert.match(output, /worktree: \/repo\/example\/\.omx\/agent-worktrees\/example \(present\)/);
  assert.match(output, /locks: 4 \(src\/cockpit\/render\.js, src\/cockpit\/state\.js, test\/cockpit-render\.test\.js, \+1 more\)/);
  assert.match(output, /task: implement cockpit/);
  assert.match(output, /colony: colony\.plan=queen-plan colony\.subtask=1/);
});

test('renderCockpit groups sessions into fleet buckets', () => {
  const output = renderCockpit({
    repoPath: '/repo/example',
    baseBranch: 'main',
    sessions: [
      {
        agentName: 'codex',
        branch: 'agent/codex/working',
        worktreePath: '/repo/example/.omx/agent-worktrees/working',
        worktreeExists: true,
        status: 'working',
        task: 'implement UI',
        changedFiles: ['src/cockpit/render.js'],
      },
      {
        agentName: 'claude',
        branch: 'agent/claude/pending',
        worktreePath: '/repo/example/.omx/agent-worktrees/pending',
        worktreeExists: true,
        status: 'thinking',
        task: 'review spec',
      },
      {
        agentName: 'codex',
        branch: 'agent/codex/blocked',
        worktreePath: '/repo/example/.omx/agent-worktrees/blocked',
        worktreeExists: true,
        status: 'blocked',
        task: 'fix test',
      },
      {
        agentName: 'codex',
        branch: 'agent/codex/merged',
        worktreePath: '/repo/example/.omx/agent-worktrees/merged',
        worktreeExists: true,
        status: 'complete',
        prState: 'MERGED',
        prUrl: 'https://github.com/example/repo/pull/1',
      },
      {
        agentName: 'codex',
        branch: 'agent/codex/stale',
        worktreePath: '/repo/example/.omx/agent-worktrees/stale',
        worktreeExists: false,
        status: 'working',
      },
    ],
  });

  assert.match(output, /summary: working=1 thinking=1 blocked=1 done=1 stale=1/);
  assert.match(output, /WORKING NOW \(1\)/);
  assert.match(output, /THINKING \(1\)/);
  assert.match(output, /BLOCKED \(1\)/);
  assert.match(output, /DONE \(1\)/);
  assert.match(output, /STALE \(1\)/);
  assert.match(output, /codex \| CHANGED \| working/);
  assert.match(output, /codex \| MERGED \| complete/);
  assert.match(output, /codex \| STALE \| working/);
  assert.match(output, /changed: 1 \(src\/cockpit\/render\.js\)/);
  assert.match(output, /detail: selected lane shows branch, progress, claims, changed files, PR, heartbeat, and Colony metadata\./);
});

test('agents status payload and cockpit state see the same session', () => {
  const repoPath = initRepo();
  const worktreePath = path.join(repoPath, '.omx', 'agent-worktrees', 'example');
  fs.mkdirSync(worktreePath, { recursive: true });
  createAgentSession(repoPath, {
    id: 'canonical-cockpit',
    agent: 'codex',
    branch: 'agent/codex/example',
    worktreePath,
    status: 'working',
    task: 'implement cockpit',
    metadata: {
      'colony.plan': 'queen-plan',
      'colony.subtask': '4',
      'colony.task_id': '88',
    },
  });
  fs.mkdirSync(path.join(repoPath, '.omx', 'state'), { recursive: true });
  fs.writeFileSync(
    path.join(repoPath, '.omx', 'state', 'agent-file-locks.json'),
    JSON.stringify({
      locks: {
        'src/cockpit/render.js': { branch: 'agent/codex/example' },
        'src/cockpit/state.js': { branch: 'agent/codex/example' },
        'README.md': { branch: 'agent/other/example' },
      },
    }),
    'utf8',
  );

  const statusPayload = buildAgentsStatusPayload(repoPath);
  const state = readCockpitState(repoPath);

  assert.equal(state.repoPath, repoPath);
  assert.equal(state.baseBranch, 'main');
  assert.deepEqual(state.agentsStatus, statusPayload);
  assert.equal(state.sessions.length, 1);
  assert.equal(state.sessions[0].id, statusPayload.sessions[0].id);
  assert.equal(state.sessions[0].branch, statusPayload.sessions[0].branch);
  assert.equal(state.sessions[0].worktreePath, statusPayload.sessions[0].worktreePath);
  assert.equal(state.sessions[0].status, 'working');
  assert.equal(state.sessions[0].task, 'implement cockpit');
  assert.equal(state.sessions[0].worktreeExists, true);
  assert.equal(state.sessions[0].lockCount, 2);
  assert.deepEqual(state.sessions[0].metadata, {
    'colony.plan': 'queen-plan',
    'colony.subtask': '4',
    'colony.task_id': '88',
  });
});

test('cockpit marks missing worktrees and renders lock count', () => {
  const repoPath = initRepo();
  const missingWorktree = path.join(repoPath, '.omx', 'agent-worktrees', 'missing');
  createAgentSession(repoPath, {
    id: 'missing-cockpit',
    agent: 'codex',
    branch: 'agent/codex/missing',
    worktreePath: missingWorktree,
    status: 'stalled',
    task: 'repair cockpit',
  });
  fs.mkdirSync(path.join(repoPath, '.omx', 'state'), { recursive: true });
  fs.writeFileSync(
    path.join(repoPath, '.omx', 'state', 'agent-file-locks.json'),
    JSON.stringify({
      locks: {
        'src/cockpit/render.js': { branch: 'agent/codex/missing' },
        'src/cockpit/state.js': { branch: 'agent/codex/missing' },
        'README.md': { branch: 'agent/other/example' },
      },
    }),
    'utf8',
  );

  const state = readCockpitState(repoPath);

  assert.equal(state.repoPath, repoPath);
  assert.equal(state.baseBranch, 'main');
  assert.equal(state.sessions.length, 1);
  assert.equal(state.sessions[0].worktreeExists, false);
  assert.equal(state.sessions[0].lockCount, 2);

  const output = renderCockpit(state);
  assert.match(output, new RegExp(`worktree: ${missingWorktree.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')} \\(missing\\)`));
  assert.match(output, /locks: 2/);
});

test('empty cockpit state renders cleanly', () => {
  const repoPath = initRepo();

  const output = render(repoPath);

  assert.equal(typeof output, 'string');
  assert.match(output, /GitGuardex Cockpit/);
  assert.match(output, /active sessions: 0/);
  assert.match(output, /No active agent sessions\./);
});
