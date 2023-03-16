#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f ./tmp/pids/server.pid
mkdir -pm 1777 ./tmp

# Set the environment
if [ -z "$RAILS_ENV" ]
then
  export RAILS_ENV=production
fi

# [ -z "$API_SERVICE_URL" ] && echo '{"ts": "'"$(date -u +%FT%T.%3NZ)"'", "level": "ERROR", "message": "You have not specified the env var API_SERVICE_URL"}' >&2

# if [ -z "$API_SERVICE_URL" ] ]
# then
#   exit 1
# fi

# Handle secrets based on env
if [ "$RAILS_ENV" == "production" ] && [ -z "$SECRET_KEY_BASE" ]
then
  SECRET_KEY_BASE=$(./bin/rails secret)
  export SECRET_KEY_BASE
fi

export RAILS_RELATIVE_URL_ROOT=${APPLICATION_ROOT:-'/app/root'}
export SCRIPT_NAME=${RAILS_RELATIVE_URL_ROOT}

echo '{"ts": "'"$(date -u +%FT%T.%3NZ)"'", "level": "INFO", "message": "Starting LR Landing application with RAILS_ENV='"${RAILS_ENV}"'", "RAILS_RELATIVE_URL_ROOT"="'"${RAILS_RELATIVE_URL_ROOT}"'", "SCRIPT_NAME"="'"${SCRIPT_NAME}"'", "API_SERVICE_URL"="'"${API_SERVICE_URL}"'"}'

exec ./bin/rails server -e "${RAILS_ENV}" -b 0.0.0.0
