#!/bin/bash

# Terraform Import Helper Script
# This script helps import existing Azure resources into Terraform state

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Healthcare Infrastructure - Terraform Import Helper${NC}"
echo "=================================================="

# Check if Azure CLI is available
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed or not in PATH${NC}"
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Please login first:${NC}"
    echo "az login"
    exit 1
fi

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo -e "${GREEN}Using subscription: ${SUBSCRIPTION_ID}${NC}"

# Resource names
RESOURCE_GROUP_NAME="healthcare-content-rg"
STORAGE_ACCOUNT_NAME="healthcarestorefv0vlbg2"
CONTAINER_NAME="healthcare-files"

echo ""
echo "Checking for existing resources..."

# Check if resource group exists
if az group show --name "${RESOURCE_GROUP_NAME}" &>/dev/null; then
    echo -e "${YELLOW}Resource Group '${RESOURCE_GROUP_NAME}' exists${NC}"
    echo "To import: terraform import azurerm_resource_group.healthcare_rg /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}"
    IMPORT_RG=true
else
    echo -e "${GREEN}Resource Group '${RESOURCE_GROUP_NAME}' does not exist - will be created${NC}"
    IMPORT_RG=false
fi

# Check if storage account exists
if az storage account show --name "${STORAGE_ACCOUNT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" &>/dev/null; then
    echo -e "${YELLOW}Storage Account '${STORAGE_ACCOUNT_NAME}' exists${NC}"
    echo "To import: terraform import azurerm_storage_account.healthcare_storage /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.Storage/storageAccounts/${STORAGE_ACCOUNT_NAME}"
    IMPORT_STORAGE=true
else
    echo -e "${GREEN}Storage Account '${STORAGE_ACCOUNT_NAME}' does not exist - will be created${NC}"
    IMPORT_STORAGE=false
fi

# Check if storage container exists (only if storage account exists)
if [ "$IMPORT_STORAGE" = true ]; then
    # Get storage account key to check container
    STORAGE_KEY=$(az storage account keys list --resource-group "${RESOURCE_GROUP_NAME}" --account-name "${STORAGE_ACCOUNT_NAME}" --query '[0].value' --output tsv)
    
    if az storage container show --name "${CONTAINER_NAME}" --account-name "${STORAGE_ACCOUNT_NAME}" --account-key "${STORAGE_KEY}" &>/dev/null; then
        echo -e "${YELLOW}Storage Container '${CONTAINER_NAME}' exists${NC}"
        echo "To import: terraform import azurerm_storage_container.healthcare_container https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}"
        IMPORT_CONTAINER=true
    else
        echo -e "${GREEN}Storage Container '${CONTAINER_NAME}' does not exist - will be created${NC}"
        IMPORT_CONTAINER=false
    fi
else
    IMPORT_CONTAINER=false
fi

echo ""
echo "=================================================="

if [ "$IMPORT_RG" = true ] || [ "$IMPORT_STORAGE" = true ] || [ "$IMPORT_CONTAINER" = true ]; then
    echo -e "${YELLOW}Some resources already exist. You have two options:${NC}"
    echo ""
    echo "Option 1: Import existing resources (recommended)"
    echo "Run these commands before 'terraform apply':"
    echo ""
    
    if [ "$IMPORT_RG" = true ]; then
        echo "terraform import azurerm_resource_group.healthcare_rg /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}"
    fi
    
    if [ "$IMPORT_STORAGE" = true ]; then
        echo "terraform import azurerm_storage_account.healthcare_storage /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.Storage/storageAccounts/${STORAGE_ACCOUNT_NAME}"
    fi
    
    if [ "$IMPORT_CONTAINER" = true ]; then
        echo "terraform import azurerm_storage_container.healthcare_container https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}"
    fi
    
    echo ""
    echo "Option 2: Delete existing resources (destructive)"
    echo "Run these commands to delete existing resources:"
    echo ""
    
    if [ "$IMPORT_CONTAINER" = true ]; then
        echo "az storage container delete --name ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --account-key [STORAGE_KEY]"
    fi
    
    if [ "$IMPORT_STORAGE" = true ]; then
        echo "az storage account delete --name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP_NAME} --yes"
    fi
    
    if [ "$IMPORT_RG" = true ]; then
        echo "az group delete --name ${RESOURCE_GROUP_NAME} --yes"
    fi
    
else
    echo -e "${GREEN}No existing resources found. You can run 'terraform apply' directly.${NC}"
fi

echo ""
echo "=================================================="
echo -e "${GREEN}Import helper completed${NC}"
