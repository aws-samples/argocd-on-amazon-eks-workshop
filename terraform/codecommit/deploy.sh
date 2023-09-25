#!/bin/bash


read -p "Enter the region: " region
export AWS_DEFAULT_REGION=$region

# Initialize Terraform
terraform init --upgrade

echo "Applying git resources"
apply_output=$(terraform apply -auto-approve 2>&1 | tee /dev/tty)
if [[ ${PIPESTATUS[0]} -eq 0 && $apply_output == *"Apply complete"* ]]; then
  echo "SUCCESS: Terraform apply of all modules completed successfully"
else
  echo "FAILED: Terraform apply of all modules failed"
  exit 1
fi
