#!/bin/bash
set -e

mkdir -pm 1777 ./tmp

# Set the environment
[ -z "$RAILS_ENV" ] && RAILS_ENV=production

# Check for SENTRY_API_KEY variable and report if missing
[ -z "$SENTRY_API_KEY" ] && echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"ERROR\",\"message\":\"SENTRY_API_KEY is required\"}"

# Check for RAILS_RELATIVE_URL_ROOT variable and log it
[ -n "$RAILS_RELATIVE_URL_ROOT" ] && echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"RAILS_RELATIVE_URL_ROOT=${RAILS_RELATIVE_URL_ROOT}\"}"

# Handle secrets based on env
[ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ] && SECRET_KEY_BASE=$(./bin/rails secret) && export SECRET_KEY_BASE

# Log the rails command that will be executed
echo "{\"ts\":\"$(date -u +%FT%T.%3NZ)\",\"level\":\"INFO\",\"message\":\"exec ./bin/rails server -e ${RAILS_ENV} -b 0.0.0.0\"}"

# Execute the rails command
exec ./bin/rails server -e "${RAILS_ENV}" -b 0.0.0.0
