output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
  EOT
}


output "configure_argocd" {
  description = "Terminal Setup"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
    export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
    kubectl config set-context --current --namespace argocd
    argocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)
    echo "ArgoCD Username: admin"
    echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
    echo Port Forward: http://localhost:8080
    kubectl port-forward -n argocd svc/argo-cd-argocd-server 8080:80
    EOT
}

output "access_argocd" {
  description = "ArgoCD Access"
  value       = <<-EOT
    export KUBECONFIG="/tmp/${module.eks.cluster_name}"
    aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
    echo "ArgoCD URL: https://$(kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    echo "ArgoCD Username: admin"
    echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
    EOT
}


output "argocd_iam_role_arn" {
  description = "IAM Role for ArgoCD Cluster Hub, use to connect to spoke clusters"
  value       = module.argocd_irsa.iam_role_arn
}

output "cluster_name" {
  description = "Cluster Hub name"
  value       = module.eks.cluster_name
}
output "cluster_endpoint" {
  description = "Cluster Hub endpoint"
  value       = module.eks.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  description = "Cluster Hub certificate_authority_data"
  value       = module.eks.cluster_certificate_authority_data
}
output "cluster_region" {
  description = "Cluster Hub region"
  value       = local.region
}

output "gitops_addons_org" {
  description = "Git repository org/user contains for addons"
  value     = local.gitops_addons_org
}
output "gitops_addons_repo" {
  description = "Git repository contains for addons"
  value     = var.gitops_addons_repo
}
output "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  value     = local.gitops_addons_basepath
}
output "gitops_addons_path" {
  description = "Git repository path for addons"
  value     = local.gitops_addons_path
}
output "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  value     = local.gitops_addons_revision
}

output "gitops_platform_org" {
  description = "Git repository org/user contains for platform"
  value     = local.gitops_platform_org
}
output "gitops_platform_repo" {
  description = "Git repository contains for platform"
  value     = var.gitops_platform_repo
}
output "gitops_platform_path" {
  description = "Git repository path for platform"
  value     = local.gitops_platform_path
}
output "gitops_platform_revision" {
  description = "Git repository revision/branch/ref for platform"
  value     = local.gitops_platform_revision
}

output "gitops_workload_org" {
  description = "Git repository org/user contains for workload"
  value     = local.gitops_workload_org
}
output "gitops_workload_repo" {
  description = "Git repository contains for workload"
  value     = var.gitops_workload_repo
}
output "gitops_workload_path" {
  description = "Git repository path for workload"
  value     = local.gitops_workload_path
}
output "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  value     = local.gitops_workload_revision
}