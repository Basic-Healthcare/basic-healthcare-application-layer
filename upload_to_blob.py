import os
from azure.storage.blob import BlobServiceClient

def upload_file_to_blob(file_path, blob_name, connection_string, container_name):
    """
    Uploads a file to Azure Blob Storage container.
    Args:
        file_path (str): Path to the file to upload.
        blob_name (str): Name for the blob in storage.
        connection_string (str): Azure Storage account connection string.
        container_name (str): Name of the container to upload to.
    Returns:
        str: URL of the uploaded blob.
    """
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
    with open(file_path, "rb") as data:
        blob_client.upload_blob(data, overwrite=True)
    return blob_client.url

# Example usage (replace with actual values from Terraform outputs or environment variables):
# connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
# upload_file_to_blob("/path/to/file.txt", "file.txt", connection_string, "healthcare-files")
