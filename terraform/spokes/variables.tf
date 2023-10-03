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
    enable_cert_manager                          = false
    enable_aws_efs_csi_driver                    = false
    enable_aws_fsx_csi_driver                    = false
    enable_aws_cloudwatch_metrics                = false
    enable_aws_privateca_issuer                  = false
    enable_cluster_autoscaler                    = false
    enable_external_dns                          = false
    enable_external_secrets                      = false
    enable_aws_load_balancer_controller          = false
    enable_fargate_fluentbit                     = false
    enable_aws_for_fluentbit                     = false
    enable_aws_node_termination_handler          = false
    enable_karpenter                             = false
    enable_velero                                = false
    enable_aws_gateway_api_controller            = false
    enable_aws_ebs_csi_resources                 = false
    enable_aws_secrets_store_csi_driver_provider = false
    enable_ack_apigatewayv2                      = false
    enable_ack_dynamodb                          = false
    enable_ack_s3                                = false
    enable_ack_rds                               = false
    enable_ack_prometheusservice                 = false
    enable_ack_emrcontainers                     = false
    enable_ack_sfn                               = false
    enable_ack_eventbridge                       = false
    enable_argocd                                = false
    enable_argo_rollouts                         = false
    enable_argo_events                           = false
    enable_argo_workflows                        = false
    enable_cluster_proportional_autoscaler       = false
    enable_gatekeeper                            = false
    enable_gpu_operator                          = false
    enable_ingress_nginx                         = false
    enable_kyverno                               = false
    enable_kube_prometheus_stack                 = false
    enable_metrics_server                        = false
    enable_prometheus_adapter                    = false
    enable_secrets_store_csi_driver              = false
    enable_vpa                                   = false
  }
}
