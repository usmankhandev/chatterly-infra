variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string
}

variable "environment" {
    type = string
}

variable "name_prefix" {
    type = string
}

variable "aks_subnet_id" {
    type = string
}

variable "app_subnet_id" {
    type = string
}

variable "tags" {
    type    = map(string)
    default = {}
}




