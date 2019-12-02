# HMLR linked-data applications landing site

This repo provides the landing page experience for visitors
to [landregistry.data.gov.uk](http://landregistry.data.gov.uk).
The landing page provides links to the various open data services
(PPD, standard reports and UKHPI), and hosts the qonsole app, which
allows users to run SPARQL queries against the linked-data dataset.

## Developer notes

### Updating the code

This is a pretty standard, and quite small, Rails app. Clone
[the Github repo](https://github.com/epimorphics/lr-landing)
to start making changes.

Please keep the [changelog](CHANGELOG.md) up-to-date, and
increment the `Version::VERSION` identifier in line with
semver principles.

### Code standards

Rubocop should return zero errors or warnings

### Running the tests

There aren't very many tests as this is a very simple app.

    rails -t

### Deployment

At the present time (this may change in future), the development,
staging (aka pre-production) and production deployments are
built by Chef scripts from the `dev` `staging` and `production`
branches respectively.

To add a new feature or fix, create an appropriate branch,
make a pull request, merge the code then use the DMS to update
that particular deployment environment.
