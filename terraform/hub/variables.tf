variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"

}
variable "kubernetes_version" {
  description = "EKS version"
  type        = string
  default     = "1.27"
}
