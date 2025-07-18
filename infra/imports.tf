# Terraform Import Configuration
# This file defines how to import existing resources automatically
# Enabled to import resources that already exist in Azure

# Import existing resource group
import {
  to = azurerm_resource_group.healthcare_rg
  id = "/subscriptions/82ba81d8-2ee1-4c98-87ce-dc378bef4592/resourceGroups/healthcare-content-rg"
}

# Import existing storage account
import {
  to = azurerm_storage_account.healthcare_storage
  id = "/subscriptions/82ba81d8-2ee1-4c98-87ce-dc378bef4592/resourceGroups/healthcare-content-rg/providers/Microsoft.Storage/storageAccounts/healthcarestorefv0vlbg2"
}

# import {
#   to = azurerm_storage_container.healthcare_container
#   id = "https://healthcarestorefv0vlbg2.blob.core.windows.net/healthcare-files"
# }
