## ArgoCD on Amazon EKS Workshop

This workshop covers the following use cases

1. Deploy hub-spoke clusters (hub, staging, prod)
1. Deploy namespaces and argocd project
1. Deploy application on each environment cluster (ie staging and production)
1. Makes changes to the app in production using gitops
1. TODO: Have the carts backend use dynamodb deployed with ACK

## Setup Workshop

Run the following command create git repository in CodeCommit and create 3 EKS Clusters (Hub, Staging, Prod)
```shell
./install.sh
```

## Deploy EKS Cluster Addons

```shell
mkdir -p codecommit/addons
cp -r gitops/addons/* codecommit/addons/
cd codecommit
git add .
git push
cd ..
```

## Deploy Platform Guardrails

```shell
mkdir -p codecommit/platform
cp -r gitops/platform/* codecommit/platform/
cd codecommit
git add .
git push
cd .
```

## Deploy Workloads

```shell
mkdir -p codecommit/apps
cp -r gitops/apps/* codecommit/apps/
cd codecommit
git add .
git push
cd .
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

## Setup Staging Cluster Terminal
Setup `kubectl` for Staging Cluster
```shell
export KUBECONFIG="/tmp/spoke-staging"
aws eks --region us-west-2 update-kubeconfig --name spoke-staging
```

## Setup Prod Cluster Terminal
Setup `kubectl` for Production Cluster
```shell
export KUBECONFIG="/tmp/spoke-prod"
aws eks --region us-west-2 update-kubeconfig --name spoke-prod
```

## Access Applicaiton UI on Staging or Production, pick the correct terminal
```shell
kubectl port-forward -n ui svc/ui 8080:80
```
Open browser on http://localhost:8080


# Update Workload in Production

Make a change in production, like setting the `ui` replicas to 2.
Update the `codecommit/apps/ui/prod/kustomization.yaml`
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


## Clean
Destroy all AWS resources
```shell
./cleaup.sh
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

