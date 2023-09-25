#!/usr/bin/env bash

set -euo pipefail
set -o errexit

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

read -p "Enter the region: " region
export AWS_DEFAULT_REGION=$region


${SCRIPTDIR}/terraform/codecommit/destroy.sh
rm -rf ${SCRIPTDIR}/codecommit




