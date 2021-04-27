# Params
ARG ENVIRONMENT="production"
ARG RELATIVE_URL="/"

# Defining ruby version
FROM ruby:2.6.6-alpine

# Set working dir and copy app
WORKDIR /usr/src/app
COPY . .

# Prerequisites for gems install
RUN apk add build-base \
            npm \
            tzdata \
            git

# Install bundler and gems
RUN gem install bundler
RUN bundle install

# Set environment variables and expose the running port
ENV RAILS_ENV=$ENVIRONMENT
ENV RAILS_SERVE_STATIC_FILES=true
ENV RELATIVE_URL_ROOT=$RELATIVE_URL
EXPOSE 3000

# Precompile assets and add entrypoint script
RUN rake assets:precompile
ENTRYPOINT [ "sh", "./entrypoint.sh" ]
