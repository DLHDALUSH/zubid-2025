// Create auction page functionality
let html5QrcodeScanner = null;

document.addEventListener('DOMContentLoaded', async () => {
    await loadCategories();
    
    // Set default end time to 7 days from now
    const defaultEndTime = new Date();
    defaultEndTime.setDate(defaultEndTime.getDate() + 7);
    const endTimeInput = document.getElementById('endTime');
    if (endTimeInput) {
        endTimeInput.value = defaultEndTime.toISOString().slice(0, 16);
    }
    
    // Check if user is logged in
    if (!currentUser) {
        showToast('Please login to create an auction', 'error');
        setTimeout(() => {
            window.location.href = 'index.html';
        }, 2000);
    }
    
    // Cleanup QR scanner on page unload
    window.addEventListener('beforeunload', () => {
        if (html5QrcodeScanner) {
            stopQRScanner();
        }
    });
});

// QR Code Scanner Functions
function startQRScanner() {
    const qrReaderElement = document.getElementById('qr-reader');
    const startBtn = document.getElementById('startQrScanner');
    const stopBtn = document.getElementById('stopQrScanner');
    const resultsDiv = document.getElementById('qr-reader-results');
    
    if (!qrReaderElement) return;
    
    // Check if html5Qrcode is available
    if (typeof Html5Qrcode === 'undefined') {
        showToast('QR Scanner library not loaded. Please refresh the page.', 'error');
        return;
    }
    
    try {
        // Clear previous scanner if exists
        if (html5QrcodeScanner) {
            stopQRScanner();
        }
        
        // Create new scanner instance
        html5QrcodeScanner = new Html5Qrcode("qr-reader");
        
        // Start scanning
        html5QrcodeScanner.start(
            { facingMode: "environment" }, // Use back camera
            {
                fps: 10,
                qrbox: { width: 250, height: 250 },
                aspectRatio: 1.0
            },
            (decodedText, decodedResult) => {
                // Success callback
                onScanSuccess(decodedText, decodedResult);
            },
            (errorMessage) => {
                // Error callback - ignore for continuous scanning
                // console.log('QR scan error:', errorMessage);
            }
        ).then(() => {
            startBtn.style.display = 'none';
            stopBtn.style.display = 'inline-block';
            resultsDiv.style.display = 'none';
            showToast('QR Scanner started. Point camera at QR code.', 'info');
        }).catch((err) => {
            console.error('Failed to start QR scanner:', err);
            showToast('Failed to start camera. Please check permissions.', 'error');
        });
    } catch (error) {
        console.error('Error starting QR scanner:', error);
        showToast('Failed to start QR scanner: ' + error.message, 'error');
    }
}

function stopQRScanner() {
    const startBtn = document.getElementById('startQrScanner');
    const stopBtn = document.getElementById('stopQrScanner');
    
    if (html5QrcodeScanner) {
        html5QrcodeScanner.stop().then(() => {
            html5QrcodeScanner.clear();
            html5QrcodeScanner = null;
            startBtn.style.display = 'inline-block';
            stopBtn.style.display = 'none';
        }).catch((err) => {
            console.error('Error stopping QR scanner:', err);
        });
    }
}

function onScanSuccess(decodedText, decodedResult) {
    // Stop scanner after successful scan
    stopQRScanner();
    
    try {
        // Try to parse as JSON (our QR code format)
        let qrData;
        try {
            qrData = JSON.parse(decodedText);
        } catch (e) {
            // If not JSON, treat as plain text
            qrData = { raw_text: decodedText };
        }
        
        // Fill form with scanned data
        fillFormFromQRData(qrData);
        
        // Show success message
        const resultsDiv = document.getElementById('qr-reader-results');
        const dataDiv = document.getElementById('qr-scanned-data');
        if (resultsDiv && dataDiv) {
            resultsDiv.style.display = 'block';
            dataDiv.textContent = `Scanned: ${qrData.item_name || qrData.raw_text || 'QR Code'}`;
        }
        
        showToast('QR Code scanned! Form filled automatically.', 'success');
    } catch (error) {
        console.error('Error processing QR code:', error);
        showToast('Error processing QR code: ' + error.message, 'error');
    }
}

