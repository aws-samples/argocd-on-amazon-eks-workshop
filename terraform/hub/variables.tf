variable "gitops_addons_org" {
  description = "Git repository org/user contains for addons"
  default     = "https://github.com/aws-samples"
}
variable "gitops_addons_repo" {
  description = "Git repository contains for addons"
  default     = "eks-blueprints-add-ons"
}
variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  default     = "argocd/"
}
variable "gitops_addons_path" {
  description = "Git repository path for addons"
  default     = "bootstrap/control-plane/addons"
}
variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  default     = "HEAD"
}

variable "gitops_platform_org" {
  description = "Git repository org/user contains for workload"
  default     = "https://github.com/csantanapr"
}
variable "gitops_platform_repo" {
  description = "Git repository contains for workload"
  default     = "gitops-bridge-eks-workshop"
}
variable "gitops_platform_path" {
  description = "Git repository path for workload"
  default     = "gitops/platform"
}
variable "gitops_platform_revision" {
  description = "Git repository revision/branch/ref for workload"
  default     = "HEAD"
}

variable "gitops_workload_org" {
  description = "Git repository org/user contains for workload"
  default     = "https://github.com/csantanapr"
}
variable "gitops_workload_repo" {
  description = "Git repository contains for workload"
  default     = "gitops-bridge-eks-workshop"
}
variable "gitops_workload_path" {
  description = "Git repository path for workload"
  default     = "gitops/apps"
}
variable "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  default     = "HEAD"
}


variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}
variable "kubernetes_version" {
  description = "EKS version"
  default     = "1.27"
}
