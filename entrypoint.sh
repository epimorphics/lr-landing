#!/bin/bash
set -e

# Remove any pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid
mkdir -pm 1777 ./tmp

# Set the environment
[ -z "$RAILS_ENV" ] && RAILS_ENV=production

# Check for API Service URL env var
[ -n "$API_SERVICE_URL" ] && echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"API_SERVICE_URL=${API_SERVICE_URL}\"}"

# Handle secrets based on env
[ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ] && SECRET_KEY_BASE=$(./bin/rails secret) && export SECRET_KEY_BASE

[ -n "$RAILS_RELATIVE_URL_ROOT" ] && echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"RAILS_RELATIVE_URL_ROOT=${RAILS_RELATIVE_URL_ROOT}\"}"

echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0\"}"

exec ./bin/rails server -e "${RAILS_ENV}" -b 0.0.0.0
