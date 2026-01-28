variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "replicas" {
  description = "Number of pod replicas for HA"
  type        = number
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
}

variable "memory_request" {
  description = "Memory request"
  type        = string
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
}

variable "cpu_request" {
  description = "CPU request"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
}