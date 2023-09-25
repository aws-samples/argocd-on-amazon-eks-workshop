#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

#read -p "Enter the region: " region
#export AWS_DEFAULT_REGION=$region

${SCRIPTDIR}/terraform/codecommit/deploy.sh
gitops_workload_url="$(terraform -chdir=${SCRIPTDIR}/terraform/codecommit output -raw gitops_workload_url)"
git clone ${gitops_workload_url} ${SCRIPTDIR}/codecommit
cp -r ${SCRIPTDIR}/gitops/* ${SCRIPTDIR}/codecommit/
pushd ${SCRIPTDIR}/codecommit
git add .
git commit -m "initial commit"
git push
popd




