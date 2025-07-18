# Remote State Configuration
# This ensures Terraform state is stored in Azure and shared across deployments

terraform {
  backend "azurerm" {
    resource_group_name  = "healthcare-content-rg"
    storage_account_name = "healthcarestorefv0vlbg2"
    container_name       = "terraform-state"
    key                  = "healthcare-infrastructure.tfstate"
  }
}
