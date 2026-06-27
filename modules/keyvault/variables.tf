variable "name" {
  description = "Key Vault name (globally unique, 3-24 chars)"
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "kubelet_identity_object_id" {
  description = "AKS kubelet managed identity object ID"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}