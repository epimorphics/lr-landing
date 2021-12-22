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

## Deployment

To mimic running the application in a deployed state you can run
`make image` and this will run through the assets precompilation, linting and testing before creating a Docker image. To view the Docker container you can run `make run`

To bypass the need for running locally AWS you can pass a global variable to the command with `ECR=local make image`

You can run `make help` to view a list of other make commands available

## Entrypoint.sh

* The Rails Framework requires certain values to be set as a Global environment variable when starting. To ensure the `RAILS_RELATIVE_URL_ROOT` is only set in one place per application we have added this to the Entrypoint file along with the `SCRIPT_NAME`.
* The Rails secret is also created here.
* There is a workaround to removing the PID lock of the Rails process in the event of the application crashing and not releasing the process.
* We have to pass the `API_SERVICE_URL` so that it is available in the Entrypoint.sh or the application will throw an error and exit before starting

## Issues

Please add issues to the [shared issues list](https://github.com/epimorphics/hmlr-linked-data/issues)
