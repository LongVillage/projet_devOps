###########################################################
# outputs.tf
###########################################################
output "vpc_id" {
  description = "ID de la VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Le nom du cluster EKS"
  value       = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint EKS"
  value       = data.aws_eks_cluster.cluster.endpoint
}

output "lb_controller_chart_version" {
  description = "Version helm du LB Controller"
  value       = helm_release.aws_load_balancer_controller.version
}
