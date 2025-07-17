import azure.functions as func
import logging
import json
import os
from azure.storage.blob import BlobServiceClient
import uuid
from datetime import datetime

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Function to handle file uploads to blob storage
    """
    logging.info('Processing file upload request')
    
    try:
        # Get file from form data
        files = req.files
        if not files:
            return func.HttpResponse(
                json.dumps({'error': 'No file provided'}),
                status_code=400,
                headers={'Content-Type': 'application/json'}
            )
        
        # Get the first file
        file_item = list(files.values())[0]
        if not file_item.filename:
            return func.HttpResponse(
                json.dumps({'error': 'No filename provided'}),
                status_code=400,
                headers={'Content-Type': 'application/json'}
            )
        
        # Get storage connection from environment
        storage_connection = os.environ.get('AzureWebJobsStorage')
        if not storage_connection:
            return func.HttpResponse(
                json.dumps({'error': 'Storage connection not configured'}),
                status_code=500,
                headers={'Content-Type': 'application/json'}
            )
        
        # Create blob service client
        blob_service_client = BlobServiceClient.from_connection_string(storage_connection)
        
        # Container name
        container_name = "healthcare-files"
        
        # Generate unique filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_id = str(uuid.uuid4())[:8]
        file_extension = file_item.filename.split('.')[-1] if '.' in file_item.filename else ''
        if file_extension:
            blob_name = f"{timestamp}_{unique_id}.{file_extension}"
        else:
            blob_name = f"{timestamp}_{unique_id}"
        
        # Upload file to blob storage
        blob_client = blob_service_client.get_blob_client(
            container=container_name,
            blob=blob_name
        )
        
        # Read file content
        file_content = file_item.stream.read()
        
        # Upload to blob storage
        blob_client.upload_blob(file_content, overwrite=True)
        
        # Get blob URL
        blob_url = blob_client.url
        
        logging.info(f'File uploaded successfully: {blob_name}')
        
        return func.HttpResponse(
            json.dumps({
                'message': 'File uploaded successfully',
                'filename': blob_name,
                'url': blob_url,
                'size': len(file_content)
            }),
            status_code=200,
            headers={'Content-Type': 'application/json'}
        )
        
    except Exception as e:
        logging.error(f'Error uploading file: {str(e)}')
        return func.HttpResponse(
            json.dumps({'error': f'Failed to upload file: {str(e)}'}),
            status_code=500,
            headers={'Content-Type': 'application/json'}
        )
