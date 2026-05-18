# /gx-act

Run GitHub Actions workflows locally with [nektos/act](https://github.com/nektos/act) before pushing, so CI failures are caught on the laptop and the PR can be squash-merged on the first remote run.

## Pre-conditions

- Docker (or Podman) is running.
- `act` is installed:

  ```sh
  command -v act || curl -fsSL https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b "$HOME/.local/bin"
  ```

## Default flow

1. Inspect what would run:

   ```sh
   act -l
   ```

2. Execute the push workflows locally:

   ```sh
   act push
   ```

   Or a single job / event:

   ```sh
   act -j <job-name>
   act pull_request
   act workflow_dispatch -W .github/workflows/release.yml
   ```

3. Only after `act` is green, hand off to the finish flow:

   ```sh
   gx branch finish \
     --branch "$(git branch --show-current)" \
     --base main \
     --via-pr \
     --wait-for-merge \
     --cleanup
   ```

4. Squash-merge the PR on GitHub once the remote run mirrors the local one.

## When to use vs the remote run

- `act` is a **fast pre-flight**: catches syntax errors, missing tools, broken matrix configs, obvious test failures.
- It does **not** replace the remote run. GitHub-hosted services, real secrets, and concurrency groups only exist remotely. Treat green `act` as a strong signal, full proof comes from the PR's checks.

## Secrets and env

Never commit secrets. Pass them at invocation time:

```sh
act -s GITHUB_TOKEN="$GITHUB_TOKEN" --env-file .env.act
```

Add `.env.act` to `.gitignore` if you create one.

## Notes

- Pin a runner image close to GitHub's: `act -P ubuntu-latest=catthehacker/ubuntu:act-latest`.
- `act --reuse` keeps containers between runs for faster iteration.
- Store shared flags in `.actrc` at the repo root so every agent uses the same setup.
