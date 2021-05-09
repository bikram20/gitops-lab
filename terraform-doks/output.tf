output "cluster_id" {
  description = "DOKS cluster ID."
  value       = digitalocean_kubernetes_cluster.gitopslab.id
}

output "cluster_endpoint" {
  description = "Endpoint for DOKS control plane."
  value       = digitalocean_kubernetes_cluster.gitopslab.endpoint
}

