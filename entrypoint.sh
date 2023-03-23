#!/bin/bash
set -e

# Remove any pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid
mkdir -pm 1777 ./tmp

# Set the environment
if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
fi

# Handle secrets based on env
if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  # Secret key is set
  SECRET_KEY_BASE=$(./bin/rails secret)
  echo "{\"ts\": $(date -u +%FT%T.%3NZ), \"level\": \"INFO\", \"message\": \"SECRET_KEY_BASE is set\"}"

  export SECRET_KEY_BASE
fi

echo "{\"ts\": $(date -u +%FT%T.%3NZ), \"level\": \"INFO\", \"message\": \"exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0\"}"

exec ./bin/rails server -e "${RAILS_ENV}" -b 0.0.0.0
