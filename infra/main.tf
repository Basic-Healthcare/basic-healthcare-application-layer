# Terraform configuration for existing Azure healthcare infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
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

# Data sources for existing resources
data "azurerm_resource_group" "healthcare_rg" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "healthcare_storage" {
  name                = "healthcarestorefv0vlbg2"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
}

data "azurerm_storage_container" "healthcare_container" {
  name                 = "healthcare-files"
  storage_account_name = data.azurerm_storage_account.healthcare_storage.name
}

# Use existing service plan
data "azurerm_service_plan" "healthcare_plan" {
  name                = "healthcare-function-plan"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
}

# Use existing function app
data "azurerm_linux_function_app" "healthcare_function" {
  name                = "healthcare-file-api-4fc0533d"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
}

# Use existing API Management
data "azurerm_api_management" "healthcare_apim" {
  name                = "healthcare-api-64e194e6"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
}

# Outputs for GitHub Actions and reference
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

output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = data.azurerm_linux_function_app.healthcare_function.name
}

output "function_app_url" {
  description = "URL of the Azure Function App"
  value       = "https://${data.azurerm_linux_function_app.healthcare_function.default_hostname}"
}

output "api_management_name" {
  description = "Name of the API Management instance"
  value       = data.azurerm_api_management.healthcare_apim.name
}

output "api_management_gateway_url" {
  description = "Gateway URL of the API Management instance"
  value       = data.azurerm_api_management.healthcare_apim.gateway_url
}

output "file_upload_api_url" {
  description = "Complete URL for the file upload API"
  value       = "${data.azurerm_api_management.healthcare_apim.gateway_url}/files/upload"
}
