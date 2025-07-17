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

resource "azurerm_resource_group" "healthcare_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "HealthcareApp"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_storage_account" "healthcare_storage" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.healthcare_rg.name
  location                 = azurerm_resource_group.healthcare_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Security settings
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  tags = {
    Environment = var.environment
    Project     = "HealthcareApp"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_storage_container" "healthcare_container" {
  name                  = "healthcare-files"
  storage_account_name  = azurerm_storage_account.healthcare_storage.name
  container_access_type = "private"
}

# Outputs for GitHub Actions
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.healthcare_rg.name
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.healthcare_storage.name
}

output "container_name" {
  description = "Name of the created container"
  value       = azurerm_storage_container.healthcare_container.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.healthcare_storage.id
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.healthcare_storage.primary_blob_endpoint
}
