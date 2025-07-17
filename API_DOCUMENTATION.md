# Healthcare File Upload API

A simple, secure API for uploading healthcare files to Azure Blob Storage using Azure Functions and API Management.

## Architecture

```
Client Application
    ↓ (HTTPS POST)
Azure API Management
    ↓ (forwards request)
Azure Function App
    ↓ (uploads file)
Azure Blob Storage (healthcare-files container)
```

## API Endpoint

**Base URL**: Provided by Terraform output `api_management_gateway_url`  
**Endpoint**: `POST /files/upload`  
**Content-Type**: `multipart/form-data`

## Request Format

### Headers
- `Content-Type: multipart/form-data`
- `Ocp-Apim-Subscription-Key: <your-api-key>` (if API key is configured)

### Body Parameters
- `file` (required): The file to upload (binary data)
- `fileName` (optional): Custom file name

### Example using cURL
```bash
curl -X POST "https://your-apim.azure-api.net/files/upload" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/path/to/your/file.pdf"
```

### Example using Python
```python
import requests

url = "https://your-apim.azure-api.net/files/upload"
files = {'file': open('document.pdf', 'rb')}

response = requests.post(url, files=files)
if response.status_code == 200:
    result = response.json()
    print(f"File uploaded: {result['fileUrl']}")
else:
    print(f"Upload failed: {response.status_code}")
```

### Example using JavaScript (Browser)
```javascript
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch('https://your-apim.azure-api.net/files/upload', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => {
    console.log('Upload successful:', data.fileUrl);
})
.catch(error => {
    console.error('Upload failed:', error);
});
```

## Response Format

### Success Response (200)
```json
{
  "message": "File uploaded successfully",
  "fileName": "20250717_143052_a1b2c3d4.pdf",
  "originalFileName": "document.pdf", 
  "fileUrl": "https://healthcarestorefv0vlbg2.blob.core.windows.net/healthcare-files/20250717_143052_a1b2c3d4.pdf",
  "uploadTime": "2025-07-17T14:30:52.123456",
  "fileSize": 1024
}
```

### Error Responses

#### 400 Bad Request
```json
{
  "error": "No file provided. Please include a 'file' in your form data."
}
```

#### 500 Internal Server Error
```json
{
  "error": "Error uploading file: <error details>"
}
```

## Security Features

1. **HTTPS Only**: All communication encrypted
2. **API Management**: Centralized security and rate limiting
3. **Private Storage**: Files stored in private blob container
4. **Unique File Names**: Prevents file name conflicts
5. **Function-level Authentication**: Azure Function protected

## File Handling

- **File Naming**: Files are automatically renamed with timestamp and unique ID
- **Storage Location**: Azure Blob Storage in `healthcare-files` container
- **File Size Limits**: Determined by Azure Function App settings (default: 100MB)
- **Supported Formats**: All file types accepted

## Rate Limits

- Default API Management consumption tier limits apply
- Can be customized in Azure Portal under API Management policies

## Monitoring

- **Application Insights**: Function execution logging
- **API Management Analytics**: Request/response metrics
- **Azure Monitor**: Infrastructure monitoring

## Testing

Use the provided test client:

```bash
# Install dependencies
pip install requests

# Test the API
python test_api_client.py <API_URL> <FILE_PATH> [API_KEY]

# Example
python test_api_client.py https://healthcare-api-a1b2c3d4.azure-api.net/files/upload test.txt
```

## Deployment

The API is automatically deployed via GitHub Actions when changes are pushed to the main branch.

### Manual Deployment

1. **Infrastructure**: `cd infra && terraform apply`
2. **Function Code**: Deploy via Azure CLI or VS Code
3. **Testing**: Run test client to verify functionality

## Configuration

Key environment variables in the Function App:

- `AZURE_STORAGE_CONNECTION_STRING`: Connection to blob storage
- `HEALTHCARE_CONTAINER_NAME`: Target container name (healthcare-files)

## Troubleshooting

### Common Issues

1. **403 Forbidden**: Check API key or authentication settings
2. **404 Not Found**: Verify API Management configuration
3. **500 Internal Error**: Check Function App logs in Azure Portal
4. **Timeout**: Large files may need increased timeout settings

### Logs and Monitoring

- **Function Logs**: Azure Portal > Function App > Logs
- **API Management**: Azure Portal > API Management > Analytics
- **Storage**: Azure Portal > Storage Account > Monitoring

---

**Next Steps**: 
1. Configure API keys in API Management for production use
2. Set up custom domains and SSL certificates
3. Implement file validation and scanning
4. Add authentication and authorization
