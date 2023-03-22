# HMLR linked-data applications landing site

This repo provides the landing page experience for visitors to
[landregistry.data.gov.uk](http://landregistry.data.gov.uk). The landing page
provides links to the various open data services ([Price Paid Data
Explorer](http://landregistry.data.gov.uk/app/ppd), [Standard
Reports](http://landregistry.data.gov.uk/app/standard-reports) and [UK Housing
Price Index](http://landregistry.data.gov.uk/app/ppukhpi)), and hosts the
qonsole app, which allows users to run SPARQL queries against the linked-data
dataset.

Please see the other repositories in the [HM Land Registry Open
Data](https://github.com/epimorphics/hmlr-linked-data/) project for more
details:

- [HMLR Common Styles](https://github.com/epimorphics/lr_common_styles)
- [PPD Explorer](https://github.com/epimorphics/ppd-explorer)
- [Standard Reports UI](https://github.com/epimorphics/standard-reports-ui)
- [UKHPI](https://github.com/epimorphics/ukhpi)
- [Qonsole (Rails)](https://github.com/epimorphics/qonsole-rails)

## Developer notes

### Updating the code

This is a pretty standard, and quite small, Rails app.

Please keep the [changelog](CHANGELOG.md) up-to-date, and increment the
[`/app/lib/version.rb`](https://github.com/epimorphics/lr-landing/app/lib/version.rb)
identifier in line with semver principles.

### Running the app locally in dev mode

Begin by cloning [the Github repo](https://github.com/epimorphics/lr-landing)
and installing the dependencies:

```sh
git clone git@github.com:epimorphics/lr-landing.git &&
cd lr-landing &&
bundle install
```

Start the app locally for development:

```sh
rails server
```

Visit [`localhost:3000`](http://localhost:3000/) to view the local instance.

### Code standards

Rubocop should return zero errors or warnings:

```sh
$ rubocop

Inspecting 30 files
..............................

30 files inspected, no offenses detected
```

### Running the tests

While there aren't very many tests, as this is a very simple app, the tests should
be updated when required and always verified as still passing.

```sh
rails -t

[...]

Finished in 1.607288s, 4.3552 runs/s, 5.5995 assertions/s.
7 runs, 9 assertions, 0 failures, 0 errors, 0 skips
```

### Running the app locally as a Docker image

It can be useful to run the compiled Docker image, that will be run by the
production installation, locally yourself.

To mimic running the application in a deployed state you can call:

```sh
make image
```

This will run through the assets precompilation before creating a Docker image,
then you can run the image with the following command:

```sh
make run
```

You can use the env variables [below](#configuration-environment-variables) to
set those values to work in your local environment if needed, for example:

```sh
APPLICATION_ROOT=/ make image run
```

N.B In the production environment, the app will be accessed via the URL path
`/app/root`. When running the docker image locally for development, you may need
to access the application via a proxy, otherwise, the paths for JS, CSS and
image assets might not work.

Please see the *[simple web
proxy](https://github.com/epimorphics/simple-web-proxy)* repository for one
simple way of handling this on a local develpment machine.

With the proxy and Docker container running you can access the application as
[`localhost:3030/app/root`](http://localhost:3030/app/root) (note the trailing
path).

### Dependent gems

Most of the local (i.e. Epimorphics) gems that this project depends on are
served via GitHub Package Registry (GPR). Specifically, `lr_common_styles` and
`json-rails-logger`.

However, `qonsole-rails` is __not__ served via GPR at present, mostly because we
are hoping to retire it in favour of a new implementation of Qonsole. Since
`qonsole-rails` is a public repo, this dependency does not require us to lean on
the old pattern of using an ssh key to serve private gems directly from a GitHub
repo.

Accessing gems from GPR will require a personal access token (PAT). To store
this locally, use `make auth` to set your GitHub Token using the PAT.

To create a PAT, see [the Epimorphics
wiki](https://github.com/epimorphics/internal/wiki/Ansible-CICD#creating-a-pat-for-gpr-access).

## Issues

Please add issues to the [shared issues
list](https://github.com/epimorphics/hmlr-linked-data/issues)

## Deployment

The detailed deployment mapping is decscribed in `deployment.yml`. At the time
of writing, using the new infrastructure, the deployment process is as follows:

- commits to the `dev-infrastructure` branch will deploy the dev server
- commits to the `preprod` branch will deploy the pre-production server
- any commit on the `prod` branch will deploy the production server as a new
  release

If the commit is a "new" release, the deployment should be tagged with the same
version number, e.g. `1.2.3`. as set in the `/app/lib/version.rb` and a short
annotation summarising the updates should be included in the tag.

Once the production deployment has been completed and verified, please create a
release on the repository using the same latest version number. Utilise the
`Generate release notes from commit log` option to create specific notes on the
contained changes as well as the ability to diff agains the previous version.

### `entrypoint.sh`

- There is a workaround to removing the PID lock of the Rails process in the
  event of the application crashing and not releasing the process.
- The Rails secret is created here.

### Configuration environment variables

We can use a number of environment variables to determine the runtime behaviour
of the application while developing the codebase locally:

| name                       | description                                                          | typical value           |
| -------------------------- | -------------------------------------------------------------------- | ----------------------- |
| `APPLICATION_ROOT`         | The path from the server root to the application                     | `/app/root`             |
| `API_SERVICE_URL`          | The base URL from which data is accessed, including the HTTP scheme  | `http://localhost:8080` |
| `SENTRY_API_KEY`           | The Sentry DSN client key for the `lr-dgu-landing` Sentry app        |                         |
