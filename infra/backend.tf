# Remote State Configuration
# This ensures Terraform state is stored in Azure and shared across deployments
# When using Service Principal authentication (GitHub Actions), the ARM_* environment variables
# will be used automatically for backend authentication

terraform {
  backend "azurerm" {
    resource_group_name  = "healthcare-content-rg"
    storage_account_name = "healthcarestorefv0vlbg2"
    container_name       = "terraform-state"
    key                  = "healthcare-infrastructure.tfstate"
    # ARM environment variables will be used for authentication:
    # ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
  }
}
