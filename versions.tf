terraform {
    required_version = ">= 1.6.0"

    required_providers {

       azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 3.90"
      }
      
      azuread = {
        source  = "hashicorp/azuread"
        version = "~> 2.47.0"
      }
      
    }

    backend "azurerm" {
      resource_group_name   = "rg-chatterly-tfstate"
      storage_account_name  = "stchatterlystatedev"
      container_name        = "tfsstate"
      key = "dev/terraform.tfstate"
    }
}


provider "azurerm" {
    features {
       resource_group {
        prevent_deletion_if_contains_resources = false     
       }

       key_vault {
        purge_soft_delete_on_destroy = true
       }
    }

    subscription_id = var.subscription_id

}