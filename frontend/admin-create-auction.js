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

// ==========================================
// PREMIUM QR CODE SCANNER FUNCTIONS
// ==========================================

let currentCameraIndex = 0;
let availableCameras = [];
let currentScannerMode = 'upload';

// Switch between Upload and Camera modes
function switchScannerMode(mode) {
    currentScannerMode = mode;
    const tabUpload = document.getElementById('tabUpload');
    const tabCamera = document.getElementById('tabCamera');
    const uploadSection = document.getElementById('uploadSection');
    const cameraSection = document.getElementById('cameraSection');

    if (mode === 'upload') {
        tabUpload.classList.add('active');
        tabCamera.classList.remove('active');
        uploadSection.style.display = 'block';
        cameraSection.style.display = 'none';
        stopQRScanner();
        updateScannerStatus('idle', 'Ready to scan image');
    } else {
        tabUpload.classList.remove('active');
        tabCamera.classList.add('active');
        uploadSection.style.display = 'none';
        cameraSection.style.display = 'block';
        updateScannerStatus('idle', 'Click Start Camera');
    }
}

// Scan QR code from uploaded file
async function scanQRFromFile(event) {
    const file = event.target.files[0];
    if (!file) return;

    const preview = document.getElementById('uploadPreview');
    const previewImage = document.getElementById('previewImage');
    const dropzone = document.getElementById('qrDropzone');

    previewImage.src = URL.createObjectURL(file);
    preview.style.display = 'block';
    dropzone.style.display = 'none';

    updateScannerStatus('loading', 'Scanning QR code...');

    try {
        const html5QrCode = new Html5Qrcode("qr-reader-file-temp");
        const result = await html5QrCode.scanFile(file, true);

        playSuccessSound();
        if (navigator.vibrate) navigator.vibrate([100, 50, 100]);

        updateScannerStatus('active', 'QR Code found!');
        onScanSuccess(result, { result: { text: result } });

        html5QrCode.clear();
    } catch (error) {
        console.error('QR Scan error:', error);
        updateScannerStatus('error', 'No QR code found in image');
        showToast('No QR code found in the image. Please try another image.', 'error');
    }
}

// Clear upload preview
function clearUploadPreview() {
    const preview = document.getElementById('uploadPreview');
    const dropzone = document.getElementById('qrDropzone');
    const fileInput = document.getElementById('qrFileInput');
    const resultsDiv = document.getElementById('qr-reader-results');

    preview.style.display = 'none';
    dropzone.style.display = 'flex';
    fileInput.value = '';
    resultsDiv.style.display = 'none';
    updateScannerStatus('idle', 'Ready to scan image');
}

// Setup drag and drop
document.addEventListener('DOMContentLoaded', () => {
    const dropzone = document.getElementById('qrDropzone');
    if (dropzone) {
        dropzone.addEventListener('dragover', (e) => {
            e.preventDefault();
            dropzone.classList.add('dragover');
        });

        dropzone.addEventListener('dragleave', () => {
            dropzone.classList.remove('dragover');
        });

        dropzone.addEventListener('drop', (e) => {
            e.preventDefault();
            dropzone.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                const fileInput = document.getElementById('qrFileInput');
                fileInput.files = files;
                scanQRFromFile({ target: { files: files } });
            }
        });
    }
});

