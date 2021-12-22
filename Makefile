.PHONY:	assets clean image lint modules publish realclean run tag test vars

ACCOUNT?=$(shell aws sts get-caller-identity | jq -r .Account)
GRP_OWNER?=epimorphics
AWS_REGION?=eu-west-1
STAGE?=dev
NAME?=$(shell awk -F: '$$1=="name" {print $$2}' deployment.yaml | sed -e 's/[[:blank:]]//g')
ECR?=${ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com
PAT?=$(shell read -p 'Github access token:' TOKEN; echo $$TOKEN)
API_SERVICE_URL?= http://localhost:8080

COMMIT=$(shell git rev-parse --short HEAD)
VERSION?=$(shell /usr/bin/env ruby -e 'require "./app/lib/version" ; puts Version::VERSION')
TAG?=${VERSION}-${COMMIT}

${TAG}:
	@echo ${TAG}

IMAGE?=${NAME}/${STAGE}
REPO?=${ECR}/${IMAGE}

GITHUB_TOKEN=.github-token
NPMRC=.npmrc
BUNDLE_CFG=${HOME}/.bundle/config
YARN_LOCK=yarn.lock

all: image

${BUNDLE_CFG}: ${GITHUB_TOKEN}
	@./bin/bundle config set rubygems.pkg.github.com ${GRP_OWNER}:`cat ${GITHUB_TOKEN}`

${GITHUB_TOKEN}:
	@echo ${PAT} > ${GITHUB_TOKEN}

${NPMRC}: ${GITHUB_TOKEN}
	@echo "@epimorphics:registry=https://npm.pkg.github.com/" > ${NPMRC}
	@echo "//npm.pkg.github.com/:_authToken=`cat ${GITHUB_TOKEN}`" >> ${NPMRC}

assets:
	@./bin/bundle config set --local without 'development'
	@./bin/bundle install
	@./bin/rails assets:clean assets:precompile

auth: ${GITHUB_TOKEN} ${NPMRC} ${BUNDLE_CFG}

clean:
	@[ -d public/assets ] && ./bin/rails assets:clobber || :

image: auth lint test
	@echo Building ${REPO}:${TAG} ...
	@docker build --tag ${REPO}:${TAG} .
	@echo Done.

lint: assets
	@./bin/bundle exec rubocop

modules: ${NPMRC}
	@yarn install

publish: image
	@echo Publishing image: ${REPO}:${TAG} ...
	@docker push ${REPO}:${TAG} 2>&1
	@echo Done.

realclean: clean
	@rm -f ${GITHUB_TOKEN} ${NPMRC} ${BUNDLE_CFG}

run:
	@-docker stop lr_landing
	@-docker rm lr_landing && sleep 20
	@docker run -p 3000:3000 --rm --name lr_landing ${REPO}:${TAG}

tag:
	@echo ${TAG}

test: assets
	@./bin/rake test

vars:
	@echo "Docker: ${REPO}:${TAG}"
