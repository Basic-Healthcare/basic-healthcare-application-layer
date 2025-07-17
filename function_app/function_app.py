import azure.functions as func
import logging
import json
import os
from azure.storage.blob import BlobServiceClient
import uuid
from datetime import datetime

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="upload", methods=["POST"])
def upload_file(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Function to handle file uploads to blob storage
    """
    logging.info('File upload function triggered.')

    try:
        # Get environment variables
        connection_string = os.environ.get('AZURE_STORAGE_CONNECTION_STRING')
        container_name = os.environ.get('HEALTHCARE_CONTAINER_NAME', 'healthcare-files')
        
        if not connection_string:
            logging.error('AZURE_STORAGE_CONNECTION_STRING not found in environment variables')
            return func.HttpResponse(
                json.dumps({"error": "Storage configuration error"}),
                status_code=500,
                mimetype="application/json"
            )

        # Get the uploaded file
        try:
            files = req.files
            if not files or 'file' not in files:
                return func.HttpResponse(
                    json.dumps({"error": "No file provided. Please include a 'file' in your form data."}),
                    status_code=400,
                    mimetype="application/json"
                )
            
            uploaded_file = files['file']
            if not uploaded_file.filename:
                return func.HttpResponse(
                    json.dumps({"error": "No file selected"}),
                    status_code=400,
                    mimetype="application/json"
                )
                
        except Exception as e:
            logging.error(f'Error processing uploaded file: {str(e)}')
            return func.HttpResponse(
                json.dumps({"error": "Error processing uploaded file"}),
                status_code=400,
                mimetype="application/json"
            )

        # Generate unique filename
        file_extension = os.path.splitext(uploaded_file.filename)[1]
        unique_filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:8]}{file_extension}"
        
        # Upload to Azure Blob Storage
        try:
            blob_service_client = BlobServiceClient.from_connection_string(connection_string)
            blob_client = blob_service_client.get_blob_client(
                container=container_name, 
                blob=unique_filename
            )
            
            # Read file content and upload
            file_content = uploaded_file.read()
            blob_client.upload_blob(file_content, overwrite=True)
            
            # Get the blob URL
            blob_url = blob_client.url
            
            logging.info(f'File uploaded successfully: {unique_filename}')
            
            # Return success response
            response_data = {
                "message": "File uploaded successfully",
                "fileName": unique_filename,
                "originalFileName": uploaded_file.filename,
                "fileUrl": blob_url,
                "uploadTime": datetime.now().isoformat(),
                "fileSize": len(file_content)
            }
            
            return func.HttpResponse(
                json.dumps(response_data),
                status_code=200,
                mimetype="application/json"
            )
            
        except Exception as e:
            logging.error(f'Error uploading to blob storage: {str(e)}')
            return func.HttpResponse(
                json.dumps({"error": f"Error uploading file: {str(e)}"}),
                status_code=500,
                mimetype="application/json"
            )
            
    except Exception as e:
        logging.error(f'Unexpected error in upload function: {str(e)}')
        return func.HttpResponse(
            json.dumps({"error": "Internal server error"}),
            status_code=500,
            mimetype="application/json"
        )
