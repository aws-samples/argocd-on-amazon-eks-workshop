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

# For AWS EC2 override with
# export TF_VAR_ssh_key_basepath="/home/ec2-user/.ssh"

read -p "Enter the region: " region
export AWS_DEFAULT_REGION=$region


# Deploy the infrastructure
${SCRIPTDIR}/terraform/codecommit/deploy.sh
# ${SCRIPTDIR}/terraform/hub/deploy.sh
# ${SCRIPTDIR}/terraform/spokes/deploy.sh staging
# ${SCRIPTDIR}/terraform/spokes/deploy.sh prod
