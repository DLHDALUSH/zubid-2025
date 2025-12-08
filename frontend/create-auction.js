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
        stopQRScanner(); // Stop camera if running
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

    // Show preview
    const preview = document.getElementById('uploadPreview');
    const previewImage = document.getElementById('previewImage');
    const dropzone = document.getElementById('qrDropzone');

    previewImage.src = URL.createObjectURL(file);
    preview.style.display = 'block';
    dropzone.style.display = 'none';

    updateScannerStatus('loading', 'Scanning QR code...');

    try {
        // Use Html5Qrcode to scan the file
        const html5QrCode = new Html5Qrcode("qr-reader-file-temp");

        const result = await html5QrCode.scanFile(file, true);

        // Success!
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
    const statusDiv = document.getElementById('qrScannerStatus');
    const statusText = document.getElementById('qrStatusText');

    if (!qrReaderElement) return;

    // Check if html5Qrcode is available
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

        // Update UI to loading state
        updateScannerStatus('loading', 'Initializing camera...');
        if (placeholder) placeholder.classList.add('hidden');

        // Create new scanner instance
        html5QrcodeScanner = new Html5Qrcode("qr-reader");

        // Get available cameras
        Html5Qrcode.getCameras().then(cameras => {
            availableCameras = cameras;

            // Show switch camera button if multiple cameras available
            if (switchBtn && cameras.length > 1) {
                switchBtn.style.display = 'flex';
            }

            // Determine which camera to use
            const cameraConfig = cameras.length > 0
                ? { deviceId: cameras[currentCameraIndex].id }
                : { facingMode: "environment" };

            // Start scanning with optimized settings
            html5QrcodeScanner.start(
                cameraConfig,
                {
                    fps: 15,
                    qrbox: { width: 280, height: 280 },
                    aspectRatio: 1.0,
                    disableFlip: false,
                    experimentalFeatures: {
                        useBarCodeDetectorIfSupported: true
                    }
                },
                (decodedText, decodedResult) => {
                    // Play success sound effect
                    playSuccessSound();
                    // Vibrate on mobile
                    if (navigator.vibrate) navigator.vibrate([100, 50, 100]);
                    // Success callback
                    onScanSuccess(decodedText, decodedResult);
                },
                (errorMessage) => {
                    // Error callback - ignore for continuous scanning
                }
            ).then(() => {
                // Update UI to scanning state
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
            console.error('Error getting cameras:', err);
            // Fall back to environment camera
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
        console.error('Fallback scanner failed:', err);
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
    } catch (e) {
        // Audio not supported
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
            // If not JSON, treat as plain text or URL
            if (decodedText.startsWith('http')) {
                qrData = { url: decodedText, raw_text: decodedText };
            } else {
                qrData = { raw_text: decodedText };
            }
        }

        // Fill form with scanned data
        fillFormFromQRData(qrData);

        // Show success message with rich data display
        const resultsDiv = document.getElementById('qr-reader-results');
        const dataDiv = document.getElementById('qr-scanned-data');
        if (resultsDiv && dataDiv) {
            resultsDiv.style.display = 'block';

            // Format the scanned data nicely
            let displayText = '';
            if (qrData.item_name) displayText += `📦 <strong>Item:</strong> ${qrData.item_name}<br>`;
            if (qrData.brand) displayText += `🏷️ <strong>Brand:</strong> ${qrData.brand}<br>`;
            if (qrData.category) displayText += `📁 <strong>Category:</strong> ${qrData.category}<br>`;
            if (qrData.price || qrData.starting_bid) displayText += `💰 <strong>Price:</strong> $${qrData.price || qrData.starting_bid}<br>`;
            if (qrData.condition) displayText += `✨ <strong>Condition:</strong> ${qrData.condition}<br>`;
            if (qrData.url) displayText += `🔗 <strong>URL:</strong> <a href="${qrData.url}" target="_blank">${qrData.url.substring(0, 40)}...</a><br>`;
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

        // ========================================
        // PRODUCT NAME (item_name, name, title, product_name)
        // ========================================
        const productName = qrData.item_name || qrData.name || qrData.title || qrData.product_name || qrData.product;
        if (productName) {
            const itemNameInput = document.getElementById('itemName');
            if (itemNameInput) {
                itemNameInput.value = productName;
                filledFields.push('Product Name');
            }
        }

        // ========================================
        // DESCRIPTION (description, desc, details, info)
        // ========================================
        const description = qrData.description || qrData.desc || qrData.details || qrData.info;
        if (description) {
            const descInput = document.getElementById('description');
            if (descInput) {
                descInput.value = description;
                filledFields.push('Description');
            }
        } else if (productName) {
            // Auto-generate description from product data
            const descInput = document.getElementById('description');
            if (descInput && !descInput.value) {
                let autoDesc = `🏷️ ${productName}`;
                if (qrData.brand) autoDesc += `\n🏭 Brand: ${qrData.brand}`;
                if (qrData.model) autoDesc += `\n📱 Model: ${qrData.model}`;
                if (qrData.color) autoDesc += `\n🎨 Color: ${qrData.color}`;
                if (qrData.size) autoDesc += `\n📏 Size: ${qrData.size}`;
                if (qrData.material) autoDesc += `\n🧵 Material: ${qrData.material}`;
                if (qrData.year) autoDesc += `\n📅 Year: ${qrData.year}`;
                if (qrData.serial_number || qrData.sku) autoDesc += `\n🔢 S/N: ${qrData.serial_number || qrData.sku}`;
                descInput.value = autoDesc;
                filledFields.push('Description (auto-generated)');
            }
        }

        // ========================================
        // ITEM CONDITION (condition, item_condition, state)
        // ========================================
        const condition = qrData.condition || qrData.item_condition || qrData.state;
        if (condition) {
            const conditionInput = document.getElementById('itemCondition');
            if (conditionInput) {
                // Map common condition values to select options
                const conditionMap = {
                    'new': 'new', 'brand new': 'new', 'sealed': 'new', 'unused': 'new',
                    'like new': 'like_new', 'like-new': 'like_new', 'mint': 'like_new', 'excellent': 'like_new',
                    'good': 'good', 'very good': 'good', 'great': 'good',
                    'fair': 'fair', 'okay': 'fair', 'average': 'fair',
                    'used': 'used', 'pre-owned': 'used', 'preowned': 'used',
                    'refurbished': 'refurbished', 'renewed': 'refurbished', 'restored': 'refurbished',
                    'for parts': 'for_parts', 'parts only': 'for_parts', 'broken': 'for_parts', 'damaged': 'for_parts'
                };
                const normalizedCondition = conditionMap[condition.toLowerCase()] || condition.toLowerCase();
                conditionInput.value = normalizedCondition;
                filledFields.push('Condition');
            }
        }

        // ========================================
        // CATEGORY (category, category_id, type, product_type)
        // ========================================
        const category = qrData.category || qrData.category_id || qrData.type || qrData.product_type;
        if (category) {
            const categoryInput = document.getElementById('category');
            if (categoryInput) {
                // Try to find matching category option
                const options = categoryInput.options;
                for (let i = 0; i < options.length; i++) {
                    if (options[i].value == category ||
                        options[i].text.toLowerCase().includes(category.toLowerCase())) {
                        categoryInput.value = options[i].value;
                        filledFields.push('Category');
                        break;
                    }
                }
            }
        }

        // ========================================
        // STARTING BID / PRICE (price, starting_bid, starting_price, msrp, retail_price)
        // ========================================
        const price = qrData.price || qrData.starting_bid || qrData.starting_price || qrData.msrp || qrData.retail_price || qrData.value;
        if (price) {
            const startingBidInput = document.getElementById('startingBid');
            if (startingBidInput) {
                // Extract numeric value from price string
                const numericPrice = parseFloat(String(price).replace(/[^0-9.]/g, ''));
                if (!isNaN(numericPrice)) {
                    startingBidInput.value = numericPrice;
                    filledFields.push('Starting Bid');
                }
            }
        }

        // ========================================
        // IMAGE URLS (images, image_urls, photos, image, photo_url)
        // ========================================
        const images = qrData.images || qrData.image_urls || qrData.photos ||
                      (qrData.image ? [qrData.image] : null) ||
                      (qrData.photo_url ? [qrData.photo_url] : null);
        if (images && Array.isArray(images) && images.length > 0) {
            const imageUrlsInput = document.getElementById('imageUrls');
            if (imageUrlsInput) {
                imageUrlsInput.value = images.join('\n');
                filledFields.push(`Images (${images.length})`);
                // Trigger change event to process URLs
                imageUrlsInput.dispatchEvent(new Event('change'));
            }
        } else if (typeof images === 'string' && images.startsWith('http')) {
            const imageUrlsInput = document.getElementById('imageUrls');
            if (imageUrlsInput) {
                imageUrlsInput.value = images;
                filledFields.push('Image URL');
                imageUrlsInput.dispatchEvent(new Event('change'));
            }
        }

        // ========================================
        // VIDEO URL (video, video_url, youtube, youtube_url)
        // ========================================
        const video = qrData.video || qrData.video_url || qrData.youtube || qrData.youtube_url;
        if (video) {
            const videoInput = document.getElementById('videoUrl');
            if (videoInput) {
                videoInput.value = video;
                filledFields.push('Video URL');
            }
        }

        // ========================================
        // FEATURED AUCTION (featured, is_featured)
        // ========================================
        if (qrData.featured || qrData.is_featured) {
            const featuredInput = document.getElementById('featured');
            if (featuredInput) {
                featuredInput.checked = true;
                filledFields.push('Featured');
            }
        }

        // ========================================
        // SHOW FILLED FIELDS SUMMARY
        // ========================================
        if (filledFields.length > 0) {
            console.log('✅ QR Scanner filled fields:', filledFields);
            showToast(`📋 Filled: ${filledFields.join(', ')}`, 'success');
        }

        // If auction_id is present, try to fetch more details from API
        if (qrData.auction_id && qrData.type === 'auction_item') {
            fetchAuctionDetails(qrData.auction_id);
        }

        // Scroll to form after filling
        setTimeout(() => {
            const form = document.getElementById('createAuctionForm');
            if (form) {
                form.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
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

        // Construct full URL using unified converter
        const baseUrl = window.API_BASE || (window.location.hostname === 'localhost' ? 'http://localhost:5000' : window.location.origin);
        const fullUrl = baseUrl + (result.url.startsWith('/') ? result.url : '/' + result.url);
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

            // Construct full URL using unified converter
            let baseUrl = 'http://localhost:5000';
            try {
                if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
                    baseUrl = String(API_BASE_URL).replace('/api', '').replace(/\/$/, '');
                }
            } catch (e) {
                console.warn('Error parsing API_BASE_URL:', e);
            }

            const fullUrl = baseUrl + (result.url.startsWith('/') ? result.url : '/' + result.url);
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

