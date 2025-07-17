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

# Create Azure Function App for file upload API
resource "azurerm_service_plan" "healthcare_plan" {
  name                = "healthcare-function-plan"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
  location            = data.azurerm_resource_group.healthcare_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"  # Consumption plan

  tags = {
    Environment = var.environment
    Project     = "HealthcareApp"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_linux_function_app" "healthcare_function" {
  name                = "healthcare-file-api-${random_id.function_suffix.id}"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
  location            = data.azurerm_resource_group.healthcare_rg.location
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
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "AzureWebJobsFeatureFlags"              = "EnableWorkerIndexing"
    "AZURE_STORAGE_CONNECTION_STRING"       = data.azurerm_storage_account.healthcare_storage.primary_connection_string
    "HEALTHCARE_CONTAINER_NAME"             = data.azurerm_storage_container.healthcare_container.name
  }

  tags = {
    Environment = var.environment
    Project     = "HealthcareApp"
    ManagedBy   = "Terraform"
  }
}

# Random ID for globally unique function app name
resource "random_id" "function_suffix" {
  byte_length = 6
}

# Create API Management instance
resource "azurerm_api_management" "healthcare_apim" {
  name                = "healthcare-api-${random_id.apim_suffix.id}"
  location            = data.azurerm_resource_group.healthcare_rg.location
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

# Random ID for globally unique APIM name
resource "random_id" "apim_suffix" {
  byte_length = 4
}

# API Management API
resource "azurerm_api_management_api" "healthcare_api" {
  name                = "healthcare-file-api"
  resource_group_name = data.azurerm_resource_group.healthcare_rg.name
  api_management_name = azurerm_api_management.healthcare_apim.name
  revision            = "1"
  display_name        = "Healthcare File Upload API"
  path                = "files"
  protocols           = ["https"]

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
                        message = { type = "string" }
                        fileUrl = { type = "string" }
                        fileName = { type = "string" }
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
