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

#read -p "Enter the region: " region
#export AWS_DEFAULT_REGION=$region

pushd ${SCRIPTDIR}

# Initialize Terraform
terraform init --upgrade

echo "Applying git resources"
apply_output=$(terraform apply -auto-approve 2>&1 | tee /dev/tty)
if [[ ${PIPESTATUS[0]} -eq 0 && $apply_output == *"Apply complete"* ]]; then
  echo "SUCCESS: Terraform apply of all modules completed successfully"
  popd
else
  echo "FAILED: Terraform apply of all modules failed"
  popd
  exit 1
fi
