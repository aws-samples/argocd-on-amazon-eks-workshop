## ArgoCD on Amazon EKS Workshop

This workshop covers the following use cases

1. Deploy hub-spoke clusters (hub, staging, prod)
1. Deploy namespaces and argocd project
1. Deploy application on each environment cluster (ie staging and production)
1. Makes changes to the app in production using gitops
1. TODO: Have the carts backend use dynamodb deployed with ACK

## Deploy Clusters
Deploy the Hub Cluster
```shell
cd terraform/hub
terraform init
terraform apply
```
Access Terraform output for Hub Cluster
```shell
terraform output
```

Open a new Terminal and Deploy Staging Cluster
```shell
cd terraform/spokes
./deploy.sh staging
```
Open a new Terminal and Deploy Production Cluster
```shell
cd terraform/spokes
./deploy.sh prod
```
Each environment uses a Terraform workspace

Access Terraform output for each environment, env is "staging" or "prod" from the `spokes` directory
```shell
terraform workspace select ${env}
terraform output
```


## Setup Hub Cluster
Setup `kubectl` and `argocd` for Hub Cluster
```shell
export KUBECONFIG="/tmp/hub-cluster"
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
aws eks --region us-west-2 update-kubeconfig --name hub-cluster
kubectl config set-context --current --namespace argocd
argocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)
```
Access ArgoCD UI
```shell
echo "ArgoCD URL: https://$(kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "ArgoCD Username: admin"
echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
```

## Setup Staging Cluster
Setup `kubectl` for Staging Cluster
```shell
export KUBECONFIG="/tmp/spoke-staging"
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
aws eks --region us-west-2 update-kubeconfig --name spoke-staging
```

## Setup Prod Cluster
Setup `kubectl` for Production Cluster
```shell
export KUBECONFIG="/tmp/spoke-prod"
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
aws eks --region us-west-2 update-kubeconfig --name spoke-prod
```

## Deploy Cluster Addons (On the Hub Cluster run the following command)
```shell
kubectl apply -f bootstrap/addons.yaml
```

## Deploy Platform (On the Hub Cluster run the following command)
```shell
kubectl apply -f bootstrap/platform.yaml
```

## Deploy Workloads (On the Hub Cluster run the following command)
```shell
kubectl apply -f bootstrap/workloads.yaml
```


## Access UI on Staging or Production, pick the correct terminal
```shell
kubectl port-forward -n ui svc/ui 8080:80
```
Open browser on http://localhost:8080



## (Optional) Make changes to git using CodeCommit

Create git repository
```shell
cd terraform/codecommit
terraform init
terraform apply
```

Setup git repository, from the `terraform/codecommit` directory
```shell
git clone $(terraform output -raw gitops_workload_url) codecommit-repo
cd codecommit-repo
cp -r ../../../gitops .
git add .
git commit -m "initial commit"
git push
```

Make a change in production, like setting the `ui` replicas to 2.
Update the `gitops/apps/ui/prod/kustomization.yaml`
Uncomment the lines and save the file
```yaml
patches:
- deployment.yaml
```
Push the changes to git
```shell
git add .
git commit -m "Replicas for ui set to 2 in prod"
git push
```


Add git ssh key into argocd, from the `terraform/hub` directory
```shell
argocd repo add $TF_VAR_gitops_workload_org/$TF_VAR_gitops_workload_repo --ssh-private-key-path ${HOME}/.ssh/gitops_ssh.pem --insecure-ignore-host-key --upsert --name git-repo
```

Update ArgoCD git urls in all Clusters, from the `terraform/hub` directory
```shell
kubectl annotate secret -n argocd --overwrite=true -l argocd.argoproj.io/secret-type=cluster \
  platform_repo_url="$(terraform -chdir=../codecommit output -raw gitops_workload_org)/$(terraform -chdir=../codecommit output -raw gitops_workload_repo)" \
  workload_repo_url="$(terraform -chdir=../codecommit output -raw gitops_workload_org)/$(terraform -chdir=../codecommit output -raw gitops_workload_repo)"
```



## Clean

Destroy Spoke Clusters
```shell
cd terraform/spokes
./destroy.sh staging
./destroy.sh prod
```

Destroy Hub Clusters
```shell
cd terraform/hub
./destroy.sh
```

Destroy codecommit
```shell
cd terraform/codecommit
terraform destroy
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

