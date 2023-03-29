#!/bin/bash
set -e

# Remove any pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid
mkdir -pm 1777 ./tmp

# Set the environment
[ -z "$RAILS_ENV" ] && RAILS_ENV=production

# Handle secrets based on env
[ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ] && export SECRET_KEY_BASE=$(./bin/rails secret)

[ -n "${RAILS_RELATIVE_URL_ROOT}" ] && echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"RAILS_RELATIVE_URL_ROOT=${RAILS_RELATIVE_URL_ROOT}\"}"

echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0\"}"

exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0
