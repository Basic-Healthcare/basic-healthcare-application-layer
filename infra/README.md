# Healthcare Infrastructure - Terraform Configuration

This directory contains the Terraform configuration for the Azure healthcare file upload infrastructure.

## Features

- **Resilient Deployments**: Handles multiple redeployments and resource deletions gracefully
- **Lifecycle Management**: Resources have appropriate lifecycle rules to prevent accidental destruction
- **Import Support**: Helper scripts to import existing resources into Terraform state
- **Flexible Configuration**: Variables for different environments and configurations

## Quick Start

### Option 1: Fresh Deployment

If you're starting fresh with no existing resources:

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### Option 2: Existing Resources

If you have existing resources that need to be managed by Terraform:

1. **Check for existing resources:**
   ```bash
   ./import_helper.sh
   ```

2. **Import existing resources (if any):**
   ```bash
   # Example commands provided by import_helper.sh
   terraform import azurerm_resource_group.healthcare_rg /subscriptions/{subscription-id}/resourceGroups/healthcare-content-rg
   terraform import azurerm_storage_account.healthcare_storage /subscriptions/{subscription-id}/resourceGroups/healthcare-content-rg/providers/Microsoft.Storage/storageAccounts/healthcarestorefv0vlbg2
   ```

3. **Apply configuration:**
   ```bash
   terraform plan
   terraform apply
   ```

## Resource Management

### Lifecycle Rules

The configuration includes several lifecycle rules to make deployments more resilient:

- **prevent_destroy**: Applied to critical resources (resource group, storage account, container)
- **create_before_destroy**: Applied to replaceable resources (function app, API management)
- **ignore_changes**: Ignores changes to auto-generated tags and dynamic settings

### Resource Naming

- **Resource Group**: Uses fixed name from variable (default: `healthcare-content-rg`)
- **Storage Account**: Uses fixed name (`healthcarestorefv0vlbg2`)
- **Function App**: Uses random suffix for uniqueness (`healthcare-file-api-{random}`)
- **API Management**: Uses random suffix for uniqueness (`healthcare-api-{random}`)

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name (dev, staging, prod) | `dev` |
| `location` | Azure region for resources | `East US` |
| `resource_group_name` | Name of the resource group | `healthcare-content-rg` |

## Troubleshooting

### Resource Already Exists Error

If you see errors like "A resource with the ID ... already exists", you have two options:

1. **Import the resource** (recommended):
   ```bash
   terraform import <resource_type>.<resource_name> <azure_resource_id>
   ```

2. **Delete the existing resource** (destructive):
   ```bash
   az group delete --name healthcare-content-rg --yes
   ```

### Import Helper

Use the import helper script to identify existing resources:

```bash
./import_helper.sh
```

This script will:
- Check for existing Azure resources
- Provide exact import commands
- Show deletion commands if you prefer to start fresh

### Manual Import Commands

If you need to import resources manually:

```bash
# Resource Group
terraform import azurerm_resource_group.healthcare_rg /subscriptions/{subscription-id}/resourceGroups/healthcare-content-rg

# Storage Account
terraform import azurerm_storage_account.healthcare_storage /subscriptions/{subscription-id}/resourceGroups/healthcare-content-rg/providers/Microsoft.Storage/storageAccounts/healthcarestorefv0vlbg2

# Storage Container
terraform import azurerm_storage_container.healthcare_container https://healthcarestorefv0vlbg2.blob.core.windows.net/healthcare-files
```

## CI/CD Integration

The configuration is designed to work seamlessly with GitHub Actions:

- **Idempotent**: Can be run multiple times safely
- **State Management**: Uses appropriate lifecycle rules
- **Output Values**: Provides all necessary outputs for deployment scripts

## Security Considerations

- **Storage Account**: Uses private containers
- **Function App**: Configured with CORS for web access
- **API Management**: Uses consumption tier for cost optimization
- **Lifecycle Protection**: Critical resources protected from accidental deletion

## Outputs

The configuration provides the following outputs for use in CI/CD:

- `resource_group_name`: Name of the resource group
- `storage_account_name`: Name of the storage account
- `function_app_name`: Name of the Azure Function App
- `api_management_gateway_url`: Gateway URL for API Management
- `file_upload_api_url`: Complete URL for the file upload endpoint

## Support

For issues with the infrastructure deployment:

1. Check the import helper: `./import_helper.sh`
2. Review Terraform state: `terraform state list`
3. Check Azure resources: `az resource list --resource-group healthcare-content-rg`
4. Validate configuration: `terraform validate`
5. Plan changes: `terraform plan`
