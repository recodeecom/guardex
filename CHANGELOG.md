# Changelog

## [8.0.0](https://github.com/recodeee/gitguardex/compare/v7.0.43...v8.0.0) (2026-05-18)


### ⚠ BREAKING CHANGES

* consolidate CLI surface + trim agent-session templates (v7.0.0) ([#146](https://github.com/recodeee/gitguardex/issues/146))
* drop musafety codename; GUARDEX_* / guardex CLI only (v6.0.0) ([#138](https://github.com/recodeee/gitguardex/issues/138))

### Features

* **agents:** cap CARGO_BUILD_JOBS in agent launch env ([#601](https://github.com/recodeee/gitguardex/issues/601)) ([b8ec4ff](https://github.com/recodeee/gitguardex/commit/b8ec4ffb00e7eee9138d83bf1f417f57e7f54c2b))
* **branch-finish:** pre-flight gate + auto-promote drafts after pass ([#572](https://github.com/recodeee/gitguardex/issues/572)) ([1f11a7c](https://github.com/recodeee/gitguardex/commit/1f11a7c9cf3dd55e993fbf2453bb15984e1bb67f))
* **claude+pr:** first-class Claude Code integration and gx pr command suite ([#600](https://github.com/recodeee/gitguardex/issues/600)) ([b61d65b](https://github.com/recodeee/gitguardex/commit/b61d65b52fe8eaacffa385ea7a48ed112270d0a4))
* **claude:** add gx pivot/ship + widen hook whitelist for safe sync ops ([#431](https://github.com/recodeee/gitguardex/issues/431)) ([f0122ee](https://github.com/recodeee/gitguardex/commit/f0122eee6a8220c9dc868f7fc0488ab352d96255))
* **cli:** gx budget — Actions usage + paid-spend thresholds ([#574](https://github.com/recodeee/gitguardex/issues/574)) ([8b50cc2](https://github.com/recodeee/gitguardex/commit/8b50cc2e31b237d4a0531b23a0c2ab44518da68f))
* **cli:** gx ci-init — scaffold budget-friendly workflows into a repo ([#575](https://github.com/recodeee/gitguardex/issues/575)) ([795af11](https://github.com/recodeee/gitguardex/commit/795af11b9ede78e2077d0717463c1faf05ad2f74))
* consolidate CLI surface + trim agent-session templates (v7.0.0) ([#146](https://github.com/recodeee/gitguardex/issues/146)) ([d00e448](https://github.com/recodeee/gitguardex/commit/d00e44837778be78f05d15823d073caf369dd732))
* **doctor,setup:** auto-prune stale agent worktrees ([#432](https://github.com/recodeee/gitguardex/issues/432)) ([3ad44d6](https://github.com/recodeee/gitguardex/commit/3ad44d6b3712acf36e4d1fd2103cf8a1ac74774d))
* drop musafety codename; GUARDEX_* / guardex CLI only (v6.0.0) ([#138](https://github.com/recodeee/gitguardex/issues/138)) ([a91058d](https://github.com/recodeee/gitguardex/commit/a91058d80227762196f91bd4d70e234a0640dcd2))
* **frontend:** add Installation mode, Claude parallel lane, copyable install pill ([#167](https://github.com/recodeee/gitguardex/issues/167)) ([3dde48a](https://github.com/recodeee/gitguardex/commit/3dde48a0009b3cfb8ac88bec18bab2adc3b2ae16))
* **frontend:** GuardeX brand block, shell-row copy buttons, realistic gx doctor output ([#168](https://github.com/recodeee/gitguardex/issues/168)) ([0732226](https://github.com/recodeee/gitguardex/commit/073222652bb15ff976b3c9f7475083c99e76a5b4))
* **gx:** add `--advance-submodules` flag to `gx branch finish` ([#559](https://github.com/recodeee/gitguardex/issues/559)) ([4fca9c5](https://github.com/recodeee/gitguardex/commit/4fca9c5d772f699b8f17333b2c7e83906654d9bc))
* **gx:** add `gx submodule advance` verb for monorepo pointer bumps ([#558](https://github.com/recodeee/gitguardex/issues/558)) ([f6e3742](https://github.com/recodeee/gitguardex/commit/f6e374280c2c44734859450428b242e2dc5a672d))
* **gx:** auto-sync submodule working dirs on `gx setup` for monorepo shops ([#557](https://github.com/recodeee/gitguardex/issues/557)) ([835d155](https://github.com/recodeee/gitguardex/commit/835d15548e9e04f01f19f8c4421f4ffc04c86403))
* **hooks:** let humans commit/push to main; block only agents ([#157](https://github.com/recodeee/gitguardex/issues/157)) ([2b76911](https://github.com/recodeee/gitguardex/commit/2b76911ef1b4ef28fa833d806a38c901638b6084))
* **scripts:** install-global-hooks.sh — opt-in global core.hooksPath ([#603](https://github.com/recodeee/gitguardex/issues/603)) ([d60fafa](https://github.com/recodeee/gitguardex/commit/d60fafa1241f7039c637b8df0a3a5e45c221e38d))
* **setup:** monorepo-aware recursive install for gx setup (v7) ([#147](https://github.com/recodeee/gitguardex/issues/147)) ([7044bc4](https://github.com/recodeee/gitguardex/commit/7044bc49759e91e1c74dc5a7ff01535a75b3cf17))
* **setup:** offer VS Code extension install during gx setup ([#416](https://github.com/recodeee/gitguardex/issues/416)) ([0e9131b](https://github.com/recodeee/gitguardex/commit/0e9131bc446419bc0b3a63e08361b4521fca3b8a))
* **skills:** add gx-act for running GitHub Actions locally with nektos/act ([#602](https://github.com/recodeee/gitguardex/issues/602)) ([14d398c](https://github.com/recodeee/gitguardex/commit/14d398c278bbbf4a1d04a8eefc92cf90b9fc6e39))
* **speckit:** add `gx speckit` subcommand to install Spec Kit + prune scaffold ([#588](https://github.com/recodeee/gitguardex/issues/588)) ([ed921e6](https://github.com/recodeee/gitguardex/commit/ed921e667e384d8c51294fef75f7d23bca228e72))
* **speckit:** run speckit install as part of `gx setup` by default ([#589](https://github.com/recodeee/gitguardex/issues/589)) ([a588011](https://github.com/recodeee/gitguardex/commit/a588011e6deb71c4eefe7aac9a9ea43cb98bf8b0))
* **status:** gx status checks oh-my-claude; setup gitignores .omc/ ([#163](https://github.com/recodeee/gitguardex/issues/163)) ([5c74a83](https://github.com/recodeee/gitguardex/commit/5c74a838162932e16abb0db6519fe1fab5ea7716))
* **vscode-active-agents:** distinct icons per tree section ([#402](https://github.com/recodeee/gitguardex/issues/402)) ([c4e79af](https://github.com/recodeee/gitguardex/commit/c4e79afb07a0534f8700cbe4f46e2303c11457ac))
* **vscode-active-agents:** refine file-icon SVGs ([#403](https://github.com/recodeee/gitguardex/issues/403)) ([082449f](https://github.com/recodeee/gitguardex/commit/082449fb65d5bd22de10ceedf189cdcaebae93e3))
* **vscode-active-agents:** surface colony task counts and details ([#422](https://github.com/recodeee/gitguardex/issues/422)) ([43aecbe](https://github.com/recodeee/gitguardex/commit/43aecbe78c6e0e5b4cfce56b976131825ce4d91f))
* **worktree:** prefix worktree leaves with repo basename instead of literal 'agent' ([#406](https://github.com/recodeee/gitguardex/issues/406)) ([91ef8a0](https://github.com/recodeee/gitguardex/commit/91ef8a0e51fdd7521bbf91e86171dca1376d2797))


### Bug Fixes

* **agent-branch-start:** verify worktree exists before printing Ready: ([#577](https://github.com/recodeee/gitguardex/issues/577)) ([7f4d43d](https://github.com/recodeee/gitguardex/commit/7f4d43d688b52288ad7b92aad5f63e0bbfb35923))
* **agent-flow:** auto-allow staged deletions + surface gh pr create failures ([#565](https://github.com/recodeee/gitguardex/issues/565)) ([1a39ebe](https://github.com/recodeee/gitguardex/commit/1a39ebe13ffb75002743794f21ca235759df9adb))
* **agent-worktree-prune:** skip worktrees with live processes ([#570](https://github.com/recodeee/gitguardex/issues/570)) ([e1f95b9](https://github.com/recodeee/gitguardex/commit/e1f95b93606d386eb7e49a3fb593e6dc7b0ccc3f))
* **branch-finish:** rephrase pending-PR cleanup message so claude doesn't claim the worktree is on disk ([#445](https://github.com/recodeee/gitguardex/issues/445)) ([029daa5](https://github.com/recodeee/gitguardex/commit/029daa5646e824c586fafbe74312d8abdb1d15c0))
* **e2e:** export GUARDEX_CLI_ENTRY/GUARDEX_NODE_BIN to gx shims ([#595](https://github.com/recodeee/gitguardex/issues/595)) ([ff93bec](https://github.com/recodeee/gitguardex/commit/ff93bec097040be648e0b95dabe88e3cde695e8c))
* **e2e:** export GUARDEX_CLI_ENTRY/HOME/NODE_BIN to every subprocess ([#596](https://github.com/recodeee/gitguardex/issues/596)) ([27cdfaa](https://github.com/recodeee/gitguardex/commit/27cdfaabe9a7c1bef7d7d2338276890b9361ea9c))
* **guardex:** auto-stash dirty primary on branch-switch ([#417](https://github.com/recodeee/gitguardex/issues/417)) ([56f2675](https://github.com/recodeee/gitguardex/commit/56f2675a7b7fca4eaea0a0adaf16fa661ead5671))
* **gx:** deploy PR [#546](https://github.com/recodeee/gitguardex/issues/546) fix to runtime via templates/scripts/ + add --auto-resolve=full submodule pointer resolver ([#547](https://github.com/recodeee/gitguardex/issues/547)) ([f1cc0ea](https://github.com/recodeee/gitguardex/commit/f1cc0eaa16041ab1416e124270126a5d5a162edd))
* **gx:** enforce symlink parity pre-commit + document scripts layout convention ([#553](https://github.com/recodeee/gitguardex/issues/553)) ([74e4489](https://github.com/recodeee/gitguardex/commit/74e4489f8bc59c6cad865d8ba8d8c8182217d642))
* **gx:** make OpenSpec scaffolding on-by-default and stop the silent-failure log ([#549](https://github.com/recodeee/gitguardex/issues/549)) ([89e6c49](https://github.com/recodeee/gitguardex/commit/89e6c49e7962e76ad62d6693c0a8ff2492716129))
* **gx:** rename colony package from @imdeadpool/colony-cli to colonyq ([#555](https://github.com/recodeee/gitguardex/issues/555)) ([8095f4f](https://github.com/recodeee/gitguardex/commit/8095f4fca7d797172fe84823054c5dd5aa2a55c8))
* **gx:** stop branch-start from leaking state files into agent branches; add opt-in safe conflict resolver to finish ([#546](https://github.com/recodeee/gitguardex/issues/546)) ([896cabf](https://github.com/recodeee/gitguardex/commit/896cabf870b280f3960bb81a11927e23b4e7cb31))
* **gx:** teach gx cleanup the state-file allowlist + log why a dirty worktree was kept ([#550](https://github.com/recodeee/gitguardex/issues/550)) ([786cb46](https://github.com/recodeee/gitguardex/commit/786cb464739a43ab50378e9422ad75d1a0eec5fc))
* **hooks:** restore scripts/agent-stalled-report.sh referenced by SessionStart ([#599](https://github.com/recodeee/gitguardex/issues/599)) ([e1278e0](https://github.com/recodeee/gitguardex/commit/e1278e07c9e1af242fe90299ead44150ad9e50b7))
* **release:** restore a clean npm deployment path ([#195](https://github.com/recodeee/gitguardex/issues/195)) ([3faedee](https://github.com/recodeee/gitguardex/commit/3faedee7d99481c2e0c902fb2977d1e427ec07a3))
* **self-update:** verify on-disk version after [@latest](https://github.com/latest) install, retry pinned when stale ([#165](https://github.com/recodeee/gitguardex/issues/165)) ([dff1588](https://github.com/recodeee/gitguardex/commit/dff1588b4eb09a01fc5d2fbb18193bb03444c939))
* **update:** hand off to the installed CLI after self-update ([#202](https://github.com/recodeee/gitguardex/issues/202)) ([b21e4b8](https://github.com/recodeee/gitguardex/commit/b21e4b85d7bf27f8cd55eb6f03a73b2f7e15bc7d))
* **vscode-active-agents:** correct publisher id to Recodee ([#414](https://github.com/recodeee/gitguardex/issues/414)) ([0f246d1](https://github.com/recodeee/gitguardex/commit/0f246d1d032651ce3627eb04f6fead5675ea69a0))
* **vscode-active-agents:** use SCM Providers category ([#415](https://github.com/recodeee/gitguardex/issues/415)) ([1027a0d](https://github.com/recodeee/gitguardex/commit/1027a0dc3e8cf96bed859291734b8c5eca35e37f))


### Performance

* **context:** memoize idempotent git/gh probes within process ([#586](https://github.com/recodeee/gitguardex/issues/586)) ([bb616db](https://github.com/recodeee/gitguardex/commit/bb616db408a466308a65c3c22ad7b4b195ce20e1))
* **output:** default to terse output when stdout is non-TTY ([#585](https://github.com/recodeee/gitguardex/issues/585)) ([2e4b75e](https://github.com/recodeee/gitguardex/commit/2e4b75ecb5dcb65ef892c312650d671708ce1444))
