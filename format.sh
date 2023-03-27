#! /bin/bash

set -x
set -euo pipefail

mint run -n swiftformat "$@"
pipenv run yamlfix "$@"
