output "kubeconfig" {
  value       = try(talos_cluster_kubeconfig.this[0].kubeconfig_raw, null)
  sensitive   = true
  description = "Kubeconfig for the Talos-managed Kubernetes cluster"
}
