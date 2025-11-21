// Admin Create Auction Page
let uploadedImages = [];
let html5QrcodeScanner = null;

document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadCategories();
    
    // Set default end time to 7 days from now
    const defaultEndTime = new Date();
    defaultEndTime.setDate(defaultEndTime.getDate() + 7);
    const endTimeInput = document.getElementById('endTime');
    if (endTimeInput) {
        endTimeInput.value = defaultEndTime.toISOString().slice(0, 16);
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
        showToast('Error loading categories', 'error');
    }
}

// Preview uploaded images
function previewUploadedImages(event) {
    const files = event.target.files;
    const previewContainer = document.getElementById('imagePreviewContainer');
    uploadedImages = [];
    
    if (files.length === 0) {
        previewContainer.innerHTML = '';
        return;
    }
    
    previewContainer.innerHTML = '';
    
    Array.from(files).forEach((file, index) => {
        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
            alert(`File "${file.name}" is too large. Maximum size is 5MB.`);
            return;
        }
        
        const reader = new FileReader();
        
        reader.onload = function(e) {
            // Compress image to reduce size
            const img = new Image();
            img.onload = function() {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');
                
                // Resize to max 1200x1200 while maintaining aspect ratio
                let width = img.width;
                let height = img.height;
                const maxSize = 1200;
                
                if (width > maxSize || height > maxSize) {
                    if (width > height) {
                        height = (height / width) * maxSize;
                        width = maxSize;
                    } else {
                        width = (width / height) * maxSize;
                        height = maxSize;
                    }
                }
                
                canvas.width = width;
                canvas.height = height;
                ctx.drawImage(img, 0, 0, width, height);
                
                // Convert to base64 with 80% quality
                const compressedBase64 = canvas.toDataURL('image/jpeg', 0.8);
                uploadedImages.push(compressedBase64);
                
                // Create preview div
                const previewDiv = document.createElement('div');
                previewDiv.style.position = 'relative';
                previewDiv.style.width = '100%';
                previewDiv.style.aspectRatio = '1';
                previewDiv.style.overflow = 'hidden';
                previewDiv.style.borderRadius = '8px';
                previewDiv.style.border = '2px solid var(--border-color)';
                
                const previewImg = document.createElement('img');
                previewImg.src = compressedBase64;
                previewImg.style.width = '100%';
                previewImg.style.height = '100%';
                previewImg.style.objectFit = 'cover';
                
                const removeBtn = document.createElement('button');
                removeBtn.textContent = '×';
                removeBtn.style.position = 'absolute';
                removeBtn.style.top = '4px';
                removeBtn.style.right = '4px';
                removeBtn.style.background = 'var(--error-color)';
                removeBtn.style.color = 'white';
                removeBtn.style.border = 'none';
                removeBtn.style.borderRadius = '50%';
                removeBtn.style.width = '24px';
                removeBtn.style.height = '24px';
                removeBtn.style.cursor = 'pointer';
                removeBtn.style.fontSize = '18px';
                removeBtn.style.lineHeight = '1';
                removeBtn.onclick = function() {
                    uploadedImages = uploadedImages.filter((_, i) => i !== index);
                    previewDiv.remove();
                    // Reset file input
                    document.getElementById('images').value = '';
                };
                
                previewDiv.appendChild(previewImg);
                previewDiv.appendChild(removeBtn);
                previewContainer.appendChild(previewDiv);
            };
            
            img.src = e.target.result;
        };
        
        reader.readAsDataURL(file);
    });
}

// Handle create auction form submission
async function handleCreateAuction(event) {
    event.preventDefault();
    
    const formError = document.getElementById('formError');
    formError.textContent = '';
    
    // Get form values
    const itemName = document.getElementById('itemName').value;
    const description = document.getElementById('description').value;
    const itemCondition = document.getElementById('itemCondition').value;
    const category = document.getElementById('category').value;
    const startingBid = parseFloat(document.getElementById('startingBid').value);
    const bidIncrement = parseFloat(document.getElementById('bidIncrement').value);
    const endTime = document.getElementById('endTime').value;
    const featured = document.getElementById('featured').checked;
    const imageUrlsText = document.getElementById('imageUrls').value;
    const videoUrl = document.getElementById('videoUrl') ? document.getElementById('videoUrl').value.trim() : '';
    
    // Validate
    if (!itemName || !description || !itemCondition || !category || !startingBid || !endTime) {
        formError.textContent = 'Please fill in all required fields';
        return;
    }
    
    if (startingBid <= 0) {
        formError.textContent = 'Starting bid must be greater than 0';
        return;
    }
    
    if (bidIncrement <= 0) {
        formError.textContent = 'Bid increment must be greater than 0';
        return;
    }
    
    // Get images - prioritize uploaded images, fallback to URLs, then placeholder
    let images = [];
    
    if (uploadedImages.length > 0) {
        images = uploadedImages;
    } else if (imageUrlsText.trim()) {
        images = imageUrlsText
            .split('\n')
            .map(url => url.trim())
            .filter(url => url.length > 0);
    }
    
    // If no images provided, use placeholder
    if (images.length === 0) {
        images.push('https://via.placeholder.com/600x400?text=No+Image+Available');
    }
    
    // Format end time for API
    const endDateTime = new Date(endTime);
    const endTimeISO = endDateTime.toISOString();
    
    const submitBtn = event.target.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.textContent = 'Creating...';
    
    try {
        const auctionData = {
            item_name: itemName,
            description: description,
            item_condition: itemCondition,
            category_id: parseInt(category),
            starting_bid: startingBid,
            bid_increment: bidIncrement,
            end_time: endTimeISO,
            featured: featured,
            images: images,
            video_url: videoUrl || null
        };
        
        const response = await AuctionAPI.create(auctionData);
        
        showToast('Auction created successfully!', 'success');
        
        // Reset form
        resetForm();
        
        // Redirect to admin auctions page after a short delay
        setTimeout(() => {
            window.location.href = 'admin-auctions.html';
        }, 1500);
    } catch (error) {
        console.error('Error creating auction:', error);
        formError.textContent = error.message || 'Failed to create auction';
        showToast(error.message || 'Failed to create auction', 'error');
    } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
    }
}

// Reset form
function resetForm() {
    document.getElementById('createAuctionForm').reset();
    document.getElementById('formError').textContent = '';
    document.getElementById('imagePreviewContainer').innerHTML = '';
    uploadedImages = [];
    
    // Stop QR scanner if running
    if (html5QrcodeScanner) {
        stopQRScanner();
    }
    
    // Clear QR scanner results
    const resultsDiv = document.getElementById('qr-reader-results');
    if (resultsDiv) {
        resultsDiv.style.display = 'none';
    }
    
    // Reset default end time
    const defaultEndTime = new Date();
    defaultEndTime.setDate(defaultEndTime.getDate() + 7);
    const endTimeInput = document.getElementById('endTime');
    if (endTimeInput) {
        endTimeInput.value = defaultEndTime.toISOString().slice(0, 16);
    }
    
    // Reset bid increment to default
    const bidIncrementInput = document.getElementById('bidIncrement');
    if (bidIncrementInput) {
        bidIncrementInput.value = '1.00';
    }
}

