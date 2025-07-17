# Basic Healthcare Application Layer

A healthcare application with Azure Blob Storage integration and automated deployment via GitHub Actions.

## Features

- 🏥 Healthcare file storage with Azure Blob Storage
- 🚀 Automated infrastructure deployment with Terraform
- ⚡ Continuous integration and deployment with GitHub Actions
- 🐍 Python-based file upload functionality
- 🔒 Secure authentication with Azure service principals

## Architecture

- **Infrastructure**: Terraform for Azure resource management
- **Storage**: Azure Blob Storage for healthcare files
- **CI/CD**: GitHub Actions for automated testing and deployment
- **Application**: Python scripts for interacting with Azure services

## Quick Start

### Prerequisites

- Azure subscription
- GitHub repository access
- Azure CLI installed locally (for initial setup)

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd basic-healthcare-application-layer
   ```

2. **Configure Azure authentication**

   - Follow the detailed setup guide in [AZURE_SETUP.md](./AZURE_SETUP.md)
   - Create GitHub secrets for Azure authentication

3. **Deploy infrastructure**
   - Push to main branch to trigger automatic deployment
   - Or manually trigger the workflow in GitHub Actions

### Local Development

```bash
# Install Python dependencies
pip install -r requirements.txt

# Set up environment variables
export AZURE_STORAGE_CONNECTION_STRING="your-connection-string"

# Test the upload functionality
python upload_to_blob.py
```

## Project Structure

```
├── .github/
│   └── workflows/          # GitHub Actions workflows
│       ├── azure-deploy.yml    # Main deployment workflow
│       └── test.yml            # Testing workflow
├── infra/
│   └── main.tf            # Terraform infrastructure configuration
├── upload_to_blob.py      # Python script for Azure Blob upload
├── requirements.txt       # Python dependencies
├── AZURE_SETUP.md        # Detailed Azure setup instructions
└── README.md             # This file
```

## GitHub Actions Workflows

### 🚀 Azure Deploy (`azure-deploy.yml`)

- **Trigger**: Push to main branch, manual dispatch
- **Jobs**:
  - Terraform planning and validation
  - Infrastructure deployment
  - Python application testing
  - Application deployment verification

### 🧪 Test (`test.yml`)

- **Trigger**: Push to any branch, pull requests
- **Purpose**: Code quality checks and syntax validation
- **Matrix**: Tests across Python 3.9, 3.10, and 3.11

## Security

- Azure authentication via service principal
- GitHub secrets for sensitive configuration
- Environment protection for production deployments
- Minimal required permissions principle

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Ensure tests pass locally
4. Create a pull request
5. Wait for CI/CD checks to pass
6. Merge after review

## Documentation

- [Azure Setup Guide](./AZURE_SETUP.md) - Complete setup instructions
- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Blob Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/blobs/)

## Support

For issues and questions:

1. Check the GitHub Actions logs for deployment issues
2. Review the Azure Setup guide for configuration problems
3. Create an issue in this repository

---

**Next Steps**: Follow the [Azure Setup Guide](./AZURE_SETUP.md) to configure your GitHub repository for automated deployment.
