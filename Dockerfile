ARG RUBY_VERSION=2.6.6-alpine
ARG BUNDLER_VERSION=2.1.4
ARG RAILS_SERVE_STATIC_FILES=true
ARG RELATIVE_URL_ROOT="/"

# Defining ruby version
FROM ruby:$RUBY_VERSION

# Set working dir and copy app
WORKDIR /usr/src/app
COPY . .

# Prerequisites for gems install
RUN apk add build-base \
            npm \
            tzdata \
            git

# Install bundler and gems
RUN gem install bundler:$BUNDLER_VERSION
RUN bundle install

# Set environment variables and expose the running port
ENV RAILS_ENV=$RAILS_ENV
ENV RAILS_SERVE_STATIC_FILES=$RAILS_SERVE_STATIC_FILES
ENV RELATIVE_URL_ROOT=$RELATIVE_URL_ROOT
EXPOSE 3000

# Precompile assets and add entrypoint script
RUN RAILS_ENV=production rake assets:precompile
ENTRYPOINT [ "sh", "./entrypoint.sh" ]