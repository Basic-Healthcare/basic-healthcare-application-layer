# GitHub Repository Secrets Setup

To make the GitHub Actions workflow work properly, you need to configure these secrets in your GitHub repository.

## Required Secrets

Based on your current Azure configuration:

- **Subscription ID**: `82ba81d8-2ee1-4c98-87ce-dc378bef4592`
- **Tenant ID**: `af92ba44-eb1c-4c36-8d68-f210cf8b1ad0`

## Step 1: Create Service Principal

Run this command to create a Service Principal for GitHub Actions:

```bash
az ad sp create-for-rbac --name "github-actions-healthcare" \
  --role contributor \
  --scopes /subscriptions/82ba81d8-2ee1-4c98-87ce-dc378bef4592 \
  --json-auth
```

This will output JSON like:
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "82ba81d8-2ee1-4c98-87ce-dc378bef4592",
  "tenantId": "af92ba44-eb1c-4c36-8d68-f210cf8b1ad0",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

## Step 2: Add Secrets to GitHub Repository

Go to your GitHub repository: `https://github.com/Basic-Healthcare/basic-healthcare-application-layer/settings/secrets/actions`

Add these secrets:

1. **AZURE_CREDENTIALS** = The entire JSON output from step 1
2. **ARM_CLIENT_ID** = The `clientId` from the JSON
3. **ARM_CLIENT_SECRET** = The `clientSecret` from the JSON  
4. **ARM_SUBSCRIPTION_ID** = `82ba81d8-2ee1-4c98-87ce-dc378bef4592`
5. **ARM_TENANT_ID** = `af92ba44-eb1c-4c36-8d68-f210cf8b1ad0`

## Step 3: Test the Workflow

After adding the secrets, push a commit to trigger the GitHub Actions workflow and verify it works.

## Local Development Setup

For local development, you can continue using Azure CLI authentication:

1. Keep the `backend.tf` file renamed or commented out: `mv backend.tf backend.tf.disabled`
2. Use `terraform init` and `terraform plan/apply` as normal
3. When you want to switch back to remote state: `mv backend.tf.disabled backend.tf` and `terraform init -migrate-state`

## Important Notes

- The Service Principal needs `Contributor` role on the subscription to create/manage resources
- The remote state storage account (`healthcarestorefv0vlbg2`) must exist before running GitHub Actions
- GitHub Actions will use remote state, local development can use local state