async function startQRScanner() {
    const qrReaderElement = document.getElementById('qr-reader');
    const startBtn = document.getElementById('startQrScanner');
    const stopBtn = document.getElementById('stopQrScanner');
    const switchBtn = document.getElementById('switchCameraBtn');
    const resultsDiv = document.getElementById('qr-reader-results');
    const viewport = document.getElementById('qrScannerViewport');
    const placeholder = document.getElementById('qrPlaceholder');

    if (!qrReaderElement) return;

    if (typeof Html5Qrcode === 'undefined') {
        showToast('QR Scanner library not loaded. Please refresh the page.', 'error');
        updateScannerStatus('error', 'Library not loaded');
        return;
    }

    try {
        // Clear previous scanner if exists
        if (html5QrcodeScanner) {
            try {
                await html5QrcodeScanner.stop();
            } catch (e) {
                // Scanner wasn't running, ignore
            }
            try {
                html5QrcodeScanner.clear();
            } catch (e) {}
            html5QrcodeScanner = null;
        }

        updateScannerStatus('loading', 'Initializing camera...');
        if (placeholder) placeholder.classList.add('hidden');

        html5QrcodeScanner = new Html5Qrcode("qr-reader");

        Html5Qrcode.getCameras().then(cameras => {
            availableCameras = cameras;
            if (switchBtn && cameras.length > 1) switchBtn.style.display = 'flex';

            const cameraConfig = cameras.length > 0
                ? { deviceId: cameras[currentCameraIndex].id }
                : { facingMode: "environment" };

            html5QrcodeScanner.start(
                cameraConfig,
                { fps: 15, qrbox: { width: 280, height: 280 }, aspectRatio: 1.0, experimentalFeatures: { useBarCodeDetectorIfSupported: true } },
                (decodedText, decodedResult) => {
                    playSuccessSound();
                    if (navigator.vibrate) navigator.vibrate([100, 50, 100]);
                    onScanSuccess(decodedText, decodedResult);
                },
                () => {}
            ).then(() => {
                startBtn.style.display = 'none';
                stopBtn.style.display = 'flex';
                resultsDiv.style.display = 'none';
                if (viewport) viewport.classList.add('scanning');
                updateScannerStatus('active', 'Scanning for QR codes...');
                showToast('📷 Camera active! Point at QR code.', 'info');
            }).catch((err) => {
                console.error('Failed to start QR scanner:', err);
                if (placeholder) placeholder.classList.remove('hidden');
                updateScannerStatus('error', 'Camera access denied');
                showToast('Failed to start camera. Please check permissions.', 'error');
            });
        }).catch(err => {
            startWithFallback();
        });
    } catch (error) {
        console.error('Error starting QR scanner:', error);
        updateScannerStatus('error', 'Scanner error');
        showToast('Failed to start QR scanner: ' + error.message, 'error');
    }
}

function startWithFallback() {
    const viewport = document.getElementById('qrScannerViewport');
    const startBtn = document.getElementById('startQrScanner');
    const stopBtn = document.getElementById('stopQrScanner');
    const resultsDiv = document.getElementById('qr-reader-results');

    html5QrcodeScanner = new Html5Qrcode("qr-reader");
    html5QrcodeScanner.start(
        { facingMode: "environment" },
        { fps: 15, qrbox: { width: 280, height: 280 }, aspectRatio: 1.0 },
        (decodedText, decodedResult) => {
            playSuccessSound();
            if (navigator.vibrate) navigator.vibrate([100, 50, 100]);
            onScanSuccess(decodedText, decodedResult);
        },
        () => {}
    ).then(() => {
        startBtn.style.display = 'none';
        stopBtn.style.display = 'flex';
        resultsDiv.style.display = 'none';
        if (viewport) viewport.classList.add('scanning');
        updateScannerStatus('active', 'Scanning for QR codes...');
    }).catch((err) => {
        updateScannerStatus('error', 'Camera not available');
    });
}

function stopQRScanner() {
    const startBtn = document.getElementById('startQrScanner');
    const stopBtn = document.getElementById('stopQrScanner');
    const switchBtn = document.getElementById('switchCameraBtn');
    const viewport = document.getElementById('qrScannerViewport');
    const placeholder = document.getElementById('qrPlaceholder');

    const resetUI = () => {
        if (startBtn) startBtn.style.display = 'flex';
        if (stopBtn) stopBtn.style.display = 'none';
        if (switchBtn) switchBtn.style.display = 'none';
        if (viewport) viewport.classList.remove('scanning');
        if (placeholder) placeholder.classList.remove('hidden');
        updateScannerStatus('idle', 'Scanner Idle');
    };

    if (html5QrcodeScanner) {
        html5QrcodeScanner.stop().then(() => {
            try { html5QrcodeScanner.clear(); } catch (e) {}
            html5QrcodeScanner = null;
            resetUI();
        }).catch((err) => {
            // Scanner might not be running, just reset UI
            try { html5QrcodeScanner.clear(); } catch (e) {}
            html5QrcodeScanner = null;
            resetUI();
        });
    } else {
        resetUI();
    }
}

