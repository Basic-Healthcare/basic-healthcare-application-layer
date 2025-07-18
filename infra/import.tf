# Import existing resources if they exist
# This file helps with importing existing resources into Terraform state

# Import commands for existing resources (run these manually if resources exist):
# terraform import azurerm_resource_group.healthcare_rg /subscriptions/{subscription-id}/resourceGroups/healthcare-content-rg
# terraform import azurerm_storage_account.healthcare_storage /subscriptions/{subscription-id}/resourceGroups/healthcare-content-rg/providers/Microsoft.Storage/storageAccounts/healthcarestorefv0vlbg2
# terraform import azurerm_storage_container.healthcare_container https://healthcarestorefv0vlbg2.blob.core.windows.net/healthcare-files

# To check existing resources, you can use:
# az group show --name healthcare-content-rg
# az storage account show --name healthcarestorefv0vlbg2 --resource-group healthcare-content-rg