function fillFormFromQRData(qrData) {
    try {
        // Fill item name
        if (qrData.item_name) {
            const itemNameInput = document.getElementById('itemName');
            if (itemNameInput) {
                itemNameInput.value = qrData.item_name;
            }
        }
        
        // Fill description
        if (qrData.description) {
            const descInput = document.getElementById('description');
            if (descInput) {
                descInput.value = qrData.description;
            }
        } else if (qrData.item_name) {
            // Create a basic description from item name
            const descInput = document.getElementById('description');
            if (descInput && !descInput.value) {
                descInput.value = `Auction item: ${qrData.item_name}`;
            }
        }
        
        // Fill item condition if available
        if (qrData.item_condition) {
            const conditionInput = document.getElementById('itemCondition');
            if (conditionInput) {
                conditionInput.value = qrData.item_condition;
            }
        }
        
        // Fill starting bid if price is available
        if (qrData.price) {
            const startingBidInput = document.getElementById('startingBid');
            if (startingBidInput) {
                startingBidInput.value = qrData.price;
            }
        }
        
        // If auction_id is present, try to fetch more details from API
        if (qrData.auction_id && qrData.type === 'auction_item') {
            fetchAuctionDetails(qrData.auction_id);
        }
        
        // Scroll to form after filling
        setTimeout(() => {
            document.getElementById('createAuctionForm').scrollIntoView({ behavior: 'smooth', block: 'start' });
        }, 300);
        
    } catch (error) {
        console.error('Error filling form:', error);
        showToast('Error filling form: ' + error.message, 'error');
    }
}

async function fetchAuctionDetails(auctionId) {
    try {
        const auction = await AuctionAPI.getById(auctionId);
        
        // Fill form with auction details
        const itemNameInput = document.getElementById('itemName');
        const descInput = document.getElementById('description');
        const conditionInput = document.getElementById('itemCondition');
        const startingBidInput = document.getElementById('startingBid');
        const categoryInput = document.getElementById('category');
        const imageUrlsInput = document.getElementById('imageUrls');
        
        if (itemNameInput && auction.item_name) {
            itemNameInput.value = auction.item_name;
        }
        
        if (descInput && auction.description) {
            descInput.value = auction.description;
        }
        
        if (conditionInput && auction.item_condition) {
            conditionInput.value = auction.item_condition;
        }
        
        if (startingBidInput && auction.current_bid) {
            startingBidInput.value = auction.current_bid;
        }
        
        if (categoryInput && auction.category_id) {
            categoryInput.value = auction.category_id;
        }
        
        if (imageUrlsInput && auction.images && auction.images.length > 0) {
            const imageUrls = auction.images.map(img => img.url).join('\n');
            imageUrlsInput.value = imageUrls;
        }
        
        showToast('Auction details loaded from QR code!', 'success');
    } catch (error) {
        console.error('Error fetching auction details:', error);
        // Don't show error - we already filled what we could from QR code
    }
}

// Load categories for dropdown
async function loadCategories() {
    try {
        const categories = await CategoryAPI.getAll();
        const select = document.getElementById('category');
        if (select) {
            select.innerHTML = '<option value="">Select Category</option>' +
                categories.map(cat => `<option value="${cat.id}">${cat.name}</option>`).join('');
        }
    } catch (error) {
        console.error('Error loading categories:', error);
    }
}

// Image upload state - using new structure
let uploadedImageData = []; // Array of {url, file, previewUrl, index, previewDiv}

// Store uploaded video
let uploadedVideoUrl = null;
let uploadedVideoFile = null;

// Store uploaded video
let uploadedVideoUrl = null;
let uploadedVideoFile = null;

