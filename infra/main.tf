# Terraform configuration for Azure Blob Storage for healthcare ecosystem

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Uncomment and configure for production use with remote state
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "terraformstate<random>"
  #   container_name       = "tfstate"
  #   key                  = "healthcare-app.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# Variables for customization
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "healthcare-content-rg"
}

# Use the existing storage account name directly
locals {
  storage_account_name = "healthcarestorefv0vlbg2"
}

# Use data sources for existing resources to avoid conflicts
data "azurerm_resource_group" "healthcare_rg" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "healthcare_storage" {
  name                = local.storage_account_name
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
}

data "azurerm_storage_container" "healthcare_container" {
  name                 = "healthcare-files"
  storage_account_name = data.azurerm_storage_account.healthcare_storage.name
}

# Outputs for GitHub Actions
output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.healthcare_rg.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = data.azurerm_storage_account.healthcare_storage.name
}

output "container_name" {
  description = "Name of the container"
  value       = data.azurerm_storage_container.healthcare_container.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = data.azurerm_storage_account.healthcare_storage.id
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = data.azurerm_storage_account.healthcare_storage.primary_blob_endpoint
}
