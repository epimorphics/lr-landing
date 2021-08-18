.PHONY:	image publish

STAGE?=dev
NAME?=$(shell awk -F: '$$1=="name" {print $$2}' deployment.yaml | sed -e 's/\s//g')
ECR?=018852084843.dkr.ecr.eu-west-1.amazonaws.com
TAG?=$(shell if git describe > /dev/null 2>&1 ; then   git describe; else   git rev-parse --short HEAD; fi)

IMAGE?=${NAME}/${STAGE}
REPO?=${ECR}/${IMAGE}

all: publish

image: assets
	@echo Building ${REPO}:${TAG} ...
	@docker build --tag ${REPO}:${TAG} .
	@echo Done.

publish: image
	@echo Publishing image: ${REPO}:${TAG} ...
	@docker push ${REPO}:${TAG} 2>&1
	@echo Done.

assets:
	@bundle config set --local without 'development'
	@bundle install
	@./bin/rails assets:clean assets:precompile

run:
	@-docker stop lr_landing
	@-docker rm lr_landing && sleep 20
	@docker run -p 3000:3000 --rm --name lr_landing -e RAILS_RELATIVE_URL_ROOT='' ${REPO}:${TAG}

tag:
	@echo ${TAG}

test: assets
	@./bin/rake test

clean:
	@./bin/rails assets:clobber

vars:
	@echo "Docker: ${REPO}:${TAG}"