// Handle image file selection
async function handleImageFilesChange(event) {
    const files = Array.from(event.target.files);
    const previewContainer = document.getElementById('imagePreviewContainer');
    const previewsDiv = document.getElementById('imagePreviews');
    
    if (files.length === 0) {
        if (uploadedImageData.length === 0) {
            previewContainer.style.display = 'none';
        }
        return;
    }
    
    // Validate file sizes (5MB max)
    const maxSize = 5 * 1024 * 1024; // 5MB
    const invalidFiles = files.filter(file => file.size > maxSize);
    
    if (invalidFiles.length > 0) {
        showToast(`Some files are too large. Maximum size is 5MB per image.`, 'error');
        event.target.value = ''; // Clear selection
        return;
    }
    
    // Show preview container
    previewContainer.style.display = 'block';
    
    // Upload files and show previews
    const uploadPromises = [];
    const startIndex = uploadedImageData.length;
    
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const imageIndex = startIndex + i;
        const previewUrl = URL.createObjectURL(file);
        
        // Show preview immediately
        const previewDiv = document.createElement('div');
        previewDiv.className = 'image-preview-item';
        previewDiv.dataset.index = imageIndex;
        previewDiv.style.position = 'relative';
        previewDiv.style.aspectRatio = '1';
        previewDiv.style.overflow = 'hidden';
        previewDiv.style.borderRadius = '8px';
        previewDiv.style.background = '#1a1a2e';
        previewDiv.style.border = '2px solid var(--border-color)';
        previewDiv.style.cursor = 'move';
        
        // Image number badge
        const numberBadge = document.createElement('div');
        numberBadge.className = 'image-number-badge';
        numberBadge.textContent = imageIndex + 1;
        numberBadge.style.position = 'absolute';
        numberBadge.style.top = '4px';
        numberBadge.style.left = '4px';
        numberBadge.style.background = 'rgba(255, 102, 0, 0.9)';
        numberBadge.style.color = 'white';
        numberBadge.style.padding = '2px 8px';
        numberBadge.style.borderRadius = '12px';
        numberBadge.style.fontSize = '12px';
        numberBadge.style.fontWeight = 'bold';
        numberBadge.style.zIndex = '10';
        
        const img = document.createElement('img');
        img.src = previewUrl;
        img.style.width = '100%';
        img.style.height = '100%';
        img.style.objectFit = 'cover';
        previewDiv.appendChild(img);
        previewDiv.appendChild(numberBadge);
        
        // Add loading indicator
        const loadingDiv = document.createElement('div');
        loadingDiv.className = 'image-loading';
        loadingDiv.style.position = 'absolute';
        loadingDiv.style.top = '0';
        loadingDiv.style.left = '0';
        loadingDiv.style.right = '0';
        loadingDiv.style.bottom = '0';
        loadingDiv.style.background = 'rgba(0,0,0,0.7)';
        loadingDiv.style.display = 'flex';
        loadingDiv.style.alignItems = 'center';
        loadingDiv.style.justifyContent = 'center';
        loadingDiv.style.color = '#fff';
        loadingDiv.textContent = 'Uploading...';
        previewDiv.appendChild(loadingDiv);
        
        // Remove button
        const removeBtn = document.createElement('button');
        removeBtn.className = 'image-remove-btn';
        removeBtn.innerHTML = '×';
        removeBtn.style.position = 'absolute';
        removeBtn.style.top = '4px';
        removeBtn.style.right = '4px';
        removeBtn.style.background = 'rgba(239, 68, 68, 0.9)';
        removeBtn.style.color = 'white';
        removeBtn.style.border = 'none';
        removeBtn.style.borderRadius = '50%';
        removeBtn.style.width = '28px';
        removeBtn.style.height = '28px';
        removeBtn.style.cursor = 'pointer';
        removeBtn.style.fontSize = '20px';
        removeBtn.style.lineHeight = '1';
        removeBtn.style.zIndex = '10';
        removeBtn.onclick = (e) => {
            e.stopPropagation();
            removeImage(imageIndex);
        };
        previewDiv.appendChild(removeBtn);
        
        // Move buttons
        const moveControls = document.createElement('div');
        moveControls.className = 'image-move-controls';
        moveControls.style.position = 'absolute';
        moveControls.style.bottom = '4px';
        moveControls.style.left = '50%';
        moveControls.style.transform = 'translateX(-50%)';
        moveControls.style.display = 'flex';
        moveControls.style.gap = '4px';
        moveControls.style.zIndex = '10';
        
        const moveUpBtn = document.createElement('button');
        moveUpBtn.innerHTML = '↑';
        moveUpBtn.className = 'image-move-btn';
        moveUpBtn.title = 'Move up';
        moveUpBtn.onclick = (e) => {
            e.stopPropagation();
            moveImage(imageIndex, -1);
        };
        
        const moveDownBtn = document.createElement('button');
        moveDownBtn.innerHTML = '↓';
        moveDownBtn.className = 'image-move-btn';
        moveDownBtn.title = 'Move down';
        moveDownBtn.onclick = (e) => {
            e.stopPropagation();
            moveImage(imageIndex, 1);
        };
        
        moveControls.appendChild(moveUpBtn);
        moveControls.appendChild(moveDownBtn);
        previewDiv.appendChild(moveControls);
        
        previewsDiv.appendChild(previewDiv);
        
        // Store image data
        const imageData = {
            file: file,
            previewUrl: previewUrl,
            index: imageIndex,
            url: null,
            previewDiv: previewDiv
        };
        uploadedImageData.push(imageData);
        
        // Upload file
        const uploadPromise = ImageAPI.upload(file)
            .then(result => {
                imageData.url = result.url;
                loadingDiv.textContent = '✓ Uploaded';
                loadingDiv.style.background = 'rgba(16, 185, 129, 0.8)';
                setTimeout(() => {
                    loadingDiv.style.display = 'none';
                }, 1000);
                updateImageNumbers();
                return result.url;
            })
            .catch(error => {
                loadingDiv.textContent = '✗ Failed';
                loadingDiv.style.background = 'rgba(239, 68, 68, 0.8)';
                showToast(`Failed to upload ${file.name}: ${error.message}`, 'error');
                // Remove failed image
                removeImage(imageIndex);
                throw error;
            });
        
        uploadPromises.push(uploadPromise);
    }
    
    // Wait for all uploads to complete
    try {
        await Promise.all(uploadPromises);
        showToast(`Successfully uploaded ${uploadedImageData.length} image(s)`, 'success');
    } catch (error) {
        console.error('Error uploading images:', error);
    }
    
    // Clear file input
    event.target.value = '';
}

