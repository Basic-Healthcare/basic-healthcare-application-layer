#!/usr/bin/env python3
"""
Simple test client for the Healthcare File Upload API
"""

import requests
import sys
import json
import os

def upload_file(api_url, file_path, api_key=None):
    """
    Upload a file to the healthcare API
    
    Args:
        api_url: The API endpoint URL
        file_path: Path to the file to upload
        api_key: Optional API key for authentication
    """
    
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found")
        return False
    
    # Prepare headers
    headers = {}
    if api_key:
        headers['Ocp-Apim-Subscription-Key'] = api_key
    
    # Prepare file for upload
    with open(file_path, 'rb') as file:
        files = {'file': (os.path.basename(file_path), file, 'application/octet-stream')}
        
        try:
            print(f"Uploading {file_path} to {api_url}...")
            response = requests.post(api_url, files=files, headers=headers, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                print("✅ Upload successful!")
                print(f"   File Name: {result.get('fileName')}")
                print(f"   File URL: {result.get('fileUrl')}")
                print(f"   Upload Time: {result.get('uploadTime')}")
                print(f"   File Size: {result.get('fileSize')} bytes")
                return True
            else:
                print(f"❌ Upload failed with status {response.status_code}")
                try:
                    error_info = response.json()
                    print(f"   Error: {error_info.get('error', 'Unknown error')}")
                except:
                    print(f"   Response: {response.text}")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Request failed: {e}")
            return False

def main():
    """Main function to handle command line usage"""
    
    if len(sys.argv) < 3:
        print("Usage: python test_api_client.py <API_URL> <FILE_PATH> [API_KEY]")
        print("")
        print("Example:")
        print("  python test_api_client.py https://your-apim.azure-api.net/files/upload test_file.txt")
        print("  python test_api_client.py https://your-apim.azure-api.net/files/upload test_file.txt your-api-key")
        sys.exit(1)
    
    api_url = sys.argv[1]
    file_path = sys.argv[2]
    api_key = sys.argv[3] if len(sys.argv) > 3 else None
    
    success = upload_file(api_url, file_path, api_key)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
