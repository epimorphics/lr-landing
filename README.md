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
- [E2E Testing](#e2e-testing)
- [Building and publishing](#building-and-publishing)
- [Releases](#releases)
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
the version pinned in `.ruby-version` (currently `3.4.9`).

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

### 3. Install dependencies

```bash
./bin/bundle install
```

No Node or Yarn installation is required.

### 4. Environment variables

`.env.development` contains sensible defaults for local development and is checked
in — no copying required. The app will start without any further configuration.

To override a value, create `.env.local` and set it there. `.env.local` is gitignored.

| Variable | Default | Purpose |
|---|---|---|
| `API_SERVICE_URL` | `http://localhost:8888` | Backing SPARQL/data API |
| `PORT` | `3000` | Rails server port |
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

Playwright is used for end-to-end browser automation. Node is required only for this
— it is not used in the application build.

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

**Run against a remote environment:**

```bash
E2E_BASE_URL=https://staging.example.com yarn test:e2e
```

Optional HTTP basic auth for protected environments:

```bash
E2E_BASE_URL=https://staging.example.com \
E2E_USERNAME=user \
E2E_PASSWORD=secret \
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

The CI workflow (`.github/workflows/e2e.yml`) is `workflow_dispatch` only — it does
not run automatically on push. Trigger it manually from the Actions tab, supplying the
target URL.

## Linting

```bash
./bin/bundle exec rubocop -a    # Ruby — auto-corrects safe offences
```

## Building and publishing

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

Branch-to-environment mapping is defined in `deployment.yaml`. CI runs `publish` and
`deploy` automatically on push via `.github/workflows/publish-deploy.yml`.

## Releases

Releases follow the [Frontend Release Process](https://github.com/epimorphics/internal/wiki/Release-Process-Frontend).

| Branch | Environment | URL |
|--------|-------------|-----|
| `dev` | Dev | https://hmlr-dev-pres.epimorphics.net/ |
| `preprod` | Pre-production | https://hmlr-preprod-pres.epimorphics.net/ |
| `prod` | Production | https://landregistry.data.gov.uk/ |

The canonical version file is `app/lib/version.rb`. The changelog is maintained in `CHANGELOG.md`.

Environment branches are kept as strict fast-forward pointers to tagged commits on `dev`. Branch-to-environment mapping is also declared in `deployment.yaml`.

## Dependency maintenance

```bash
./bin/bundle update --patch              # Update all gems to latest patch version
./bin/bundle outdated --only-explicit    # Check for outdated gems
```
