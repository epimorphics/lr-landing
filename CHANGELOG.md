# Change log for HMLR landing page app

This app presents the landing page experience for landregistry.data.gov.uk,
including the SPARQL Qonsole

# 2.0.4 - 2025-02

- (Jon) Updated log level configuration across environments
  - Added log level setting based on environment variable.
  - Default to 'debug' in development and 'info' in production/test.
  [GH-63](https://github.com/epimorphics/lr-landing/issues/63)
- (Jon) Changed the way boot information is printed.
- (Jon) Switched to JSON format for better compatibility with logging services.
- (Jon) Refactored method to improve clarity and structure.
- (Jon) Made the version string immutable by freezing it
- (Jon) Included `puma-metrics` gem for better monitoring as now using Rails 6 or greater
- (Jon) Updated Gemfile and Gemfile.lock to reflect the addition
- (Jon) Set up a configurable metrics port with a default value.
- (Jon) Updated the binding URL for the metrics server in development.
- (Jon) Removed old git reference for the qonsole_rails gem.
- (Jon) Added the qonsole_rails gem to the source block instead.
- (Jon) Updated several gems to their latest versions.
- (Jon) Cleaned up commented-out paths in the Gemfile.

## 2.0.3 - 2025-01

- (Jon) Improves error metrics reporting to ensure that logging always happens
  with the appropriate severity depending on the exception status while reducing
  the types of errors that can trigger a an error metric and therefore a
  notification in slack
  [GH-149](https://github.com/epimorphics/hmlr-linked-data/issues/149)

## 2.0.2 - 2024-12

- (Bogdan) Updated all gems, including `json_rails_logger`

## 2.0.1 - 2024-10

- (Bogdan) Fixed an issue with CSS for the checkboxes in the Qonsole query form

## 2.0.0 - 2024-10

- (Bogdan) Upgraded the `qonsole-rails` and `lr_common_styles` gems to latest
  versions (which are now running on ruby `3.3.5` and rails `7.2.2` as well)
- (Bogdan) Upgraded alpine to `3.20`
- (Bogdan) Upgraded rails to `7.2.2`
- (Bogdan) Upgraded ruby to `3.3.5`
- (Jon) Removed the public/fees-caluclator.html file as it is no longer needed
  [GH-140](https://github.com/epimorphics/lr-landing/issues/140)

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