function switchCamera() {
    if (availableCameras.length <= 1) return;

    currentCameraIndex = (currentCameraIndex + 1) % availableCameras.length;
    const cameraName = availableCameras[currentCameraIndex].label || `Camera ${currentCameraIndex + 1}`;
    showToast(`Switching to: ${cameraName}`, 'info');

    if (html5QrcodeScanner) {
        html5QrcodeScanner.stop().then(() => {
            try { html5QrcodeScanner.clear(); } catch (e) {}
            html5QrcodeScanner = null;
            setTimeout(() => startQRScanner(), 300);
        }).catch(() => {
            html5QrcodeScanner = null;
            setTimeout(() => startQRScanner(), 300);
        });
    } else {
        setTimeout(() => startQRScanner(), 300);
    }
}

function updateScannerStatus(state, text) {
    const statusDiv = document.getElementById('qrScannerStatus');
    const statusText = document.getElementById('qrStatusText');
    if (statusDiv && statusText) {
        statusDiv.classList.remove('active', 'error');
        if (state === 'active') statusDiv.classList.add('active');
        if (state === 'error') statusDiv.style.background = 'rgba(239, 68, 68, 0.15)';
        else statusDiv.style.background = '';
        statusText.textContent = text;
    }
}

function playSuccessSound() {
    try {
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        const oscillator = audioContext.createOscillator();
        const gainNode = audioContext.createGain();
        oscillator.connect(gainNode);
        gainNode.connect(audioContext.destination);
        oscillator.frequency.value = 880;
        oscillator.type = 'sine';
        gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2);
        oscillator.start(audioContext.currentTime);
        oscillator.stop(audioContext.currentTime + 0.2);
    } catch (e) {}
}

function onScanSuccess(decodedText, decodedResult) {
    stopQRScanner();

    try {
        let qrData;
        try {
            qrData = JSON.parse(decodedText);
        } catch (e) {
            if (decodedText.startsWith('http')) {
                qrData = { url: decodedText, raw_text: decodedText };
            } else {
                qrData = { raw_text: decodedText };
            }
        }

        fillFormFromQRData(qrData);

        const resultsDiv = document.getElementById('qr-reader-results');
        const dataDiv = document.getElementById('qr-scanned-data');
        if (resultsDiv && dataDiv) {
            resultsDiv.style.display = 'block';
            let displayText = '';
            if (qrData.item_name) displayText += `📦 <strong>Item:</strong> ${qrData.item_name}<br>`;
            if (qrData.brand) displayText += `🏷️ <strong>Brand:</strong> ${qrData.brand}<br>`;
            if (qrData.category) displayText += `📁 <strong>Category:</strong> ${qrData.category}<br>`;
            if (qrData.price || qrData.starting_bid) displayText += `💰 <strong>Price:</strong> $${qrData.price || qrData.starting_bid}<br>`;
            if (qrData.condition) displayText += `✨ <strong>Condition:</strong> ${qrData.condition}<br>`;
            if (qrData.url) displayText += `🔗 <strong>URL:</strong> <a href="${qrData.url}" target="_blank" style="color: #06b6d4;">${qrData.url.substring(0, 40)}...</a><br>`;
            if (!displayText && qrData.raw_text) displayText = `📝 ${qrData.raw_text}`;
            dataDiv.innerHTML = displayText || 'QR Code scanned successfully';
        }

        updateScannerStatus('idle', 'Scan complete!');
        showToast('✅ QR Code scanned! Form filled automatically.', 'success');
    } catch (error) {
        console.error('Error processing QR code:', error);
        updateScannerStatus('error', 'Processing error');
        showToast('Error processing QR code: ' + error.message, 'error');
    }
}

