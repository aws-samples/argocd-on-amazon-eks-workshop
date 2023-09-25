#!/usr/bin/env bash

set -euo pipefail
set -o errexit

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


${SCRIPTDIR}/terraform/spokes/destroy.sh prod
${SCRIPTDIR}/terraform/spokes/destroy.sh staging
${SCRIPTDIR}/terraform/hub/destroy.sh
${SCRIPTDIR}/terraform/codecommit/destroy.sh
rm -rf ${SCRIPTDIR}/codecommit
