#! /bin/bash

set -x
set -euo pipefail

mint run -n swiftformat "$@"
pipenv run yamlfix "$@"
bundle exec rubocop -A "$@"
npx prettier --write "$@"
