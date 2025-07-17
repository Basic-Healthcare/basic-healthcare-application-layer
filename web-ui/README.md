# Healthcare File Upload - Web UI

A modern, responsive web interface for the Healthcare File Upload API.

## Features

- 🎨 **Modern UI**: Clean, professional healthcare-themed interface
- 📱 **Responsive Design**: Works perfectly on desktop, tablet, and mobile
- 🖱️ **Drag & Drop**: Intuitive file selection with drag and drop support
- 📄 **Multiple Files**: Upload single or multiple files simultaneously
- 📊 **Progress Tracking**: Real-time upload progress indicators
- 🔧 **Configurable**: Easy API URL configuration with local storage
- 📋 **Detailed Results**: Comprehensive upload results and file information
- 🛡️ **Error Handling**: User-friendly error messages and troubleshooting

## Quick Start

1. **Open the Interface**:
   ```bash
   # Navigate to the web-ui directory
   cd web-ui
   
   # Open in browser (any of these methods work)
   open index.html                    # macOS
   xdg-open index.html               # Linux
   start index.html                  # Windows
   
   # Or serve with Python
   python -m http.server 8000
   # Then visit: http://localhost:8000
   ```

2. **Configure API URL**:
   - The interface is pre-configured with your API URL
   - You can change it in the "API Configuration" section
   - URL is automatically saved in browser storage

3. **Upload Files**:
   - Click to select files or drag and drop
   - Supports any file type and multiple files
   - Click "Upload" to send files to your API

## API Integration

The web interface automatically integrates with your Healthcare File Upload API:

- **Default URL**: `https://healthcare-api-64e194e6.azure-api.net/files/upload`
- **Method**: POST with multipart/form-data
- **CORS**: Enabled for web browsers
- **Authentication**: Ready for API keys if configured

## File Structure

```
web-ui/
├── index.html          # Main HTML interface
├── app.js             # JavaScript application logic
└── README.md          # This documentation
```

## Features in Detail

### File Selection
- **Click to Browse**: Traditional file picker
- **Drag & Drop**: Drop files directly onto the upload area
- **Multiple Files**: Select and upload multiple files at once
- **File Preview**: Shows selected file names and sizes

### Upload Process
- **Progress Bar**: Visual progress indicator during upload
- **Status Updates**: Real-time feedback during upload process
- **Batch Processing**: Handles multiple files sequentially
- **Error Recovery**: Continues with remaining files if one fails

### Results Display
- **Success Details**: File URLs, upload times, unique names
- **File Information**: Original name, size, storage location
- **Error Details**: Comprehensive error messages and troubleshooting
- **Multiple File Summary**: Overview of batch upload results

### Configuration
- **API URL Setting**: Easily change the target API endpoint
- **Local Storage**: Settings persist between browser sessions
- **Validation**: Checks for valid API URL before allowing uploads

## Browser Compatibility

- ✅ Chrome 60+
- ✅ Firefox 55+
- ✅ Safari 12+
- ✅ Edge 79+
- ✅ Mobile browsers (iOS Safari, Chrome Mobile)

## Customization

### Styling
The interface uses modern CSS with:
- CSS Grid and Flexbox for responsive layout
- CSS custom properties for easy theming
- Smooth animations and transitions
- Healthcare-themed color scheme

### JavaScript
The application is built with vanilla JavaScript:
- Modern ES6+ features
- Fetch API for HTTP requests
- Local Storage for configuration
- Event-driven architecture

### Adding Features

You can easily extend the interface:

1. **File Validation**: Add client-side file type/size validation
2. **Authentication**: Integrate API key input fields
3. **Metadata**: Add custom metadata fields for files
4. **Preview**: Add file preview capabilities
5. **History**: Show upload history from local storage

## Production Deployment

For production use, consider:

1. **Web Server**: Serve files through a proper web server (Nginx, Apache, etc.)
2. **HTTPS**: Ensure the interface is served over HTTPS
3. **CDN**: Use CDN for CSS/JS libraries for better performance
4. **API Keys**: Implement proper API authentication
5. **Error Tracking**: Add error tracking service integration

## Integration Examples

### With Your Healthcare App
```javascript
// Integrate upload results into your app
window.addEventListener('healthcareFileUploaded', (event) => {
    const fileData = event.detail;
    // Process the uploaded file data
    updatePatientRecord(fileData.fileUrl, fileData.fileName);
});
```

### Custom Validation
```javascript
// Add custom file validation
function validateHealthcareFile(file) {
    const allowedTypes = ['pdf', 'jpg', 'png', 'docx'];
    const maxSize = 10 * 1024 * 1024; // 10MB
    
    if (file.size > maxSize) {
        throw new Error('File too large. Maximum size is 10MB.');
    }
    
    const extension = file.name.split('.').pop().toLowerCase();
    if (!allowedTypes.includes(extension)) {
        throw new Error('File type not allowed. Use PDF, JPG, PNG, or DOCX.');
    }
}
```

## Troubleshooting

### Common Issues

1. **CORS Errors**: 
   - Ensure your API has CORS enabled
   - Check that the API URL is correct

2. **Upload Failures**:
   - Verify API is running and accessible
   - Check file size limits
   - Ensure proper API authentication

3. **Interface Not Loading**:
   - Check browser console for JavaScript errors
   - Ensure all files are properly served
   - Try opening in different browser

### Debug Mode
Open browser developer tools (F12) to see:
- Network requests to the API
- JavaScript console logs
- Detailed error messages

---

## 🎉 Ready to Use!

Your web interface is ready to use with your Healthcare File Upload API. Simply open `index.html` in a web browser and start uploading files!
