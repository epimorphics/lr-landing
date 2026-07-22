# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Converted fixed-`px` font sizes on the landing page's body text and
  headings to `rem`, so text can be resized to 200% via browser/OS text-size
  settings.
  [#232](https://github.com/epimorphics/lr-landing/issues/232)
- Made scrollable `pre` blocks keyboard-focusable and corrected heading
  hierarchy on the doc pages.
  [#230](https://github.com/epimorphics/lr-landing/issues/230)

## [2.3.3] - 2026-05

### Added

- Added automated Playwright end-to-end test suite covering existing QA spec scenarios.
  [#225](https://github.com/epimorphics/lr-landing/pull/225)
- Added GitHub issue templates and a verify workflow; restricted CI triggers to
  relevant branches and paths.

### Changed

- Improved README with tech stack overview and developer setup instructions.
- Removed hard-coded references to the yarn version from documentation.
- Set test server to use the same port documented in the README.
- Pinned gem versions and removed unused dependencies.
- Updated dependencies by minor version; updated bundler and alpine versions.
- Removed githooks in favour of CI-based checks.

### Fixed

- Fixed rubocop violations and configured rubocop to ignore vendor code.


## [2.3.2] - 2026-04

- Upgraded ruby to `3.4.9` [#214](https://github.com/epimorphics/lr-landing/issues/214)
- Updated guidance notes for PPD [#317](https://github.com/epimorphics/ppd-explorer/issues/317)

## [2.3.1] - 2026-02

### Added

- Added test coverage reporting with SimpleCov and a `coverage` Makefile target.
  [#207](https://github.com/epimorphics/lr-landing/issues/207)

### Changed

- Upgraded 'qonsole-rails' gem to include latest accessibility updates
  [v2.4.2](https://github.com/epimorphics/qonsole-rails/releases/tag/2.4.2)
- Upgraded `rubocop` and updated linting configuration.
  [#208](https://github.com/epimorphics/lr-landing/issues/208)
- Bumped development tooling: `byebug`, `solargraph`, and `ruby-lsp`.
  [#208](https://github.com/epimorphics/lr-landing/issues/208)
- Bumped runtime libraries including `jquery-rails`, `puma`, and Rails for
  compatibility and stability.
  [#201](https://github.com/epimorphics/lr-landing/issues/201)
- Refactored Sentry initialisation and updated logger configuration.
- Unified Makefile targets and modernised build behaviour.
- Updated asset pipeline precompile messaging.
- Reconciled divergent branches and consolidated dependency updates.
  [#206](https://github.com/epimorphics/lr-landing/issues/206)

### Fixed

- Handled non-zero exit codes from `bundle outdated` during dependency checks.
- Updated git hooks to improve pre-commit / pre-push workflow.
- Corrected exception message wording and improved error logging.
- Fixed hooks API SERVICE URL default value.

### Security

- Updated several third-party libraries to address security and compatibility
  issues.

## [2.3.0] - 2026-01

### Changed

- Migrated from deprecated `sass-rails` gem to `dartsass-sprockets` (Dart Sass)
  for long-term CSS compilation support
  [#158](https://github.com/epimorphics/lr-landing/issues/158)
- Removed `bootstrap-sass` in favour of Bootstrap framework dependencies for
  enhanced styling capabilities and maintainability
- Updated asset pipeline configuration and loading order for improved
  performance
- Enabled Autoprefixer source maps for better CSS debugging in development
- Streamlined Rails framework loading configuration
- Updated Sass configuration for compatibility with new build toolchain

## [2.2.4] - 2025-11

### Added

- Benchmarking and profiling tools were added for performance analysis
- System tools for resource introspection were added
- Hooks and helpers for internal resource usage logging were added

### Changed

- Core and third-party libraries were upgraded to latest versions for security
  and stability
- Dependency constraints were updated and bundled dependencies were bumped
- Logging configuration in development environment was standardised and tidied
- Exception rescue paths were updated to clarify outcomes
- Error handling and resource logging were improved

### Removed

- Removed deprecated `to_time_preserves_timezone` configuration for Rails 8.1+
  compatibility

### Fixed

- Missing status in metrics subscriber was handled to prevent exceptions during
  metrics emission

## [2.2.3] - 2025-09

### Changed

- Updated accessibility statements in English and Welsh
  [#180](https://github.com/epimorphics/lr-landing/issues/180)

## [2.2.2] - 2025-09

### Changed

- Updated to use latest Qonsole-rails gem, v2.2.1, to resolve JSON response
  issue [#85](https://github.com/epimorphics/qonsole-rails/issues/85)

## [2.2.1] - 2025-08

### Added

- Added logic to bypass pre-push checks when only markdown files are staged

### Changed

- Updated LR Common Styles gem to continue to address security issues

### Fixed

- Resolved incorrect link to PPD Detailed Documentation

## [2.2.0] - 2025-08

### Changed

- Bumped rails and all related gems to version 8.0.2.1
- Upgraded rubocop and rubocop-rails to latest 1.x and 2.x releases
- Updated rack to 3.2.0
- Bumped puma, jbuilder, json, parser, regexp_parser, unicode-display_width, and
  other gems for security and compatibility
- Synchronised dependency constraints across related gems

## [2.1.3] - 2025-07

### Changed

- Updated `qonsole_rails` version to include latest improvements
- Upgraded dependency management to improve project stability
- Enhanced Docker handling in scripts with refined command order
- Optimised makefile by removing redundant elements

### Added

- Introduced documentation for git hooks to streamline onboarding

## [2.1.2] - 2025-07

### Changed

- Updated various gems to new versions, including `qonsole_rails`,
  `lr_common_styles`, and `reline`
- Notable updates include major upgrades in `faraday`, `rubocop`, `nokogiri`,
  and dependencies such as `sentry-rails` and `thor`
- Modified `.rubocop.yml` to adjust the plugin configuration syntax
- Refactored integration tests to include language parameters in request methods

## [2.1.1] - 2025-06

### Added

- Introduced a helper module to dynamically display the current environment in
  the UI, defaulting to "development" when not set

### Changed

- Optimised Docker configuration by refactoring the Dockerfile for build
  efficiency, setting default environment variables, and refining network
  settings
- Enhanced logging by adding checks for environment variables and better logging
  output for operational clarity
- Updated dependencies to ensure compatibility and performance

## [2.1.0] - 2025-05

### Added

- Added structured JSON logging for improved observability
- Updated git hooks to ensure tests pass before commits and pushes

### Changed

- Refactored code and updated Rubocop configuration for better code quality and
  consistency
- Updated Rails to v8.0.2 alongside respective dependencies

## [2.0.6] - 2025-04

### Changed

- Updated the `Uglifier` gem to `Terser` to allow ES6 syntax in the codebase
- Modified `.githooks/pre-commit` and `.githooks/pre-push` to prevent checks on
  'hotfix', 'rebase', or 'production' branches
- Updated Gemfile and Gemfile.lock to new gem versions
- Modified the Makefile to use the `AWS_REGION` variable when constructing the
  ECR repository URL, making it region-aware
- Updated the `.gitignore` file to ignore `.env` and `.env*.local` files,
  excluding `.env.development`

### Added

- Created `.env.development` to define configurations such as API URL, port, and
  Sentry settings for the development environment
- Introduced a `.githooks/post-commit` script that builds a Docker image after a
  successful commit. The script only triggers for branches that match "issue",
  "spike", or "task"
- Created a `Procfile.dev` to allow for local development with foreman or
  similar tools to start both the web and api processes

## [2.0.5] - 2025-03

### Added

- Added pre-commit and pre-push hooks

### Changed

- Improved error handling in application controller
- Updated locale handling in application controller
- Improved Sentry configuration for different environments

## [2.0.4] - 2025-02

### Added

- Included `puma-metrics` gem for better monitoring as now using Rails 6 or
  greater
- Updated Gemfile and Gemfile.lock to reflect the addition
- Set up a configurable metrics port with a default value

### Changed

- Updated log level configuration across environments
  [#63](https://github.com/epimorphics/lr-landing/issues/63)
- Changed the way boot information is printed
- Switched to JSON format for better compatibility with logging services
- Refactored method to improve clarity and structure
- Made the version string immutable by freezing it
- Updated several gems to their latest versions
- Cleaned up commented-out paths in the Gemfile
- Updated the binding URL for the metrics server in development
- Removed old git reference for the qonsole_rails gem
- Added the qonsole_rails gem to the source block instead

## [2.0.3] - 2025-01

### Changed

- Improved error metrics reporting to ensure that logging always happens with
  the appropriate severity depending on the exception status while reducing the
  types of errors that can trigger an error metric and therefore a notification
  in slack [#149](https://github.com/epimorphics/hmlr-linked-data/issues/149)

## [2.0.2] - 2024-12

### Changed

- Updated all gems, including `json_rails_logger`

## [2.0.1] - 2024-10

### Fixed

- Fixed an issue with CSS for the checkboxes in the Qonsole query form

## [2.0.0] - 2024-10

### Changed

- Upgraded the `qonsole-rails` and `lr_common_styles` gems to latest versions
  (which are now running on ruby `3.3.5` and rails `7.2.2` as well)
- Upgraded alpine to `3.20`
- Upgraded rails to `7.2.2`
- Upgraded ruby to `3.3.5`

### Removed

- Removed the public/fees-caluclator.html file as it is no longer needed
  [#140](https://github.com/epimorphics/lr-landing/issues/140)

---

## 1.8.0 - 2024-09

- (Jon) Create a `config/initializers/load_notification_subscribers.rb` file to
  load all the notification subscribers in the application so that they are
  registeredly correctly
  [GH-135](https://github.com/epimorphics/lr-landing/issues/135)
- (Jon) Updated the application exceptions controller to instrument the
  `ActiveSupport::Notifications` for internal errors
  [GH-135](https://github.com/epimorphics/lr-landing/issues/135)
- (Jon) Updated `config/initializers/prometheus.rb` to include the `Middleware
  instrumentation` fix for the 0 memory bug by notifying Action Dispatch
  subscribers on Prometheus initialise
  [GH-135](https://github.com/epimorphics/lr-landing/issues/135)
- (Jon) Updated `config/puma.rb` to include metrics plugin and port information
  for the metrics endpoint as environment variable, with default, to enable
  running multiple sibling HMLR apps locally if needed without port conflicts
  [GH-135](https://github.com/epimorphics/lr-landing/issues/135)
- (Jon) Updated the `lr_common_styles` gem to the latest 1.9.9 patch release.
- (Bogdan) Updated both english and welsh copies of the accessibility statement
  [GH-136](https://github.com/epimorphics/lr-landing/issues/136)
- (Jon) Moved all mirrored configuration settings from individual environments
  into the application configuration to reduce the need to manage multiple
  sources of truth
- (Bogdan) Fixed a bug where the language selector was not working correctly
  when the user was on the accessibility or privacy pages
  [GH-130](https://github.com/epimorphics/lr-landing/issues/130)
- (Jon) Implemented improved boilerplate metrics integration to offer analysis
  of current application usage stats
- (Jon) Implemented the dynamic page title approach used in the other suite apps
  to the accessibility and privacy translation templates
- (Jon) Converted the privacy templates to match the same haml formatting
  language used in the app
- (Jon) Tweaked the application controller to improve selected language option
  to be applied for the pages
- (Jon) Reorganised makefile targets alphabetically as well as mirrored other
  improvements from the other applications in the suite
- (Jon) Updated .gitignore file to mirror the current approach in the other HMLR
  apps

## 1.7.7 - 2024-08

- (Dan) Updates gemfile to use v1.9.5 lr_common_styles
- (Dan) Adds underlines to links in body text to meet WCAG 2.2 accessibility
  requirements [GH-126](https://github.com/epimorphics/lr-landing/issues/126)

## 1.7.6 - 2024-06

- (Jon) - Updated the deployment.yaml file to mirror the new branch names post
  branch cleanup.
- (Jon) Reconfigured the `detailed documentation` links, both english and welsh,
  to point to the `app/doc/ppd` path; alongside adding tests querying the new
  route to ensure the route is valid and contains the expected content. All
  redirections for any old routes will now handled by the proxy server.

## 1.7.5 - 2023-11-23

- (Jon) Updated the `lr_common_styles` gem to the latest 1.9.3 patch release.

## 1.7.4 - 2023-11-23

- (Jon) Updated the `lr_common_styles` gem to the latest 1.9.2 patch release.
  - Also includes minor patch updates for gems due to bundler update process,
    please see the `Gemfile.lock` for more details.

## 1.7.3.1 - 2023-07-11

- (Jon) Updated the `app/controllers/application_controller.rb` to include the
  `before_action` for the `change_default_caching_policy` method to ensure the
  default `Cache-Control` header for all requests is set to 5 minutes (300
  seconds).

## 1.7.3 - 2023-06-07

- (Jon) Updated the `json_rails_logger` gem to the latest 1.0.1 patch release.
  - Also includes minor patch updates for gems, please see the `Gemfile.lock`
  for details.

## 1.7.2 - 2023-06-03

- (Jon) Updated the `json_rails_logger` gem to the latest 1.0.0 release.

## 1.7.1 - 2023-03-23

- (Jon) Updated to handle locking the root path for individual environments as
  well as removing unnecessary environment variables.
- (Jon) Updated the README to improve the clarity of the instructions for
  running the application locally.
- (Jon) Resolved incorrect traps for missing env vars in `entrypoint.sh`, added
  updated commands for `Dockerfile`, as well as added new `SHORTNAME` variable
  to `Makefile`.

## 1.7.0 - 2023-03-15

- (Jon) Updated the README to improve the clarity of the instructions for
  running the application locally, as well as releasing a new version.
- (Jon) Updated and improved the build files for the new infrastructure use.
- (Jon) Minor text changes to the `Gemfile` to include instructions for running
  Epimorphics specific gems locally during the development of those gems.
- (Jon) Updated the production `json_rails_logger` gem version to be at least
  the current version `~>0.3.5` (this is to cover out of sync release versions)
- (Jon) Updated the production `lr_common_styles` gem version to be at least the
  current version `~>1.9.1` (this is to cover out of sync release versions)
- (Jon) Refactored the version cadence creation to include a SUFFIX value if
  provided; otherwise no SUFFIX is included in the version number.
- (Jon) Renamed the global env variable `RAILS_RELATIVE_URL_ROOT` to
  `APPLICATION_ROOT` to be more clear on it's use in the `entrypoint.sh` code.

## 1.6.0 - 2022-04-07

- (Ian) Adopt all of the current Epimorphics best-practice deployment patterns,
  including shared GitHub actions, updated Makefile and Dockerfile, Prometheus
  monitoring, and updated version of Sentry.
- (Ian) Updated the README as part of handover.

## 1.5.8 - 2022-10-10

- (Jon) Updated accessibility statement to reflect the adjusted release dates
  for both the expected Qonsole update and preparation timestamp alongside the
  removal of the deadlines for test revisions. Also includes minor copy changes
  to resolve typos/punctuation issues.

## 1.5.7 - 2021-12-01

- (Mairead) Added deployment sub repo and assisting deployment files
- (Joseph) Copy change in PPD documentation

## 1.5.6 - 2021-09-28

- (Mairead) Updating copy change and broken link

## 1.5.5 - 2021-06-25

- (Joseph) Small config change to allow linking to privacy notice.

## 1.5.4 - 2021-04-27

- Updated correction to email address (GH-3)

## 1.5.3 - 2021-03-01

- (Ian) Update Rubygem dependencies
- (Ian) Fix Rubocop warnings
- (Ian) Switch from Travis to Github Actions for CI

## 1.5.2 - 2021-01-20

- (Ian) Welsh-language mode enabled in all deployment environments

## 1.5.1 - 2020-12-16

- (Ian) Client-requested change to contact email address

## 1.5.0 - 2020-10-30 (Ian)

- add Welsh translation of accessibility statement
- more complete and consistent support for Welsh language

## 1.4.0 - 2020-09-22 (Ian)

- Add an initial version of the accessibility

## 1.3.1 - 2020-09-22 (Ian)

- added skip-to-main-content link

## 1.3.0 - 2020-09-20 (Ian)

- WCAG conformance updates, including updating to the upstream
  `lr_common_styles`
- removed UKHPI documentation, now that this is available from the UKHPI app
  itself

## 1.2.2 - 2020-07-06

- Update gem dependencies after CVE warnings

## 1.2.1 - 2020-03-19

- Update to gem dependencies, while keeping Rails below version 6

## 1.2.0 - 2020-02-10

- Fix for Qonsole character encoding bug, GH-21

## 1.1.0 - 2019-12-17

- Changed minor version number as we've switched to using a separate Sentry
  project for this app.

## 1.0.7 - 2019-12-16

- Update qonsole-rails to (hopefully) reduce Sentry noise due to path issues
  with error pages.

## 1.0.6 - 2019-12-10

- Remove a reference to an old, now obsolete, dev server as a target endpoint
  for Qonsole

## 1.0.5 - 2019-12-09

- Pull in updated `qonsole-rails` to resolve Sentry warning of unbound variable
  `e`

## 2019-11-15 - 1.0.4

- Gem dependency updates for CVE-2019-15587
- general code tidying
- added some simple integration tests

## 2019-07-17

- (Belatedly) created change log
- update gem dependencies
