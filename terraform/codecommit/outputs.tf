output "gitops_workload_org" {
  value = local.gitops_workload_org
}
output "gitops_workload_repo" {
  value = local.gitops_workload_repo
}
output "gitops_workload_url" {
  value = local.gitops_workload_url
}
output "configure_argocd" {
  value = "argocd repo add ${local.gitops_workload_url} --ssh-private-key-path $${HOME}/.ssh/gitops_ssh.pem --insecure-ignore-host-key --upsert --name git-repo"
}
output "git_clone" {
  value = "git clone ${local.gitops_workload_url} gitops-bridge-eks-workshop"
}
