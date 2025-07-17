# Terraform configuration for Azure healthcare infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
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

# Random suffixes for unique resource names
resource "random_id" "function_suffix" {
  byte_length = 6
}

resource "random_id" "apim_suffix" {
  byte_length = 4
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

# Create new Azure Service Plan
resource "azurerm_service_plan" "healthcare_plan" {
  name                = "healthcare-function-plan-${random_id.function_suffix.hex}"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = {
    Environment = var.environment
    Project     = "HealthcareApp"
    ManagedBy   = "Terraform"
  }
}

# Create new Azure Function App
resource "azurerm_linux_function_app" "healthcare_function" {
  name                = "healthcare-file-api-${random_id.function_suffix.hex}"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.healthcare_plan.id

  storage_account_name       = data.azurerm_storage_account.healthcare_storage.name
  storage_account_access_key = data.azurerm_storage_account.healthcare_storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"        = "python"
    "AzureWebJobsFeatureFlags"        = "EnableWorkerIndexing"
    "AZURE_STORAGE_CONNECTION_STRING" = data.azurerm_storage_account.healthcare_storage.primary_connection_string
    "HEALTHCARE_CONTAINER_NAME"       = data.azurerm_storage_container.healthcare_container.name
  }

  tags = {
    Environment = var.environment
    Project     = "HealthcareApp"
    ManagedBy   = "Terraform"
  }
}

# Create new API Management
resource "azurerm_api_management" "healthcare_apim" {
  name                = "healthcare-api-${random_id.apim_suffix.hex}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
  publisher_name      = "Healthcare Organization"
  publisher_email     = "admin@healthcare.local"
  sku_name            = "Consumption_0"

  tags = {
    Environment = var.environment
    Project     = "HealthcareApp"
    ManagedBy   = "Terraform"
  }
}

# API Management API definition
resource "azurerm_api_management_api" "healthcare_api" {
  name                = "healthcare-file-api"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
  api_management_name = azurerm_api_management.healthcare_apim.name
  revision            = "1"
  display_name        = "Healthcare File Upload API"
  path                = "files"
  protocols           = ["https"]
  subscription_required = false

  import {
    content_format = "openapi+json"
    content_value = jsonencode({
      openapi = "3.0.0"
      info = {
        title   = "Healthcare File Upload API"
        version = "1.0.0"
      }
      paths = {
        "/upload" = {
          post = {
            summary     = "Upload a healthcare file"
            operationId = "uploadFile"
            requestBody = {
              content = {
                "multipart/form-data" = {
                  schema = {
                    type = "object"
                    properties = {
                      file = {
                        type   = "string"
                        format = "binary"
                      }
                      fileName = {
                        type = "string"
                      }
                    }
                    required = ["file"]
                  }
                }
              }
            }
            responses = {
              "200" = {
                description = "File uploaded successfully"
                content = {
                  "application/json" = {
                    schema = {
                      type = "object"
                      properties = {
                        message  = { type = "string" }
                        fileName = { type = "string" }
                        fileUrl  = { type = "string" }
                      }
                    }
                  }
                }
              }
              "400" = {
                description = "Bad request"
              }
              "500" = {
                description = "Internal server error"
              }
            }
          }
        }
      }
    })
  }
}

# API Management Backend
resource "azurerm_api_management_backend" "healthcare_backend" {
  name                = "healthcare-function-backend"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
  api_management_name = azurerm_api_management.healthcare_apim.name
  protocol            = "http"
  url                 = "https://${azurerm_linux_function_app.healthcare_function.default_hostname}/api"
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
  value       = azurerm_linux_function_app.healthcare_function.name
}

output "function_app_url" {
  description = "URL of the Azure Function App"
  value       = "https://${azurerm_linux_function_app.healthcare_function.default_hostname}"
}

output "api_management_name" {
  description = "Name of the API Management instance"
  value       = azurerm_api_management.healthcare_apim.name
}

output "api_management_gateway_url" {
  description = "Gateway URL of the API Management instance"
  value       = azurerm_api_management.healthcare_apim.gateway_url
}

output "file_upload_api_url" {
  description = "Complete URL for the file upload API"
  value       = "${azurerm_api_management.healthcare_apim.gateway_url}/files/upload"
}
