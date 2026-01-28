output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.apps.metadata[0].name
}

output "deployment_name" {
  description = "Deployment name"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "replicas" {
  description = "Number of replicas"
  value       = kubernetes_deployment.app.spec[0].replicas
}