#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

# For AWS EC2 override with
# export TF_VAR_ssh_key_basepath="/home/ec2-user/.ssh"


# Deploy the infrastructure
${SCRIPTDIR}/terraform/codecommit/deploy.sh
${SCRIPTDIR}/terraform/hub/deploy.sh
${SCRIPTDIR}/terraform/spokes/deploy.sh staging
${SCRIPTDIR}/terraform/spokes/deploy.sh prod

aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name hub-cluster --alias hub-cluster
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name spoke-staging --alias staging-cluster
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name spoke-prod --alias prod-cluster