// Remove an image
function removeImage(index) {
    const imageData = uploadedImageData[index];
    if (!imageData) return;
    
    // Revoke object URL to free memory
    if (imageData.previewUrl) {
        URL.revokeObjectURL(imageData.previewUrl);
    }
    
    // Remove from array
    uploadedImageData.splice(index, 1);
    
    // Remove from DOM
    if (imageData.previewDiv) {
        imageData.previewDiv.remove();
    }
    
    // Update indices and numbers
    uploadedImageData.forEach((img, i) => {
        img.index = i;
        if (img.previewDiv) {
            img.previewDiv.dataset.index = i;
        }
    });
    
    updateImageNumbers();
    
    // Hide container if no images
    if (uploadedImageData.length === 0) {
        document.getElementById('imagePreviewContainer').style.display = 'none';
    }
}

// Move an image up or down
function moveImage(index, direction) {
    const newIndex = index + direction;
    if (newIndex < 0 || newIndex >= uploadedImageData.length) return;
    
    // Swap in array
    [uploadedImageData[index], uploadedImageData[newIndex]] = [uploadedImageData[newIndex], uploadedImageData[index]];
    
    // Update indices
    uploadedImageData.forEach((img, i) => {
        img.index = i;
        if (img.previewDiv) {
            img.previewDiv.dataset.index = i;
        }
    });
    
    // Swap in DOM
    const previewsDiv = document.getElementById('imagePreviews');
    const items = Array.from(previewsDiv.children);
    if (items[index] && items[newIndex]) {
        if (direction > 0) {
            previewsDiv.insertBefore(items[newIndex], items[index]);
        } else {
            previewsDiv.insertBefore(items[index], items[newIndex].nextSibling);
        }
    }
    
    updateImageNumbers();
}

// Update image number badges
function updateImageNumbers() {
    uploadedImageData.forEach((img, i) => {
        const badge = img.previewDiv?.querySelector('.image-number-badge');
        if (badge) {
            badge.textContent = i + 1;
        }
    });
}

