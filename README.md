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
- [Data API](#data-api)
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
| SPARQL UI | Qonsole (`qonsole_rails` gem) |
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

The `json_rails_logger`, `lr_common_styles`, and `qonsole_rails` gems are hosted on
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

| Variable | Default | Purpose |
|---|---|---|
| `API_SERVICE_URL` | `http://localhost:8888` | Backing SPARQL/data API |
| `PORT` | `3000` | Rails server port |
| `QONSOLE_ENDPOINT` | dev SPARQL endpoint | Where the qonsole sends queries in development; deployed, it is `/landregistry/query` on the same host |
| `SENTRY_ENABLED` | `false` | Enable Sentry error tracking |
| `SENTRY_AUTH_TOKEN` | — | Required only for production builds (source map upload) |
| `SENTRY_API_KEY` | — | Required only if `SENTRY_ENABLED=true` |

## Data API

The app queries a backing data API at `API_SERVICE_URL` (default
`http://localhost:8888`). To run it locally, install Maven and follow the
instructions in the
[lr-data-api](https://github.com/epimorphics/lr-data-api) repository, ensuring
it listens on port `8888`.

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
console behaves, so that the `qonsole_rails` engine can be replaced by the
`@epimorphics/qonsole` web component (#224) without regressions:

| Spec | Checks |
|------|--------|
| `qonsole.spec.ts` | Example queries, result formats, prefixes, links from PPD and UKHPI, errors, keyboard use |
| `qonsole-a11y.spec.ts` | axe scan against WCAG 2.2 AA; today's known violations are listed in `KNOWN_VIOLATIONS` |
| `qonsole-visual.spec.ts` | Screenshot baselines (Chromium only), the visual target for the replacement's theme |

Anything that depends on how the console is built (editor API, dropdown
markup, the query request URL) is behind the page object in
`test/playwright/support/`, with one implementation per console:
`qonsole-engine.ts` (the default) and `qonsole-component.ts`.

The queries need a real SPARQL endpoint, which a local server does not have, so
run the suite against a deployed environment. Its queries are small enough for
dev:

```bash
E2E_BASE_URL=https://hmlr-dev-pres.epimorphics.net/ yarn test:e2e test/playwright/qonsole
```

When the console's appearance changes on purpose, review the screenshot diffs
in the HTML report, then update the baselines:

```bash
E2E_BASE_URL=https://hmlr-dev-pres.epimorphics.net/ yarn test:e2e test/playwright/qonsole-visual.spec.ts --update-snapshots
```

#### Against the web component

To check the `<epi-qonsole>` web component before it is installed here, set
`QONSOLE_IMPL=component`. The test harness loads the deployed `/qonsole` page,
replaces the engine inside `<main>` with `<epi-qonsole>` configured from
`config/qonsole.json`, and serves a local build of the component. It expects
a build in a checkout of
[epimorphics/qonsole](https://github.com/epimorphics/qonsole) next to this
repo; set `QONSOLE_COMPONENT_JS` to use a different bundle:

```bash
(cd ../qonsole/packages/qonsole-wc && yarn build)
QONSOLE_IMPL=component E2E_BASE_URL=https://hmlr-dev-pres.epimorphics.net/ yarn test:e2e test/playwright/qonsole
```

Failures here are the gaps the component must close before it replaces the
engine. The screenshot baselines are the engine's, so expect those to fail
until the component is themed; don't update them from a component run.

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

## Dependency maintenance

```bash
./bin/bundle update --patch              # Update all gems to latest patch version
./bin/bundle outdated --only-explicit    # Check for outdated gems
```
