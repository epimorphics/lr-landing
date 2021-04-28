# Change log for HMLR landing page app

This app presents the landing page experience for
landregistry.data.gov.uk, including the SPARQL
Qonsole

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
- removed UKHPI documentation, now that this is available from the
  UKHPI app itself

## 1.2.2 - 2020-07-06

- Update gem dependencies after CVE warnings

## 1.2.1 - 2020-03-19

- Update to gem dependencies, while keeping Rails below version 6

## 1.2.0 - 2020-02-10

- Fix for Qonsole character encoding bug, GH-21

## 1.1.0 - 2019-12-17

- Changed minor version number as we've switched to using a
  separate Sentry project for this app.

## 1.0.7 - 2019-12-16

- Update qonsole-rails to (hopefully) reduce Sentry noise due to
  path issues with error pages.

## 1.0.6 - 2019-12-10

- Remove a reference to an old, now obsolete, dev
  server as a target endpoint for Qonsole

## 1.0.5 - 2019-12-09

- Pull in updated `qonsole-rails` to resolve Sentry warning
  of unbound variable `e`

## 2019-11-15 - 1.0.4

- Gem dependency updates for CVE-2019-15587
- general code tidying
- added some simple integration tests

## 2019-07-17

- (Belatedly) created change log
- update gem dependencies