// Handle image URLs from textarea
function handleImageUrlsChange(event) {
    const imageUrlsText = event.target.value;
    const previewContainer = document.getElementById('imagePreviewContainer');
    const previewsDiv = document.getElementById('imagePreviews');
    
    // Parse URLs
    const urlImages = imageUrlsText
        .split('\n')
        .map(url => url.trim())
        .filter(url => url.length > 0 && (url.startsWith('http://') || url.startsWith('https://')));
    
    // Remove existing URL images (those without file property)
    uploadedImageData = uploadedImageData.filter(img => img.file !== null);
    
    // Clear and rebuild previews for file-based images
    previewsDiv.innerHTML = '';
    uploadedImageData.forEach(img => {
        if (img.previewDiv) {
            previewsDiv.appendChild(img.previewDiv);
        }
    });
    
    // Add URL images
    urlImages.forEach((url) => {
        const imageIndex = uploadedImageData.length;
        const previewDiv = document.createElement('div');
        previewDiv.className = 'image-preview-item';
        previewDiv.dataset.index = imageIndex;
        previewDiv.style.position = 'relative';
        previewDiv.style.aspectRatio = '1';
        previewDiv.style.overflow = 'hidden';
        previewDiv.style.borderRadius = '8px';
        previewDiv.style.background = '#1a1a2e';
        previewDiv.style.border = '2px solid var(--border-color)';
        
        // Image number badge
        const numberBadge = document.createElement('div');
        numberBadge.className = 'image-number-badge';
        numberBadge.textContent = imageIndex + 1;
        numberBadge.style.position = 'absolute';
        numberBadge.style.top = '4px';
        numberBadge.style.left = '4px';
        numberBadge.style.background = 'rgba(255, 102, 0, 0.9)';
        numberBadge.style.color = 'white';
        numberBadge.style.padding = '2px 8px';
        numberBadge.style.borderRadius = '12px';
        numberBadge.style.fontSize = '12px';
        numberBadge.style.fontWeight = 'bold';
        numberBadge.style.zIndex = '10';
        
        const img = document.createElement('img');
        img.src = url;
        img.style.width = '100%';
        img.style.height = '100%';
        img.style.objectFit = 'cover';
        img.onerror = function() {
            this.style.display = 'none';
            const errorDiv = document.createElement('div');
            errorDiv.style.display = 'flex';
            errorDiv.style.alignItems = 'center';
            errorDiv.style.justifyContent = 'center';
            errorDiv.style.height = '100%';
            errorDiv.style.color = '#ff4444';
            errorDiv.textContent = 'Invalid URL';
            previewDiv.appendChild(errorDiv);
        };
        previewDiv.appendChild(img);
        previewDiv.appendChild(numberBadge);
        
        // Remove button
        const removeBtn = document.createElement('button');
        removeBtn.className = 'image-remove-btn';
        removeBtn.innerHTML = '×';
        removeBtn.style.position = 'absolute';
        removeBtn.style.top = '4px';
        removeBtn.style.right = '4px';
        removeBtn.style.background = 'rgba(239, 68, 68, 0.9)';
        removeBtn.style.color = 'white';
        removeBtn.style.border = 'none';
        removeBtn.style.borderRadius = '50%';
        removeBtn.style.width = '28px';
        removeBtn.style.height = '28px';
        removeBtn.style.cursor = 'pointer';
        removeBtn.style.fontSize = '20px';
        removeBtn.style.lineHeight = '1';
        removeBtn.style.zIndex = '10';
        removeBtn.onclick = (e) => {
            e.stopPropagation();
            removeImage(imageIndex);
            // Remove from textarea
            const textarea = document.getElementById('imageUrls');
            const currentUrls = textarea.value.split('\n').filter(u => u.trim() !== url.trim());
            textarea.value = currentUrls.join('\n');
        };
        previewDiv.appendChild(removeBtn);
        
        // Move buttons
        const moveControls = document.createElement('div');
        moveControls.className = 'image-move-controls';
        moveControls.style.position = 'absolute';
        moveControls.style.bottom = '4px';
        moveControls.style.left = '50%';
        moveControls.style.transform = 'translateX(-50%)';
        moveControls.style.display = 'flex';
        moveControls.style.gap = '4px';
        moveControls.style.zIndex = '10';
        
        const moveUpBtn = document.createElement('button');
        moveUpBtn.innerHTML = '↑';
        moveUpBtn.className = 'image-move-btn';
        moveUpBtn.title = 'Move up';
        moveUpBtn.onclick = (e) => {
            e.stopPropagation();
            moveImage(imageIndex, -1);
        };
        
        const moveDownBtn = document.createElement('button');
        moveDownBtn.innerHTML = '↓';
        moveDownBtn.className = 'image-move-btn';
        moveDownBtn.title = 'Move down';
        moveDownBtn.onclick = (e) => {
            e.stopPropagation();
            moveImage(imageIndex, 1);
        };
        
        moveControls.appendChild(moveUpBtn);
        moveControls.appendChild(moveDownBtn);
        previewDiv.appendChild(moveControls);
        
        previewsDiv.appendChild(previewDiv);
        
        // Store image data
        const imageData = {
            file: null, // URL images don't have file
            previewUrl: url,
            index: imageIndex,
            url: url,
            previewDiv: previewDiv
        };
        uploadedImageData.push(imageData);
    });
    
    // Show container if we have images
    if (uploadedImageData.length > 0) {
        previewContainer.style.display = 'block';
    }
    
    updateImageNumbers();
}

