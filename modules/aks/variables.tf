variable "cluster_name" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string
}

variable "kubernetes_version" {
    type = string
    default = "1.30"
}

variable "dns_prefix" {
    type = string
}

variable "node_count" {
    type = number
    default = 1
}

variable "node_size" {
    type = string
    default = "Standard_B2ms"
}

variable "min_count" {
  type    = number
  default = 1
}

variable "max_count" {
  type    = number
  default = 3
}

variable "vnet_subnet_id" {
  type = string
}

variable "acr_id" {
  description = "ACR resource ID to grant AcrPull. Leave empty to skip."
  type        = string
  default     = ""
  nullable    = true
}

variable "tags" {
  type    = map(string)
  default = {}
}