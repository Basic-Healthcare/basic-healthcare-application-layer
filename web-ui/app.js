// Healthcare File Upload Web Interface
class FileUploadApp {
    constructor() {
        this.apiUrl = '';
        this.selectedFiles = [];
        this.initializeElements();
        this.attachEventListeners();
        this.loadApiUrl();
    }

    initializeElements() {
        this.elements = {
            apiUrl: document.getElementById('apiUrl'),
            fileInput: document.getElementById('fileInput'),
            dropZone: document.getElementById('dropZone'),
            selectedFile: document.getElementById('selectedFile'),
            fileName: document.getElementById('fileName'),
            fileSize: document.getElementById('fileSize'),
            uploadBtn: document.getElementById('uploadBtn'),
            btnText: document.querySelector('.btn-text'),
            loading: document.querySelector('.loading'),
            progressBar: document.getElementById('progressBar'),
            progressFill: document.getElementById('progressFill'),
            resultSection: document.getElementById('resultSection'),
            resultTitle: document.getElementById('resultTitle'),
            resultMessage: document.getElementById('resultMessage'),
            resultDetails: document.getElementById('resultDetails')
        };
    }

    attachEventListeners() {
        // API URL change
        this.elements.apiUrl.addEventListener('input', () => {
            this.apiUrl = this.elements.apiUrl.value.trim();
            localStorage.setItem('healthcareApiUrl', this.apiUrl);
        });

        // File input change
        this.elements.fileInput.addEventListener('change', (e) => {
            this.handleFileSelection(e.target.files);
        });

        // Drag and drop
        this.elements.dropZone.addEventListener('dragover', (e) => {
            e.preventDefault();
            this.elements.dropZone.classList.add('dragover');
        });

        this.elements.dropZone.addEventListener('dragleave', () => {
            this.elements.dropZone.classList.remove('dragover');
        });

        this.elements.dropZone.addEventListener('drop', (e) => {
            e.preventDefault();
            this.elements.dropZone.classList.remove('dragover');
            this.handleFileSelection(e.dataTransfer.files);
        });

        // Upload button
        this.elements.uploadBtn.addEventListener('click', () => {
            this.uploadFiles();
        });
    }

    loadApiUrl() {
        const savedUrl = localStorage.getItem('healthcareApiUrl');
        if (savedUrl) {
            this.elements.apiUrl.value = savedUrl;
            this.apiUrl = savedUrl;
        } else {
            this.apiUrl = this.elements.apiUrl.value;
        }
    }

    handleFileSelection(files) {
        if (files.length === 0) return;

        this.selectedFiles = Array.from(files);
        this.updateFileDisplay();
        this.updateUploadButton();
        this.hideResult();
    }

    updateFileDisplay() {
        if (this.selectedFiles.length === 0) {
            this.elements.selectedFile.classList.remove('show');
            return;
        }

        const file = this.selectedFiles[0];
        const fileSize = this.formatFileSize(file.size);
        
        if (this.selectedFiles.length === 1) {
            this.elements.fileName.textContent = file.name;
            this.elements.fileSize.textContent = fileSize;
        } else {
            this.elements.fileName.textContent = `${this.selectedFiles.length} files selected`;
            const totalSize = this.selectedFiles.reduce((sum, f) => sum + f.size, 0);
            this.elements.fileSize.textContent = `Total size: ${this.formatFileSize(totalSize)}`;
        }

        this.elements.selectedFile.classList.add('show');
    }

    updateUploadButton() {
        const hasFiles = this.selectedFiles.length > 0;
        const hasApiUrl = this.apiUrl.length > 0;

        this.elements.uploadBtn.disabled = !hasFiles || !hasApiUrl;

        if (!hasApiUrl) {
            this.elements.btnText.textContent = 'Enter API URL first';
        } else if (!hasFiles) {
            this.elements.btnText.textContent = 'Select a file to upload';
        } else if (this.selectedFiles.length === 1) {
            this.elements.btnText.textContent = 'Upload File';
        } else {
            this.elements.btnText.textContent = `Upload ${this.selectedFiles.length} Files`;
        }
    }

    async uploadFiles() {
        if (this.selectedFiles.length === 0 || !this.apiUrl) return;

        this.setLoadingState(true);
        this.hideResult();
        this.showProgress();

        try {
            const results = [];
            
            for (let i = 0; i < this.selectedFiles.length; i++) {
                const file = this.selectedFiles[i];
                this.updateProgress((i / this.selectedFiles.length) * 100);
                
                const result = await this.uploadSingleFile(file);
                results.push({ file: file.name, result });
            }

            this.updateProgress(100);
            this.showSuccess(results);
        } catch (error) {
            this.showError(error);
        } finally {
            this.setLoadingState(false);
            this.hideProgress();
        }
    }

