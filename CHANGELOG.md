# Change log for HMLR landing page app

This app presents the landing page experience for
landregistry.data.gov.uk, including the SPARQL
Qonsole

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