function fillFormFromQRData(qrData) {
    try {
        let filledFields = [];

        // PRODUCT NAME
        const productName = qrData.item_name || qrData.name || qrData.title || qrData.product_name || qrData.product;
        if (productName) {
            const itemNameInput = document.getElementById('itemName');
            if (itemNameInput) {
                itemNameInput.value = productName;
                filledFields.push('Product Name');
            }
        }

        // DESCRIPTION
        const description = qrData.description || qrData.desc || qrData.details || qrData.info;
        if (description) {
            const descInput = document.getElementById('description');
            if (descInput) {
                descInput.value = description;
                filledFields.push('Description');
            }
        } else if (productName) {
            const descInput = document.getElementById('description');
            if (descInput && !descInput.value) {
                let autoDesc = `🏷️ ${productName}`;
                if (qrData.brand) autoDesc += `\n🏭 Brand: ${qrData.brand}`;
                if (qrData.model) autoDesc += `\n📱 Model: ${qrData.model}`;
                if (qrData.color) autoDesc += `\n🎨 Color: ${qrData.color}`;
                if (qrData.size) autoDesc += `\n📏 Size: ${qrData.size}`;
                descInput.value = autoDesc;
                filledFields.push('Description (auto)');
            }
        }

        // ITEM CONDITION
        const condition = qrData.condition || qrData.item_condition || qrData.state;
        if (condition) {
            const conditionInput = document.getElementById('itemCondition');
            if (conditionInput) {
                const conditionMap = {
                    'new': 'new', 'brand new': 'new', 'sealed': 'new',
                    'like new': 'like_new', 'like-new': 'like_new', 'mint': 'like_new',
                    'good': 'good', 'very good': 'good',
                    'fair': 'fair', 'used': 'used', 'refurbished': 'refurbished'
                };
                conditionInput.value = conditionMap[condition.toLowerCase()] || condition.toLowerCase();
                filledFields.push('Condition');
            }
        }

        // CATEGORY
        const category = qrData.category || qrData.category_id || qrData.type || qrData.product_type;
        if (category) {
            const categoryInput = document.getElementById('category');
            if (categoryInput) {
                for (let i = 0; i < categoryInput.options.length; i++) {
                    if (categoryInput.options[i].value == category ||
                        categoryInput.options[i].text.toLowerCase().includes(category.toLowerCase())) {
                        categoryInput.value = categoryInput.options[i].value;
                        filledFields.push('Category');
                        break;
                    }
                }
            }
        }

        // STARTING BID / PRICE
        const price = qrData.price || qrData.starting_bid || qrData.starting_price || qrData.msrp || qrData.value;
        if (price) {
            const startingBidInput = document.getElementById('startingBid');
            if (startingBidInput) {
                const numericPrice = parseFloat(String(price).replace(/[^0-9.]/g, ''));
                if (!isNaN(numericPrice)) {
                    startingBidInput.value = numericPrice;
                    filledFields.push('Starting Bid');
                }
            }
        }

        // IMAGE URLS
        const images = qrData.images || qrData.image_urls || (qrData.image ? [qrData.image] : null);
        if (images && Array.isArray(images) && images.length > 0) {
            const imageUrlsInput = document.getElementById('imageUrls');
            if (imageUrlsInput) {
                imageUrlsInput.value = images.join('\n');
                filledFields.push(`Images (${images.length})`);
            }
        }

        // VIDEO URL
        const video = qrData.video || qrData.video_url || qrData.youtube;
        if (video) {
            const videoInput = document.getElementById('videoUrl');
            if (videoInput) {
                videoInput.value = video;
                filledFields.push('Video URL');
            }
        }

        // FEATURED
        if (qrData.featured || qrData.is_featured) {
            const featuredInput = document.getElementById('featured');
            if (featuredInput) {
                featuredInput.checked = true;
                filledFields.push('Featured');
            }
        }

        if (filledFields.length > 0) {
            console.log('✅ QR Scanner filled fields:', filledFields);
            showToast(`📋 Filled: ${filledFields.join(', ')}`, 'success');
        }

        if (qrData.auction_id && qrData.type === 'auction_item') {
            fetchAuctionDetails(qrData.auction_id);
        }

        setTimeout(() => {
            const form = document.getElementById('createAuctionForm');
            if (form) form.scrollIntoView({ behavior: 'smooth', block: 'start' });
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

