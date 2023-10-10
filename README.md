## ArgoCD on Amazon EKS Workshop

:construction: WORK IN PROGRESS :construction:

[Register for AWS re:Invent 2023 Session 402](https://hub.reinvent.awsevents.com/attendee-portal/catalog/?search=con402) to attend the full version of the workshop


## Use Cases

1. Deploy EKS clusters (hub, staging, prod)
1. Deploy Namespaces
1. Create DynamoDB
1. Deploy Applications
1. Day 2 Operations


# Module 1: Setup

Run the following command create git repository in CodeCommit and create 3 EKS Clusters (Hub, Staging, Prod)
```shell
export ACCOUNT_ID="1234556789"
export AWS_DEFAULT_REGION="us-west-2"
./install.sh
```

Access ArgoCD UI on the Hub Cluster
```shell
echo "ArgoCD URL: https://$(kubectl --context hub-cluster get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "ArgoCD Username: admin"
echo "ArgoCD Password: $(kubectl --context hub-cluster get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
```

# Module 2: Platform

## Deploy EKS Addons

To deploy EKS Addons we need to use Infrastructure as Code (IaC) and GitOps to work together.
Enable the variables for the corresponding Addons in the IaC tool.
```shell
sed -i '' s/"balancer_controller = false"/"balancer_controller = true"/ terraform/spokes/variables.tf
sed -i '' s/"dynamodb                 = false"/"dynamodb                 = true"/ terraform/spokes/variables.tf
```

Apply the IaC to create the IAM Roles for each Addon, and enable the Helm Chart to be deploy by GitOps
```shell
terraform -chdir=terraform/spokes workspace select staging
terraform -chdir=terraform/spokes apply -var-file="workspaces/staging.tfvars" -auto-approve
terraform -chdir=terraform/spokes workspace select prod
terraform -chdir=terraform/spokes apply -var-file="workspaces/prod.tfvars" -auto-approve
```

Verify AWS Load Balancer Controller is installed on each cluster
```shell
kubectl --context staging-cluster get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl --context prod-cluster get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```
Expected Result
```
NAME                                            READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-6d64b58dfc-89wxc   1/1     Running   0          3m
aws-load-balancer-controller-6d64b58dfc-pzbtl   1/1     Running   0          3m
```

Verify AWS Controller for Kubernetes (ACK) is installed on each cluster
```shell
kubectl --context staging-cluster get pods -n ack-dynamodb
kubectl --context prod-cluster get pods -n ack-dynamodb
```
Expected Result
```
NAME                                               READY   STATUS    RESTARTS   AGE
ack-dynamodb-aws-controllers-k8s-89685f8c5-p9rwt   1/1     Running   0          3m
```

## Deploy Namespaces

Set environment variables with the GitHub and CodeCommit repos directory names - they will be referenced in the subsequent instructions that populate the CodeCommit repo.

```shell
export GITHUB_REPO=argocd-on-amazon-eks-workshop
export CODECOMMIT_REPO=gitops-bridge-argocd
```

Create namespaces for each microservice

```shell
mkdir ${CODECOMMIT_REPO}/platform
cp -r ${GITHUB_REPO}/gitops/platform/* ${CODECOMMIT_REPO}/platform/
cd ${CODECOMMIT_REPO}
git add .
git commit -m "add platform"
git push
cd ..
```


## Verify namespaces


```shell
kubectl --context staging-cluster get ns
kubectl --context prod-cluster get ns
```
There should be new namespaces on each cluster
```shell
NAME              STATUS   AGE
assets            Active   7m8s
carts             Active   7m8s
catalog           Active   7m8s
checkout          Active   7m8s
default           Active   159m
kube-node-lease   Active   159m
kube-public       Active   159m
kube-system       Active   159m
orders            Active   7m8s
rabbitmq          Active   7m8s
ui                Active   7m8s
```

# Module 3: Workloads in Stage

Deploy the workloads to staging cluster (default)

```shell
mkdir ${CODECOMMIT_REPO}/apps
cp -r ${GITHUB_REPO}/gitops/apps/* ${CODECOMMIT_REPO}/apps/
cd ${CODECOMMIT_REPO}
sed -i '' "s/ACCOUNT_ID/$ACCOUNT_ID/" apps/carts/staging/kustomization.yaml
sed -i '' "s/ACCOUNT_ID/$ACCOUNT_ID/" apps/carts/prod/kustomization.yaml
git add .
git commit -m "add workloads"
git push
cd ..
```
> Files are committed for both staging and prod, but prod is inactive. In a later section we will deploy to prod

Verify App is running on staging cluster
```shell
kubectl --context staging-cluster get pods -A -l app.kubernetes.io/created-by=eks-workshop
```
There should be pods running in namespaces
```shell
NAMESPACE   NAME                             READY   STATUS    RESTARTS        AGE
assets      assets-7556557b4d-sfndh          1/1     Running   0               3m56s
carts       carts-86c7db99db-5b557           1/1     Running   0               69s
carts       carts-dynamodb-cb4b6f564-wn265   1/1     Running   0               69s
catalog     catalog-6ccfd94978-fcrkl         1/1     Running   0               3m56s
catalog     catalog-mysql-0                  1/1     Running   0               3m56s
checkout    checkout-6845d66fb-b6m82         1/1     Running   0               4m
checkout    checkout-redis-fb67f7944-j2jvr   1/1     Running   0               4m1s
orders      orders-548b6658ff-qjsv7          1/1     Running   0               3m56s
orders      orders-mysql-76dd47c48f-jwt7j    1/1     Running   0               3m56s
ui          ui-59b974ffcc-cbmkw              1/1     Running   0               69s
```

## Access Application UI

Access in
```shell
echo "Staging UI URL: http://$(kubectl --context staging-cluster get svc -n ui ui-nlb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```


# Module 4: Day 2 Operations

Platform team promotes the app to prod cluster, by updating the ApplicationSet `workloads.yaml`

```shell
cp -r gitops/apps/* codecommit/apps/
cd codecommit
sed -i '' s/"values: \[staging\]"/"values: \[staging,prod\]"/ platform/control-plane/workloads.yaml
git add .
git commit -m "add workloads"
git push
cd ..
```

Verify App is running on prod cluster
```shell
kubectl --context prod-cluster get pods -A -l app.kubernetes.io/created-by=eks-workshop
```
There should be pods running in namespaces
```shell
NAMESPACE   NAME                             READY   STATUS    RESTARTS        AGE
assets      assets-7556557b4d-sfndh          1/1     Running   0               3m56s
carts       carts-86c7db99db-5b557           1/1     Running   0               69s
carts       carts-dynamodb-cb4b6f564-wn265   1/1     Running   0               69s
catalog     catalog-6ccfd94978-fcrkl         1/1     Running   0               3m56s
catalog     catalog-mysql-0                  1/1     Running   0               3m56s
checkout    checkout-6845d66fb-b6m82         1/1     Running   0               4m
checkout    checkout-redis-fb67f7944-j2jvr   1/1     Running   0               4m1s
orders      orders-548b6658ff-qjsv7          1/1     Running   0               3m56s
orders      orders-mysql-76dd47c48f-jwt7j    1/1     Running   0               3m56s
ui          ui-59b974ffcc-cbmkw              1/1     Running   0               69s
```

## Access Application UI in Prod

Access in
```shell
echo "Production UI URL: http://$(kubectl --context prod-cluster get svc -n ui ui-nlb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```


## Update Workload in Production

Make a change in production, like setting the `ui` replicas to 2.
Update the patch `codecommit/apps/ui/prod/deployment.yaml`

Push the changes to git
```shell
cd codecommit
sed -i '' s/"replicas: 1"/"replicas: 2"/ apps/ui/prod/deployment.yaml
git add .
git commit -m "set replicas to 2 in prod"
git push
cd ..
```

Verify there are 2 replias in prod cluster
```shell
kubectl --context prod-cluster get pods -n ui
```
Expected output
```shell
NAME                  READY   STATUS    RESTARTS   AGE
ui-59b974ffcc-fktvx   1/1     Running   0          5m
ui-59b974ffcc-hwkqh   1/1     Running   0          41s
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