    async uploadSingleFile(file) {
        const formData = new FormData();
        formData.append('file', file);

        const response = await fetch(this.apiUrl, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Upload failed for ${file.name}: ${response.status} ${response.statusText}\n${errorText}`);
        }

        return await response.json();
    }

    setLoadingState(loading) {
        this.elements.uploadBtn.disabled = loading;
        this.elements.btnText.style.display = loading ? 'none' : 'inline';
        this.elements.loading.style.display = loading ? 'inline-flex' : 'none';
    }

    showProgress() {
        this.elements.progressBar.style.display = 'block';
        this.updateProgress(0);
    }

    hideProgress() {
        setTimeout(() => {
            this.elements.progressBar.style.display = 'none';
        }, 1000);
    }

    updateProgress(percentage) {
        this.elements.progressFill.style.width = `${percentage}%`;
    }

    showSuccess(results) {
        this.elements.resultSection.className = 'result-section success';
        this.elements.resultSection.style.display = 'block';
        
        this.elements.resultTitle.innerHTML = '<i class="fas fa-check-circle"></i> Upload Successful!';
        
        if (results.length === 1) {
            const result = results[0].result;
            this.elements.resultMessage.textContent = result.message || 'File uploaded successfully!';
            this.showSingleFileDetails(result);
        } else {
            this.elements.resultMessage.textContent = `Successfully uploaded ${results.length} files!`;
            this.showMultipleFileDetails(results);
        }
    }

    showSingleFileDetails(result) {
        const details = [
            { label: 'File Name:', value: result.fileName || 'N/A' },
            { label: 'Original Name:', value: result.originalFileName || 'N/A' },
            { label: 'File Size:', value: result.fileSize ? this.formatFileSize(result.fileSize) : 'N/A' },
            { label: 'Upload Time:', value: result.uploadTime ? new Date(result.uploadTime).toLocaleString() : 'N/A' },
            { label: 'File URL:', value: result.fileUrl ? `<a href="${result.fileUrl}" target="_blank" class="file-url">${result.fileUrl}</a>` : 'N/A' }
        ];

        this.elements.resultDetails.innerHTML = details
            .map(item => `
                <div class="result-item">
                    <span class="result-label">${item.label}</span>
                    <span class="result-value">${item.value}</span>
                </div>
            `).join('');
    }

    showMultipleFileDetails(results) {
        const successCount = results.filter(r => r.result && !r.error).length;
        const errorCount = results.length - successCount;

        let html = `
            <div class="result-item">
                <span class="result-label">Total Files:</span>
                <span class="result-value">${results.length}</span>
            </div>
            <div class="result-item">
                <span class="result-label">Successful:</span>
                <span class="result-value">${successCount}</span>
            </div>
        `;

        if (errorCount > 0) {
            html += `
                <div class="result-item">
                    <span class="result-label">Failed:</span>
                    <span class="result-value">${errorCount}</span>
                </div>
            `;
        }

        html += '<div style="margin-top: 15px; font-weight: 600;">File Details:</div>';

        results.forEach((item, index) => {
            const status = item.result && !item.error ? '✅' : '❌';
            const fileName = item.result?.fileName || item.file;
            html += `
                <div class="result-item" style="margin-left: 20px;">
                    <span class="result-label">${status} ${fileName}</span>
                    <span class="result-value">${item.result?.fileUrl ? `<a href="${item.result.fileUrl}" target="_blank" class="file-url">View</a>` : ''}</span>
                </div>
            `;
        });

        this.elements.resultDetails.innerHTML = html;
    }

    showError(error) {
        this.elements.resultSection.className = 'result-section error';
        this.elements.resultSection.style.display = 'block';
        
        this.elements.resultTitle.innerHTML = '<i class="fas fa-exclamation-circle"></i> Upload Failed';
        this.elements.resultMessage.textContent = error.message || 'An error occurred during upload.';
        
        this.elements.resultDetails.innerHTML = `
            <div class="result-item">
                <span class="result-label">Error Details:</span>
                <span class="result-value">${error.stack || error.message}</span>
            </div>
            <div class="result-item">
                <span class="result-label">API URL:</span>
                <span class="result-value">${this.apiUrl}</span>
            </div>
            <div class="result-item" style="margin-top: 10px;">
                <span class="result-label">Troubleshooting:</span>
                <span class="result-value">
                    • Check if the API URL is correct<br>
                    • Verify the API is running and accessible<br>
                    • Check browser console for detailed errors<br>
                    • Ensure file size is within limits
                </span>
            </div>
        `;
    }

    hideResult() {
        this.elements.resultSection.style.display = 'none';
    }

    formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
}

// Initialize the application when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new FileUploadApp();
});
