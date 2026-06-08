variable "name" {
    description = "Resource group name"
    type = string
}

variable "location" {
    description = "Azure region"
    type = string
}

variable "tags" {
    description = "Tags to Apply"
    type = map(string)
    default = {}
}