// Handle video file upload
async function handleVideoFileChange(event) {
    const file = event.target.files[0];
    const previewContainer = document.getElementById('videoPreviewContainer');
    const preview = document.getElementById('videoPreview');
    const videoUrlInput = document.getElementById('videoUrl');
    
    if (!file) {
        previewContainer.style.display = 'none';
        uploadedVideoUrl = null;
        uploadedVideoFile = null;
        return;
    }
    
    // Validate file size (100MB max)
    const maxSize = 100 * 1024 * 1024; // 100MB
    if (file.size > maxSize) {
        showToast('Video file is too large. Maximum size is 100MB.', 'error');
        event.target.value = '';
        previewContainer.style.display = 'none';
        return;
    }
    
    // Validate file type
    const allowedTypes = ['video/mp4', 'video/webm', 'video/ogg', 'video/quicktime', 'video/x-msvideo', 'video/x-matroska'];
    const fileExt = file.name.split('.').pop().toLowerCase();
    const allowedExts = ['mp4', 'webm', 'ogg', 'mov', 'avi', 'mkv', 'm4v'];
    
    if (!allowedExts.includes(fileExt)) {
        showToast('Invalid video file type. Allowed: MP4, WebM, OGG, MOV, AVI, MKV, M4V', 'error');
        event.target.value = '';
        previewContainer.style.display = 'none';
        return;
    }
    
    // Show preview
    const previewUrl = URL.createObjectURL(file);
    preview.src = previewUrl;
    previewContainer.style.display = 'block';
    uploadedVideoFile = file;
    
    // Clear URL input when file is selected
    if (videoUrlInput) {
        videoUrlInput.value = '';
    }
    
    // Upload video file using VideoAPI
    try {
        const result = await VideoAPI.upload(file);
        
        // Construct full URL
        const baseUrl = API_BASE_URL.replace('/api', '');
        const fullUrl = baseUrl + result.url;
        uploadedVideoUrl = fullUrl;
        
        showToast('Video uploaded successfully!', 'success');
    } catch (error) {
        console.error('Error uploading video:', error);
        showToast(error.message || 'Failed to upload video', 'error');
        previewContainer.style.display = 'none';
        event.target.value = '';
        uploadedVideoFile = null;
        uploadedVideoUrl = null;
    }
}

