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

pushd ${SCRIPTDIR}

echo "Destroying AWS git resources"
terraform destroy -auto-approve
destroy_output=$(terraform destroy -auto-approve 2>&1)
if [[ $? -eq 0 && $destroy_output == *"Destroy complete!"* ]]; then
  echo "SUCCESS: Terraform destroy of all targets completed successfully"
else
  echo "FAILED: Terraform destroy of all targets failed"
  popd
  exit 1
fi

popd
