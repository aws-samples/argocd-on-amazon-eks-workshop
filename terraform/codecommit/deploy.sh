#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

pushd ${SCRIPTDIR}

# Initialize Terraform
terraform init --upgrade

echo "Applying git resources"
apply_output=$(terraform apply -auto-approve 2>&1 | tee /dev/tty)
if [[ ${PIPESTATUS[0]} -eq 0 && $apply_output == *"Apply complete"* ]]; then
  # wait for ssh access allowed
  sleep 10
  echo "SUCCESS: Terraform apply of all modules completed successfully"
  gitops_workload_url="$(terraform output -raw gitops_workload_url)"
  rm -rf ${ROOTDIR}/codecommit
  git clone ${gitops_workload_url} ${ROOTDIR}/codecommit || true
  mkdir -p ${ROOTDIR}/codecommit/addons
  mkdir -p ${ROOTDIR}/codecommit/platform/control-plane
  touch ${ROOTDIR}/codecommit/platform/control-plane/.keep
  mkdir -p ${ROOTDIR}/codecommit/platform/staging
  touch ${ROOTDIR}/codecommit/platform/staging/.keep
  mkdir -p ${ROOTDIR}/codecommit/platform/prod
  touch ${ROOTDIR}/codecommit/platform/prod/.keep
  mkdir -p ${ROOTDIR}/codecommit/apps
  touch ${ROOTDIR}/codecommit/apps/.keep
  cp -r ${ROOTDIR}/gitops/addons ${ROOTDIR}/codecommit/
  pushd ${ROOTDIR}/codecommit
  git add .
  git commit -m "initial commit" || true
  git push
  popd
  echo "SUCCESS: Terraform apply of all modules completed successfully"
else
  echo "FAILED: Terraform apply of all modules failed"
  popd
  exit 1
fi

popd