// Handle featured image upload
async function handleFeaturedImageChange(event) {
    const file = event.target.files[0];
    const previewContainer = document.getElementById('featuredImagePreviewContainer');
    const preview = document.getElementById('featuredImagePreview');
    
    if (!file) {
        previewContainer.style.display = 'none';
        uploadedFeaturedImageUrl = null;
        uploadedFeaturedImageFile = null;
        return;
    }
    
    // Validate file size (5MB max)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
        showToast('Featured image file is too large. Maximum size is 5MB.', 'error');
        event.target.value = '';
        previewContainer.style.display = 'none';
        return;
    }
    
    // Validate file type
    const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];
    const fileExt = file.name.split('.').pop().toLowerCase();
    const allowedExts = ['png', 'jpg', 'jpeg', 'gif', 'webp'];
    
    if (!allowedExts.includes(fileExt)) {
        showToast('Invalid image file type. Allowed: PNG, JPG, JPEG, GIF, WEBP', 'error');
        event.target.value = '';
        previewContainer.style.display = 'none';
        return;
    }
    
    // Show preview
    const previewUrl = URL.createObjectURL(file);
    preview.src = previewUrl;
    previewContainer.style.display = 'block';
    uploadedFeaturedImageFile = file;
    
        // Upload featured image file with high quality flag
        try {
            const result = await ImageAPI.upload(file, true); // Pass true for featured image
            
            // Construct full URL
            const baseUrl = API_BASE_URL.replace('/api', '');
            const fullUrl = baseUrl + result.url;
            uploadedFeaturedImageUrl = fullUrl;
            
            showToast('Featured image uploaded successfully with enhanced quality!', 'success');
        } catch (error) {
            console.error('Error uploading featured image:', error);
            showToast(error.message || 'Failed to upload featured image', 'error');
            previewContainer.style.display = 'none';
            event.target.value = '';
            uploadedFeaturedImageFile = null;
            uploadedFeaturedImageUrl = null;
        }
}

// Remove featured image
function removeFeaturedImage() {
    const featuredImageInput = document.getElementById('featuredImageFile');
    const previewContainer = document.getElementById('featuredImagePreviewContainer');
    const preview = document.getElementById('featuredImagePreview');
    
    if (preview && preview.src) {
        URL.revokeObjectURL(preview.src);
    }
    
    if (featuredImageInput) {
        featuredImageInput.value = '';
    }
    
    previewContainer.style.display = 'none';
    uploadedFeaturedImageUrl = null;
    uploadedFeaturedImageFile = null;
}

// Remove video file
function removeVideoFile() {
    const videoFileInput = document.getElementById('videoFile');
    const previewContainer = document.getElementById('videoPreviewContainer');
    const preview = document.getElementById('videoPreview');
    
    if (preview && preview.src) {
        URL.revokeObjectURL(preview.src);
    }
    
    if (videoFileInput) {
        videoFileInput.value = '';
    }
    
    previewContainer.style.display = 'none';
    uploadedVideoUrl = null;
    uploadedVideoFile = null;
}

