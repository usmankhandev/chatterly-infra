variable "subscription_id" {
    description = "Azure Subscription ID"
    type = string
}

variable "environment" {
    description = "Enviornment name (dev, staging, prod)"
    type = string
    validation {
        condition = contains(["dev", "staging", "prod"], var.environment)
        error_message = "Invalid environment. Please choose from dev, staging, or prod."
    }
}

variable "location" {
    description = "Azure region for resource deployment"
    type = string
    default = "eastus"
}

variable "project" {
    description = "Project name used in all resource naming convention"
    type = string
    default = "chatterly"
}


variable "tags" {
    description = "Common tags applied to all resources"
    type = map(string)
    default = {}
}

# ---- Networking Variables----

variable "vnet_address_space" {
    description = "VNet CIDR block for the virtual network"
    type = list(string)
    default = ["10.0.0.0/16"]
}

variable "aks_cluster_cidr" {
    description = "CIDR block for AKS Cluster"
    type = string
    default = "10.0.1.0/24"
}

variable "aks_subnet_cidr" {
    description = "CIDR block for the AKS subnet"
    type        = string
    default = "10.0.1.0/24"
}

variable "app_subnet_cidr" {
    description = "CIDR block for application subnet"
    type = string
    default = "10.0.2.0/24"
}

# ------ AKS Variablrs -------


variable "aks_node_count" {
    description = "Initial node count for the default node pool in AKS"
    type = number
    default = 1
}

variable "aks_node_size" {
    description = "Minimum nodes for autoscaler"
    type = string
    default = "Standard_B2ms"
}

variable "aks_min_count" {
    description = "Minimum nodes for autoscaler"
    type = number
    default = 1
}

variable "aks_max_count" {
  description = "Maximum nodes for autoscaler"
  type        = number
  default     = 3
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.30"
}

