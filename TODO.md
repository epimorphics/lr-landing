# TODO

## Pre-Integration Tasks

- [x] Run `bundle install` to update Gemfile.lock after removing `popper_js`
- [x] Verify local testing with lr_common_styles via local path works correctly
- [x] Run `make check` (or equivalent) to verify linting and tests pass
- [x] Test asset compilation with `rails assets:precompile`
- [x] Verify Bootstrap dropdowns and popovers function correctly
- [x] Check browser console for JavaScript errors related to Popper/Bootstrap
- [x] Verify local testing with qonsole_rails via local path works correctly
- [x] Test SPARQL query functionality (empty results, non-empty results)
- [x] Verify dropdown components display and function correctly in query interface
- [x] Check query form responsiveness on mobile and desktop viewports

## Integration Tasks

- [x] Update Gemfile to use published lr_common_styles 3.0.0 from eGPR
- [x] Run `bundle update lr_common_styles` to lock new version
- [x] Remove local path override from Gemfile
- [x] Test full application functionality with published gem
- [x] Update Gemfile to use published qonsole_rails 2.4.0 from eGPR
- [x] Run `bundle update qonsole_rails` to lock new version
- [x] Remove local path override from Gemfile
- [x] Test full application functionality with published qonsole_rails gem

## Deployment Tasks

- [ ] Deploy to test/staging environment
- [ ] Verify UI components render correctly
- [ ] Test interactive Bootstrap components (modals, dropdowns, tooltips)
- [ ] Monitor for asset pipeline errors in logs
- [ ] Test query submission and result handling (including empty results)
- [ ] Verify query form responsiveness and dropdown toggles work correctly
- [ ] Monitor logs for deprecation warnings and response noise
- [ ] Deploy to production after successful testing