// Handle create auction form submission
async function handleCreateAuction(event) {
    event.preventDefault();
    
    if (!currentUser) {
        showToast('Please login to create an auction', 'error');
        showLogin();
        return;
    }
    
    const formError = document.getElementById('formError');
    formError.textContent = '';
    
    // Get form values
    const itemName = document.getElementById('itemName').value;
    const description = document.getElementById('description').value;
    const itemCondition = document.getElementById('itemCondition').value;
    const category = document.getElementById('category').value;
    const startingBid = parseFloat(document.getElementById('startingBid').value);
    const bidIncrement = parseFloat(document.getElementById('bidIncrement').value);
    const marketPrice = document.getElementById('marketPrice').value ? parseFloat(document.getElementById('marketPrice').value) : null;
    const realPrice = document.getElementById('realPrice').value ? parseFloat(document.getElementById('realPrice').value) : null;
    const endTime = document.getElementById('endTime').value;
    const featured = document.getElementById('featured').checked;
    const imageUrlsText = document.getElementById('imageUrls').value;
    const videoUrl = document.getElementById('videoUrl').value.trim();
    
    // Enhanced validation using FormValidator if available
    const validator = window.FormValidator || {
        validateRequired: (v) => v !== null && v !== undefined && String(v).trim().length > 0,
        validateNumber: (v, min, max) => {
            const num = parseFloat(v);
            if (isNaN(num)) return false;
            if (min !== null && num < min) return false;
            if (max !== null && num > max) return false;
            return true;
        }
    };
    
    // Clear previous errors
    formError.textContent = '';
    let hasErrors = false;
    
    // Validate required fields
    if (!validator.validateRequired(itemName)) {
        showFieldError('itemName', 'Item name is required');
        hasErrors = true;
    }
    
    if (!validator.validateRequired(description)) {
        showFieldError('description', 'Description is required');
        hasErrors = true;
    }
    
    if (!validator.validateRequired(itemCondition)) {
        showFieldError('itemCondition', 'Item condition is required');
        hasErrors = true;
    }
    
    if (!validator.validateRequired(category)) {
        showFieldError('category', 'Category is required');
        hasErrors = true;
    }
    
    if (!validator.validateRequired(startingBid)) {
        showFieldError('startingBid', 'Starting bid is required');
        hasErrors = true;
    } else if (!validator.validateNumber(startingBid, 0.01)) {
        showFieldError('startingBid', 'Starting bid must be greater than 0');
        hasErrors = true;
    }
    
    if (!validator.validateRequired(bidIncrement)) {
        showFieldError('bidIncrement', 'Bid increment is required');
        hasErrors = true;
    } else if (!validator.validateNumber(bidIncrement, 0.01)) {
        showFieldError('bidIncrement', 'Bid increment must be greater than 0');
        hasErrors = true;
    }
    
    if (!validator.validateRequired(endTime)) {
        showFieldError('endTime', 'End time is required');
        hasErrors = true;
    } else {
        // Validate end time is in the future
        const endDateTime = new Date(endTime);
        const now = new Date();
        if (endDateTime <= now) {
            showFieldError('endTime', 'End time must be in the future');
            hasErrors = true;
        }
    }
    
    // Validate real price if provided
    if (realPrice !== null && realPrice !== undefined && realPrice !== '') {
        if (!validator.validateNumber(realPrice, 0.01)) {
            showFieldError('realPrice', 'Real price must be greater than 0');
            hasErrors = true;
        } else if (realPrice <= startingBid) {
            showFieldError('realPrice', 'Real price must be higher than starting bid');
            hasErrors = true;
        }
    }
    
    if (hasErrors) {
        formError.textContent = 'Please fix the errors above';
        if (window.ToastManager) {
            ToastManager.show('Please fix the form errors', 'error');
        }
        return;
    }
    
    // Get uploaded image URLs (only successfully uploaded ones)
    const imageUrls = uploadedImageData
        .filter(img => img.url !== null)
        .map(img => img.url);
    
    // Parse image URLs from textarea
    const urlImages = imageUrlsText
        .split('\n')
        .map(url => url.trim())
        .filter(url => url.length > 0);
    
    imageUrls.push(...urlImages);
    
    // If no images provided, use placeholder
    if (imageUrls.length === 0) {
        imageUrls.push('https://via.placeholder.com/600x400?text=No+Image');
    }
    
    // Format end time for API
    const endDateTime = new Date(endTime);
    const endTimeISO = endDateTime.toISOString();
    
    try {
        const auctionData = {
            item_name: itemName,
            description: description,
            item_condition: itemCondition,
            category_id: parseInt(category),
            starting_bid: startingBid,
            bid_increment: bidIncrement,
            market_price: marketPrice,
            real_price: realPrice,  // Buy It Now / Real Price
            end_time: endTimeISO,
            featured: featured,
            images: imageUrls,
            video_url: videoUrl || null,
            featured_image_url: uploadedFeaturedImageUrl || null
        };
        
        const response = await AuctionAPI.create(auctionData);
        
        showToast('Auction created successfully!', 'success');
        
        // Redirect to auction detail page
        setTimeout(() => {
            window.location.href = `auction-detail.html?id=${response.id}`;
        }, 1500);
    } catch (error) {
        const errorMsg = error.message || 'Failed to create auction';
        formError.textContent = errorMsg;
        if (window.ErrorHandler) {
            ErrorHandler.handle(error, 'createAuction');
        } else {
            showToast(errorMsg, 'error');
        }
    }
}

// Helper function to show field errors
function showFieldError(fieldId, message) {
    const field = document.getElementById(fieldId);
    if (field) {
        field.classList.add('invalid');
        
        // Remove existing error message
        const existingError = field.parentElement.querySelector('.form-error');
        if (existingError) {
            existingError.remove();
        }
        
        // Add error message
        const errorDiv = document.createElement('div');
        errorDiv.className = 'form-error';
        errorDiv.textContent = message;
        field.parentElement.appendChild(errorDiv);
        
        // Remove error on input
        field.addEventListener('input', function removeError() {
            field.classList.remove('invalid');
            const error = field.parentElement.querySelector('.form-error');
            if (error) {
                error.remove();
            }
            field.removeEventListener('input', removeError);
        }, { once: true });
    }
}

