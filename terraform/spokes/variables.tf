variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS version"
  type        = string
}

variable "addons" {
  description = "EKS addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = false
    enable_ack_dynamodb                 = false
    enable_metrics_server               = true
  }
}
