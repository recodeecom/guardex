# verifier tasks

## 1. Spec

- [x] Define requirements and scope for verifier
- [x] Confirm acceptance criteria are explicit and testable
  - Verify `test/fuzzing.test.js` keeps the optional `fast-check` path non-fatal.
  - Verify publish/release metadata coverage still passes on the focused publish path.

## 2. Tests

- [x] Define verification approach and evidence requirements
- [x] List concrete commands for verification
  - PASS `node --check test/fuzzing.test.js`
  - PASS `node --test test/fuzzing.test.js`
  - PASS `node --test test/metadata.test.js`
  - PASS `npx --yes eslint --no-config-lookup --rule 'no-undef:error' --rule 'no-unused-vars:error' --parser-options '{"ecmaVersion":"latest"}' --global require --global __dirname --global __filename --global process --global module --global exports test/fuzzing.test.js`
  - PASS `lsp_diagnostics test/fuzzing.test.js` → 0 diagnostics (`tsc` skipped because no `tsconfig.json` exists)
  - FAIL baseline `npm test` → unrelated existing failure in `test/install.test.js` (`withPackageJson is not defined`)

## 3. Implementation

- [x] Execute role-specific deliverables
- [x] Capture decisions, risks, and handoff notes
  - Confirmed the focused fuzzing suite exercises the optional-dependency fallback and unknown-option property checks successfully.
  - Confirmed publish metadata/release workflow assertions still pass in `test/metadata.test.js`.
  - Baseline blocker for full-suite verification is outside this task’s scope: `npm test` currently fails across `test/install.test.js` because `withPackageJson` is undefined before many setup/release cases run.

## 4. Checkpoints

- [x] Publish checkpoint update for this role
