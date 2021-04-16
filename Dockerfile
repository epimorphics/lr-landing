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
RUN gem install bundler:2.1.4
RUN bundle install --without="development"

# Set environment variables and expose the running port
ENV RELATIVE_URL_ROOT="/"
ENV RAILS_ENV="production"
EXPOSE 3000

# Add secrets as environment variables (used development env key temporarily)
ENV SECRET_KEY_BASE="c73c9b7ba9910c6f9a3bdd193392f8da6cc36094dbbd3f8c5e575cfc03b09e9ad0d056e15f591bc5f39adbc2e35398ec75cbac94cef5668f8a4497853e5d0537" 

# Add app entrypoint script
ENTRYPOINT [ "sh", "./entrypoint.sh" ]