# HMLR linked-data applications landing site

This repo provides the landing page experience for visitors to
[landregistry.data.gov.uk](http://landregistry.data.gov.uk). The landing page
provides links to the various open data services, and hosts the Qonsole app,
which allows users to run SPARQL queries against the linked-data dataset.

Please see the other repositories in the [HM Land Registry Open
Data](https://github.com/epimorphics/hmlr-linked-data/) project for more
details.

For more information about this project visit [the
wiki](https://github.com/epimorphics/lr-landing/wiki).

## Contents

- [Tech stack](#tech-stack)
- [Developer setup](#developer-setup)
- [Running locally](#running-locally)
- [Testing](#testing)
- [E2E testing](#e2e-testing)
- [Linting](#linting)
- [Building and publishing](#building-and-publishing)
- [Releases](#releases)
- [Environments](#environments)
- [Observability](#observability)
- [Dependency maintenance](#dependency-maintenance)

## Tech stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8.1, served via Puma |
| Assets | Sprockets asset pipeline + Dart Sass |
| Templates | HAML |
| SPARQL UI | `<epi-qonsole>` web component (`@epimorphics/qonsole` npm package) |
| Logging | Structured JSON via the `epilog_rails` gem |
| Error tracking | Sentry |
| Metrics | Prometheus (`prometheus-client`, `puma-metrics`) |

This is a server-rendered Rails application with no Node.js build tooling — there is
no Vite and no Webpack. Node is present **only** to run Playwright E2E automations;
it plays no part in the application build or asset pipeline.

## Developer setup

### 1. Install Ruby

Use [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com) to install
the version pinned in `.ruby-version` (currently `3.4.12`).

With rbenv:

```bash
rbenv install        # reads .ruby-version automatically
gem install bundler
```

### 2. Authenticate with the private gem registry

The `epilog_rails` and `lr_common_styles` gems are hosted on
the Epimorphics GitHub Package Registry. You need a GitHub Personal Access Token with
the `read:packages` scope.

Configure Bundler with your token:

```bash
./bin/bundle config set --local rubygems.pkg.github.com epimorphics:<your-token>
```

#### GitHub Packages token

The `@epimorphics/qonsole` npm package also comes from GitHub Packages, which needs a
token even for public packages. The same token works. Put it in your user-level Yarn
config (`~/.yarnrc.yml`), never in the repo's `.yarnrc.yml`:

```bash
yarn config set --home npmScopes.epimorphics.npmAuthToken <your-token>
```

Elsewhere:

- **CI** (`.github/actions/setup-node`) sets the same config from the workflow's
  `GITHUB_TOKEN`, which needs `packages: read`.
- **Docker** (`make image`) passes `.github-token` to the build as the secret
  `github_token`; it is never written to an image layer.

### 3. Install dependencies

```bash
./bin/bundle install
yarn install
```

Node (see `.nvmrc`) and Yarn (via `corepack enable`) are needed for the JavaScript
packages the assets are built from, and for the E2E tests.

### 4. Environment variables

`.env.development` contains sensible defaults for local development and is checked
in — no copying required. The app will start without any further configuration.

To override a value, create `.env.local` and set it there. `.env.local` is gitignored.

The app makes no server-side API calls, so it needs no API URL. The qonsole
queries the SPARQL endpoint from the browser.

| Variable | Default | Purpose |
|---|---|---|
| `LOG_LEVEL` | `debug` in development, `info` otherwise | Log level (case-insensitive) |
| `PORT` | `3000` | Rails server port |
| `QONSOLE_ENDPOINT` | dev SPARQL endpoint | Development only: where the qonsole sends queries. Deployed, it is `/landregistry/query` on the same host |
| `SENTRY_ENABLED` | `false` | Enable Sentry error tracking |
| `SENTRY_AUTH_TOKEN` | — | Required only for production builds (source map upload) |
| `SENTRY_API_KEY` | — | Required only if `SENTRY_ENABLED=true` |

## Running locally

```bash
./bin/rails server -p 3000
```

The app is served on port 3000 by default. Assets are compiled on the fly by
Sprockets in development — no separate build step is needed.

## Testing

```bash
./bin/rails test
```

View the coverage report after a test run:

```bash
open coverage/index.html
```

## E2E testing

Playwright is used for end-to-end browser automation. Node is required only for this:
it is not used in the application build.

**Prerequisites:** Node 24 via [nvm](https://github.com/nvm-sh/nvm):

```bash
nvm install   # reads .nvmrc automatically
nvm use
```

**Install dependencies** (yarn uses the `yarnPath` configuration and will resolve from a locally kept version in `.yarn/releases/`, no separate corepack step needed):

```bash
yarn install
```

**Run against the local server** (starts Rails automatically on port 3001):

```bash
yarn test:e2e
```

**Interactive UI mode:**

```bash
yarn test:e2e:ui
```

**Open the last HTML report:**

```bash
yarn test:e2e:report
```

Tests run in Chromium, Firefox and WebKit. To run one browser, add
`--project=chromium` (or `firefox`, `webkit`). If the browsers are not
installed yet, run `yarn playwright install chromium firefox webkit`.

### Running against a deployed environment

Set `E2E_BASE_URL` to any URL from [Environments](#environments). For
pre-production, also pass the Basic Auth [credentials](#credentials):

```bash
E2E_BASE_URL=https://hmlr-preprod-pres.epimorphics.net/ \
E2E_USERNAME=user \
E2E_PASSWORD=secret \
yarn test:e2e
```

### Qonsole regression suite

The `test/playwright/qonsole*.spec.ts` files record how the SPARQL query
console behaves. They were written against the `qonsole_rails` engine and now
check that the `@epimorphics/qonsole` web component that replaced it (#224)
behaves the same:

| Spec | Checks |
|------|--------|
| `qonsole.spec.ts` | Example queries, result formats, prefixes, links from PPD and UKHPI, errors, keyboard use |
| `qonsole-a11y.spec.ts` | axe scan against WCAG 2.2 AA; any violation fails |
| `qonsole-visual.spec.ts` | Screenshot baselines of the HMLR theme (Chromium only), with stubbed query responses |

Anything that depends on how the console is built (shadow DOM, editor API,
the query request URL) is behind the page object in
`test/playwright/support/qonsole-page.ts`.

The queries need a SPARQL endpoint. A local server sends them to the dev
endpoint (see `QONSOLE_ENDPOINT`), so the suite runs against `bin/rails server`
as well as a deployed environment. Its queries are small enough for dev:

```bash
yarn test:e2e test/playwright/qonsole
E2E_BASE_URL=https://hmlr-dev-pres.epimorphics.net/ yarn test:e2e test/playwright/qonsole
```

When the console's appearance changes on purpose, review the screenshot diffs
in the HTML report, then update the baselines:

```bash
yarn test:e2e test/playwright/qonsole-visual.spec.ts --update-snapshots
```

### In CI

The **E2E Tests** workflow (`.github/workflows/e2e.yml`) is manual only: run it
from **Actions > E2E Tests > Run workflow**. It always targets pre-production.
The dev hosts are too small to complete some of the large queries the suite
makes, so runs against dev fail for reasons unrelated to the code.

## Linting

```bash
./bin/bundle exec rubocop -a    # Ruby — auto-corrects safe offences
```

## Building and publishing

> [!WARNING]
> Do not trigger deployments concurrently. ukhpi, ppd-explorer,
> standard-reports-ui and lr-landing all deploy to the same hosts with the
> same Ansible playbook, and nothing stops two deploys from overlapping. Before
> pushing to `dev`, `preprod` or `prod`, check the Actions tab of all four
> repositories and wait for any deploy in progress to finish.

The `Makefile` is scoped to the Docker image build and publish pipeline.

```bash
make image     # Build the Docker image (requires GitHub token configured)
make publish   # Push to AWS ECR
make vars      # Print all build variables
make tag       # Print the computed image tag
make version   # Print the application version
```

Variables can be overridden on the command line, e.g.:

```bash
STAGE=preprod make publish
```

Branch-to-environment mapping is defined in `deployment.yaml`. CI runs
`publish` and `deploy` automatically on push via
`.github/workflows/publish-deploy.yml`.

## Releases

Releases follow the [Frontend Release Process](https://github.com/epimorphics/internal/wiki/Release-Process-Frontend).

The canonical version file is `app/lib/version.rb`. The changelog is maintained in `CHANGELOG.md`.

Environment branches are kept as strict fast-forward pointers to tagged commits on `dev`. URLs for each environment are listed under [Environments](#environments).

## Environments

### Container configuration

Deployed containers are configured by Ops in `hmlr-ansible-deployment`
(`ansible/roles/landing`), not in this repository. The image reads:

| Variable | Default | Purpose |
|---|---|---|
| `LOG_LEVEL` | `info` | Log level. Deployments set `DEBUG` on dev and `INFO` elsewhere |
| `SENTRY_LOG_LEVEL` | `warn` | Level of the Sentry SDK's own diagnostics, separate from `LOG_LEVEL` |
| `RAILS_MAX_THREADS` | `5` | Puma threads per process, maximum. Deployments set `16` |
| `RAILS_MIN_THREADS` | `RAILS_MAX_THREADS` | Puma threads per process, minimum. Deployments set `4` |
| `WEB_CONCURRENCY` | none (single process) | Puma worker processes, read by Puma itself. Deployments set `3` |
| `GOOGLE_ANALYTICS_ID` | a legacy Universal Analytics ID | Read by `lr_common_styles`, used once a visitor accepts analytics cookies |
| `SECRET_KEY_BASE` | generated at start-up | Generated by the entrypoint if unset; sessions don't survive a restart then |
| `RAILS_RELATIVE_URL_ROOT` | `/` | Path the app is served under. Also a build argument, since compiled asset paths depend on it |
| `METRICS_PORT` | `9393` | Puma metrics server port. Only honoured in development for now; deployed, the port is always 9393 |
| `RAILS_ENV` | `production` | Set by the entrypoint |
| Sentry variables | | See [Environment variables](#4-environment-variables) |


| Branch | Environment | URL | Basic Auth |
|--------|-------------|-----|------------|
| `dev` | Dev | https://hmlr-dev-pres.epimorphics.net/ | No |
| `preprod` | Pre-production | https://hmlr-preprod-pres.epimorphics.net/ | Yes |
| `prod` | Production | https://landregistry.data.gov.uk/ | No |

Pushing to an environment branch builds, publishes and deploys to that
environment (see [Building and publishing](#building-and-publishing)).

### Credentials

Pre-production is protected by HTTP Basic Auth. The credentials are not stored
in this repository: ask Ops for them. The E2E workflow reads the same
credentials from the `E2E_USERNAME` and `E2E_PASSWORD` repository secrets.

## Observability

Metrics for the presentation hosts of all HMLR apps are in
[Grafana](https://grafana-hmlr.epimorphics.net/). Use it to see how each
environment has behaved over time and to line up a problem with when it
started. Ask Ops for access.

### Logging

Logs are single-line JSON on stdout, formatted by
[`epilog_rails`](https://github.com/epimorphics/epilog-rails) to the
[logging standard](https://github.com/epimorphics/internal/wiki/Logging-Standard).
The gem logs every request itself, so controllers must not: each request
produces one `received` entry and one `completed` entry (or `error` for a 5xx),
sharing a `request_id` and carrying `method`, `path`, `status` and
`request_time` in seconds.

To log something else, pass `Rails.logger` a string or a Hash with a `message`
key. Never pass it `JSON.generate(...)` or `to_json`: the formatter encodes the
entry, so pre-encoded text ends up as JSON inside the `message` string.

`LOG_LEVEL` sets the level (`debug` in development, `info` otherwise). Sentry's
own diagnostics have a separate level, `SENTRY_LOG_LEVEL` (default `warn`), so
turning on debug logging doesn't fill the log with them.

In the test environment logs go to `log/test.log`, not stdout.

### Metrics

`/metrics` is served by the Prometheus middleware. Alert rules are kept by Ops, not
in this repository, so a change to a metric's name or labels must be agreed with
them for the same deploy.

Label values are bounded: they never contain an exception's own message, which can
carry user input or a URL and would create a new time series per value.

| Metric | Labels | Measures |
|---|---|---|
| `internal_application_error` | `message`: `<exception class> in <controller>#<action>`, e.g. `RuntimeError in landing#index` | Responses with status 500 |
| `memory_used_mb` | none | Process memory, sampled after each request |
| `process_threads` | `status`: `run`, `sleep`, `aborting`, `false` or `nil` | Threads in each state, sampled after each request |

`internal_application_error` is recorded by `ApplicationPrometheusSubscriber`
from the `internal_error.application` event that `ErrorsController` sends. The
gauges are set by `ActionDispatchPrometheusSubscriber`. Request counts and
durations by status are the Prometheus client's own `http_server_*` metrics.

## Dependency maintenance

```bash
./bin/bundle update --patch              # Update all gems to latest patch version
./bin/bundle outdated --only-explicit    # Check for outdated gems
```
