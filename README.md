# HMLR linked-data applications landing site

This repo provides the landing page experience for visitors to
[landregistry.data.gov.uk](http://landregistry.data.gov.uk). The landing page
provides links to the various open data services (Price Paid Data Explorer,
Standard Reports and UK Housing Price Index), and hosts the qonsole app, which
allows users to run SPARQL queries against the linked-data dataset.

Please see the other repositories in the [HM Land Registry Open Data](https://github.com/epimorphics/hmlr-linked-data/)
project for more details:

- [HMLR Common Styles](https://github.com/epimorphics/lr_common_styles)
- [PPD Explorer](https://github.com/epimorphics/ppd-explorer)
- [Standard Reports UI](https://github.com/epimorphics/standard-reports-ui)
- [UKHPI](https://github.com/epimorphics/ukhpi)
- [Qonsole (Rails)](https://github.com/epimorphics/qonsole-rails)

## Production Mode

Unlike other HMLR applications, the Landing application does not run run from 
a sub-diretory. As such Production and deveolpment mode run at teh same location.

If running more than one application locally ensure that each is listerning on a
separate port. In the case of running local docker images, the required
configuration is captured in the `Makefile` and an image can be run by using

```sh
make image run
```

or, if the image is already built, simply

```sh
make run
```

For rails applications you can start the server locally using the following command:

```sh
rails server -e production -p <port> -b 0.0.0.0
```

To test the running application visit `localhost:<port>`.

For information on how to running a proxy to mimic production and run multple services
together see [simple-web-proxy](https://github.com/epimorphics/simple-web-proxy/edit/main/README.md)

## Runtime Configuration environment variables

We use a number of environment variables to determine the runtime behaviour
of the application:

| name                       | description                                                             | default value              |
| -------------------------- | ----------------------------------------------------------------------- | -------------------------- |
| `SENTRY_API_KEY`           | The DSN for sending reports to the PPD Sentry account                   | None                       |

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

### Runtime Configuration environment variables

We can use a number of environment variables to determine the runtime behaviour of
the application while developing the codebase locally:

| name                       | description                                                          |
| -------------------------- | -------------------------------------------------------------------- |
| `SENTRY_API_KEY`           | The Sentry DSN client key for the `lr-dgu-landing` Sentry app        |

## Developer notes

### Updating the code

This is a pretty standard, and quite small, Rails app.

Please keep the [changelog](CHANGELOG.md) up-to-date, and increment the
[`/app/lib/version.rb`](https://github.com/epimorphics/lr-landing/app/lib/version.rb)
identifier in line with semver principles.

### Running the app locally in dev mode

Begin by cloning [the Github
repo](https://github.com/epimorphics/lr-landing) and installing the dependencies:

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

There aren't very many tests as this is a very simple app.

```sh
rails -t
```

### Dependent gems

Most of the local (i.e. Epimorphics) gems that this project depends on are served
via GitHub Package Registry (GPR). Specifically, `lr_common_styles` and `json-rails-logger`.

However, `qonsole-rails` is __not__ served via GPR at present, mostly because we
are hoping to retire it in favour of a new implementation of Qonsole. Since
`qonsole-rails` is a public repo, this dependency does not require us to lean on
the old pattern of using an ssh key to serve private gems directly from a
GitHub repo.

Accessing gems from GPR will require a personal access token (PAT). To store this
locally, use `make auth` to set your GitHub Token using the PAT.

To create a PAT, see [the Epimorphics wiki](https://github.com/epimorphics/internal/wiki/Ansible-CICD#creating-a-pat-for-gpr-access).

## Issues

Please add issues to the [shared issues
list](https://github.com/epimorphics/hmlr-linked-data/issues)

