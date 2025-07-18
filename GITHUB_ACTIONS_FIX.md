# GitHub Actions Service Principal Authentication Fix

## The Problem

You're getting this error in GitHub Actions:
```
Error: Error building ARM Config: Authenticating using the Azure CLI is only supported as a User (not a Service Principal).
```

## Root Cause

The Terraform Azure backend requires Service Principal authentication when running in GitHub Actions, but either:
1. The ARM environment variables are not properly set
2. The Service Principal doesn't have the right permissions
3. The GitHub secrets are not configured correctly

## Solution Steps

### Step 1: Set up Service Principal with correct permissions

Run this script locally (you need to be logged in with `az login`):

```bash
./setup-service-principal.sh
```

This will:
- Create a Service Principal with the right permissions
- Grant it access to your storage account for Terraform state
- Display the exact values you need for GitHub secrets

### Step 2: Add GitHub Secrets

Go to your repository: https://github.com/Basic-Healthcare/basic-healthcare-application-layer/settings/secrets/actions

Add these 5 secrets exactly as shown in the script output:
- `AZURE_CREDENTIALS`
- `ARM_CLIENT_ID` 
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

### Step 3: Verify the GitHub Actions workflow

The workflow should already be correctly configured with these sections:

```yaml
- name: Setup Remote State Storage
  run: |
    az storage container create \
      --name terraform-state \
      --account-name healthcarestorefv0vlbg2 \
      --resource-group healthcare-content-rg \
      --public-access off \
      --only-show-errors || true
  env:
    ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
    ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
    ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
    ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}

- name: Terraform Init
  run: terraform init -upgrade
  env:
    ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
    ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
    ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
    ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
```

### Step 4: Test

Push a commit to trigger the GitHub Actions workflow and verify it works.

## Common Issues

### Issue: "ResourceGroupNotFound" 
**Solution**: Ensure the resource group `healthcare-content-rg` exists

### Issue: "Storage account not found"
**Solution**: Ensure the storage account `healthcarestorefv0vlbg2` exists

### Issue: "Insufficient permissions"
**Solution**: The Service Principal needs these roles:
- `Contributor` on the subscription
- `Storage Account Contributor` on the storage account  
- `Storage Blob Data Contributor` on the storage account

### Issue: Still getting Azure CLI authentication error
**Solution**: 
1. Double-check all 5 GitHub secrets are set correctly
2. Verify the Service Principal has the right permissions
3. Try recreating the Service Principal with the setup script

## Local Development

For local development, you can continue using Azure CLI authentication:
1. Rename backend.tf: `mv backend.tf backend.tf.disabled`
2. Run: `terraform init` (will use local state)
3. Work normally with `terraform plan` and `terraform apply`
4. When done: `mv backend.tf.disabled backend.tf`
