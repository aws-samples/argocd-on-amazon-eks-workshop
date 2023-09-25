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


# Setup CodeCommit
${SCRIPTDIR}/terraform/codecommit/deploy.sh
gitops_workload_url="$(terraform -chdir=${SCRIPTDIR}/terraform/codecommit output -raw gitops_workload_url)"
git clone ${gitops_workload_url} ${SCRIPTDIR}/codecommit || true
mkdir -p ${SCRIPTDIR}/codecommit/addons
mkdir -p ${SCRIPTDIR}/codecommit/platform
touch ${SCRIPTDIR}/codecommit/platform/.keep
mkdir -p ${SCRIPTDIR}/codecommit/apps
touch ${SCRIPTDIR}/codecommit/apps/.keep
cp -r ${SCRIPTDIR}/gitops/addons ${SCRIPTDIR}/codecommit/
pushd ${SCRIPTDIR}/codecommit
git add .
git commit -m "initial commit" || true
git push
popd



${SCRIPTDIR}/terraform/hub/deploy.sh
