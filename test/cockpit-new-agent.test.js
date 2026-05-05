'use strict';

const assert = require('node:assert/strict');
const test = require('node:test');

const { applyCockpitAction, renderControlFrame } = require('../src/cockpit/control');

function snapshot(sessions = []) {
  return { repoPath: '/repo/gitguardex', baseBranch: 'main', sessions };
}

test('typing printable characters in new-agent mode appends to the input buffer', () => {
  let state = applyCockpitAction({}, { type: 'refresh', cockpitState: snapshot() });
  state = applyCockpitAction(state, { type: 'key', key: 'n' });
  assert.equal(state.mode, 'new-agent');
  assert.equal(state.newAgentInput || '', '');

  state = applyCockpitAction(state, { type: 'key', key: 'h' });
  state = applyCockpitAction(state, { type: 'key', key: 'i' });
  state = applyCockpitAction(state, { type: 'key', key: ' ' });
  state = applyCockpitAction(state, { type: 'key', key: '!' });
  assert.equal(state.newAgentInput, 'hi !');
  assert.equal(state.mode, 'new-agent', 'staying in new-agent mode while typing');
});

test('backspace trims the last character of the new-agent input', () => {
  let state = applyCockpitAction({}, { type: 'refresh', cockpitState: snapshot() });
  state = applyCockpitAction(state, { type: 'key', key: 'n' });
  for (const ch of 'abc') {
    state = applyCockpitAction(state, { type: 'key', key: ch });
  }
  assert.equal(state.newAgentInput, 'abc');
  state = applyCockpitAction(state, { type: 'key', key: '' });
  assert.equal(state.newAgentInput, 'ab');
  state = applyCockpitAction(state, { type: 'key', key: '\b' });
  assert.equal(state.newAgentInput, 'a');
});

test('Enter on new-agent emits agent:start with the typed task and clears input', () => {
  let state = applyCockpitAction({}, { type: 'refresh', cockpitState: snapshot() });
  state = applyCockpitAction(state, { type: 'key', key: 'n' });
  for (const ch of 'fix auth') {
    state = applyCockpitAction(state, { type: 'key', key: ch });
  }
  state = applyCockpitAction(state, { type: 'key', key: 'enter' });
  assert.equal(state.mode, 'main');
  assert.equal(state.newAgentInput, '');
  assert.equal(state.lastIntent && state.lastIntent.type, 'agent:start');
  assert.equal(state.lastIntent.task, 'fix auth');
  assert.ok(state.lastIntent.agent);
  assert.ok(state.lastIntent.base);
});

test('Esc on new-agent returns to main without emitting an intent', () => {
  let state = applyCockpitAction({}, { type: 'refresh', cockpitState: snapshot() });
  state = applyCockpitAction(state, { type: 'key', key: 'n' });
  state = applyCockpitAction(state, { type: 'key', key: 'x' });
  state = applyCockpitAction(state, { type: 'key', key: '' });
  assert.equal(state.mode, 'main');
  assert.equal(state.lastIntent, null);
});

test('renderNewAgentPanel renders the prompt box and footer hints', () => {
  const seeded = {
    mode: 'new-agent',
    repoPath: '/repo/gitguardex',
    sessions: [],
    newAgentInput: 'refresh status',
    settings: { defaultAgent: 'codex', defaultBase: 'main' },
  };
  const frame = renderControlFrame(seeded).replace(/\x1b\[[0-9;]*m/g, '');
  assert.match(frame, /\+ New Pane - gitguardex/);
  assert.match(frame, /Project:\s+gitguardex/);
  assert.match(frame, /Agent:\s+codex/);
  assert.match(frame, /Base:\s+main/);
  assert.match(frame, /\| > refresh status_/);
  assert.match(frame, /Enter to submit/);
  assert.match(frame, /Esc to cancel/);
});
