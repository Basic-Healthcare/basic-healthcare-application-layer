#!/bin/bash

# Setup Remote State Storage for Terraform
# This script creates the necessary Azure resources to store Terraform state remotely

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Terraform Remote State Storage${NC}"
echo "=============================================="

# Configuration
RESOURCE_GROUP_NAME="healthcare-content-rg"
STORAGE_ACCOUNT_NAME="healthcarestorefv0vlbg2"
CONTAINER_NAME="terraform-state"

# Check if Azure CLI is available
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Please login to Azure first:${NC}"
    echo "az login"
    exit 1
fi

echo -e "${GREEN}✓ Azure CLI is available and logged in${NC}"

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo -e "${GREEN}Using subscription: ${SUBSCRIPTION_ID}${NC}"

# Check if resource group exists
if az group show --name "${RESOURCE_GROUP_NAME}" &>/dev/null; then
    echo -e "${GREEN}✓ Resource group '${RESOURCE_GROUP_NAME}' exists${NC}"
else
    echo -e "${YELLOW}⚠ Resource group '${RESOURCE_GROUP_NAME}' does not exist${NC}"
    echo "Creating resource group..."
    az group create --name "${RESOURCE_GROUP_NAME}" --location "East US"
    echo -e "${GREEN}✓ Resource group created${NC}"
fi

# Check if storage account exists
if az storage account show --name "${STORAGE_ACCOUNT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" &>/dev/null; then
    echo -e "${GREEN}✓ Storage account '${STORAGE_ACCOUNT_NAME}' exists${NC}"
else
    echo -e "${YELLOW}⚠ Storage account '${STORAGE_ACCOUNT_NAME}' does not exist${NC}"
    echo "Creating storage account..."
    az storage account create \
        --name "${STORAGE_ACCOUNT_NAME}" \
        --resource-group "${RESOURCE_GROUP_NAME}" \
        --location "East US" \
        --sku Standard_LRS \
        --encryption-services blob
    echo -e "${GREEN}✓ Storage account created${NC}"
fi

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --query '[0].value' --output tsv)

# Check if container exists
if az storage container show \
    --name "${CONTAINER_NAME}" \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --account-key "${STORAGE_KEY}" &>/dev/null; then
    echo -e "${GREEN}✓ Container '${CONTAINER_NAME}' exists${NC}"
else
    echo -e "${YELLOW}⚠ Container '${CONTAINER_NAME}' does not exist${NC}"
    echo "Creating container..."
    az storage container create \
        --name "${CONTAINER_NAME}" \
        --account-name "${STORAGE_ACCOUNT_NAME}" \
        --account-key "${STORAGE_KEY}" \
        --public-access off
    echo -e "${GREEN}✓ Container created${NC}"
fi

echo ""
echo -e "${GREEN}✅ Remote state storage is ready!${NC}"
echo ""
echo "Backend configuration:"
echo "  Resource Group: ${RESOURCE_GROUP_NAME}"
echo "  Storage Account: ${STORAGE_ACCOUNT_NAME}"
echo "  Container: ${CONTAINER_NAME}"
echo "  State File: healthcare-infrastructure.tfstate"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Run: terraform init -reconfigure"
echo "2. Your state will be stored remotely and shared across deployments"
echo "3. GitHub Actions will use the same state automatically"
echo ""
echo -e "${YELLOW}Important: The state file is now stored remotely in Azure${NC}"
echo "This means multiple people/systems can safely run Terraform on this infrastructure"
