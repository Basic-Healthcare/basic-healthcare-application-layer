# Azure GitHub Actions Setup Guide

This guide will help you configure GitHub Actions to deploy your healthcare application to Azure.

## Prerequisites

1. ✅ Azure Application Registration (you've already created this)
2. ✅ GitHub repository (this one)
3. Azure subscription with appropriate permissions

## Setup Steps

### 1. Create Azure Service Principal (if not done already)

If you haven't created a service principal yet, run these commands in Azure CLI:

```bash
# Login to Azure
az login

# Create service principal
az ad sp create-for-rbac --name "github-actions-healthcare" --role contributor --scopes /subscriptions/{subscription-id} --sdk-auth
```

Save the JSON output - you'll need it for GitHub secrets.

### 2. Configure GitHub Secrets

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add these secrets:

#### Required Secrets:

- `AZURE_CREDENTIALS`: The complete JSON output from the service principal creation
- `ARM_CLIENT_ID`: The client ID from your application registration
- `ARM_CLIENT_SECRET`: The client secret from your application registration
- `ARM_SUBSCRIPTION_ID`: Your Azure subscription ID
- `ARM_TENANT_ID`: Your Azure tenant ID

#### Example AZURE_CREDENTIALS format:

```json

```

### 3. Configure Terraform Backend (Recommended)

For production use, configure a remote backend for Terraform state. Add this to your `infra/main.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstate<random>"
    container_name       = "tfstate"
    key                  = "healthcare-app.terraform.tfstate"
  }
}
```

### 4. Environment Protection (Optional but Recommended)

1. Go to **Settings > Environments** in your GitHub repository
2. Create a new environment called "production"
3. Add protection rules:
   - Required reviewers
   - Wait timer
   - Deployment branches (restrict to main branch)

## Workflow Overview

The GitHub Actions workflow (`azure-deploy.yml`) includes:

1. **Terraform Plan**: Validates infrastructure changes on every push/PR
2. **Terraform Apply**: Deploys infrastructure changes (main branch only)
3. **Test Python App**: Validates Python code syntax and dependencies
4. **Deploy Application**: Tests the application deployment to Azure

## Manual Deployment

To manually trigger deployment:

1. Go to **Actions** tab in GitHub
2. Select "Deploy to Azure" workflow
3. Click "Run workflow"
4. Choose the branch and click "Run workflow"

## Local Development

To test locally:

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export AZURE_STORAGE_CONNECTION_STRING="your-connection-string"

# Test upload
python upload_to_blob.py
```

## Troubleshooting

### Common Issues:

1. **Authentication errors**: Verify all GitHub secrets are correctly set
2. **Terraform errors**: Check Azure permissions for the service principal
3. **Storage access errors**: Ensure the storage account exists and permissions are correct

### Getting Help:

- Check the Actions logs for detailed error messages
- Verify Azure resource permissions
- Ensure all secrets are properly configured

## Security Best Practices

1. ✅ Use GitHub environments for production deployments
2. ✅ Restrict workflow permissions to minimum required
3. ✅ Enable branch protection on main branch
4. ✅ Use Azure Key Vault for sensitive configuration (future enhancement)
5. ✅ Regular secret rotation

## Next Steps

1. Set up the GitHub secrets as described above
2. Test the workflow by pushing to a feature branch
3. Merge to main to trigger full deployment
4. Monitor the deployment in GitHub Actions

---

**Note**: Replace placeholder values like `{subscription-id}` with your actual Azure subscription ID.
