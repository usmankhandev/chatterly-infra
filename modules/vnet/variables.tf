variable "name" {
    description = "VNET Name"
    type = string
}

variable "resource_group_name" {
    description = "Resource Group Name to deploy into"
    type = string
}  

variable "location" {
    description = "Azure region"
    type = string
}

variable "address_space" {
    description = "VNET address space"
    type = list(string)
}

variable "aks_subnet_cidr" {
    description = "CIDR for AKS node subnet"
    type = string
}

variable "app_subnet_cidr" {
    description = "CIDR for app subnet"
    type = string
}

variable "tags" {
    description = "Tags"
    type = map(string)
    default = {}
}