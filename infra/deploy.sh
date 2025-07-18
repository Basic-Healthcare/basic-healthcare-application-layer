#!/bin/bash

# Complete Terraform Deployment Script
# This script handles the entire deployment process including state management


set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Healthcare Infrastructure Deployment${NC}"
echo "====================================="

# Change to the infra directory
cd "$(dirname "$0")"

# Step 1: Setup remote state if needed
echo -e "${BLUE}Step 1: Setting up remote state storage${NC}"
./setup-remote-state.sh

echo ""
echo -e "${BLUE}Step 2: Initializing Terraform with remote backend${NC}"

# Check if backend is already configured
if [ -f ".terraform/terraform.tfstate" ]; then
    echo -e "${YELLOW}Local state detected. Migrating to remote backend...${NC}"
    terraform init -reconfigure -upgrade
else
    terraform init -upgrade
fi

echo ""
echo -e "${BLUE}Step 3: Validating Terraform configuration${NC}"
terraform validate

echo ""
echo -e "${BLUE}Step 4: Planning deployment${NC}"
terraform plan -out=tfplan

echo ""
echo -e "${YELLOW}Review the plan above. Do you want to apply these changes? (y/N)${NC}"
read -r REPLY
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    rm -f tfplan
    exit 0
fi

echo ""
echo -e "${BLUE}Step 5: Applying changes${NC}"
terraform apply tfplan

echo ""
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"

# Clean up plan file
rm -f tfplan

echo ""
echo -e "${BLUE}Deployment Summary:${NC}"
echo "=================="
terraform output

echo ""
echo -e "${GREEN}Your infrastructure is now deployed and managed remotely!${NC}"
echo -e "${YELLOW}Future deployments will use the remote state automatically.${NC}"
