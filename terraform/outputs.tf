output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint

}

output "Cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}