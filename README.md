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

### Dependent gems

As of 2022-04-04, most of the local (i.e. Epimorphics) gems that this project
depends on are served via GitHub Package Registry (GPR). Specifically,
`lr_common_styles` and `json-rails-logger`. However, `qonsole-rails` is **not**
served via GPR at present, mostly because we are hoping to retire it in favour
of a new implementation of Qonsole. Since `qonsole-rails` is a public repo,
this dependency does not require us to lean on the old pattern of using an ssh
key to serve private gems directly from a GitHub repo.

Accessing gems from GPR will require a personal access token PAT. To store this
locally, use `make auth`. To create a PAT, see [the Epimorphics
wiki](https://github.com/epimorphics/internal/wiki/Ansible-CICD#creating-a-pat-for-gpr-access).

### Pre-flight testing

To mimic running the application in a deployed state you can run `make image`
and this will run through the assets precompilation, linting and testing before
creating a Docker image. To view the Docker container you can run `make run`

Note that in the production environment, the app will be accessed via the URL
path `/app/root`. When running the docker image locally, you will need to
access the application via a proxy, otherwise, the paths for JS, CSS and image
assets will not work. Please see the [simple web
proxy](https://github.com/epimorphics/simple-web-proxy) for one simple way of
handling this on a local dev machine.

## Issues

Please add issues to the [shared issues list](https://github.com/epimorphics/hmlr-linked-data/issues)

## Deployment

The detailed deployment mapping is decscribed in `deployment.yml`. At the time of
writing:

- any commit tagged with `vNNN`, e.g: `v1.2.7` will be deployed to production
- any commit on the `dev-infrastructure` branch will deploy the dev server in
  using the new infrastructure

### `entrypoint.sh`

- The Rails Framework requires certain values to be set as a Global environment
  variable when starting. To ensure the `APPLICATION_ROOT` is only set
  in one place per application we have added this to the Entrypoint file along
  with the `SCRIPT_NAME`.
- The Rails secret is also created here.
- There is a workaround to removing the PID lock of the Rails process in the
  event of the application crashing and not releasing the process.
- We have to pass the `API_SERVICE_URL` so that it is available in the
  `entrypoint.sh` or the application will throw an error and exit before starting

## Configuration environment variables

We use a number of environment variables to determine the runtime behaviour
of the application:

| name                       | description                                                          | typical value           |
| -------------------------- | -------------------------------------------------------------------- | ----------------------- |
| `APPLICATION_ROOT`         | The path from the server root to the application                     | `/app/root`             |
| `API_SERVICE_URL`          | The base URL from which data is accessed, including the HTTP scheme  | `http://localhost:8080` |
| `SENTRY_API_KEY`           | The Sentry DSN client key for the `lr-dgu-landing` Sentry app        |                         |
