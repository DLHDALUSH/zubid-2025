// Admin Auctions Management
let currentPage = 1;
let currentStatus = '';

document.addEventListener('DOMContentLoaded', async () => {
    await checkAdminAuth();
    await loadAuctions();
});

async function loadAuctions(page = 1) {
    currentPage = page;
    currentStatus = document.getElementById('statusFilter').value;
    
    const tbody = document.getElementById('auctionsTableBody');
    tbody.innerHTML = '<tr><td colspan="11" class="loading">Loading auctions...</td></tr>';
    
    try {
        const data = await AdminAPI.getAuctions(page, currentStatus);
        
        if (data.auctions && data.auctions.length > 0) {
            // Escape user input to prevent XSS
            const escapeHtml = (text) => {
                if (text == null) return '';
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            };
            
	            tbody.innerHTML = data.auctions.map(auction => {
	                const itemName = escapeHtml(auction.item_name || '');
	                const seller = escapeHtml(auction.seller || '');
	                const winnerName = escapeHtml(auction.winner_name || '');
	                const rawStatus = auction.status || '';
	                const statusLabel = escapeHtml(rawStatus);
	                const allowedStatuses = ['pending', 'active', 'ended', 'cancelled', 'draft'];
	                const safeStatusClass = allowedStatuses.includes(rawStatus) ? rawStatus : 'other';
	                const itemCode = escapeHtml(auction.item_code || `ZUBID-${String(auction.id).padStart(6, '0')}`);
	                const statusEscaped = statusLabel;
	                const safeId = Number(auction.id) || 0;
	                return `
	                <tr>
	                    <td>${safeId}</td>
                    <td><strong>${itemCode}</strong></td>
                    <td>${itemName}</td>
                    <td>${seller}</td>
                    <td>$${(auction.current_bid || 0).toFixed(2)}</td>
	                    <td>${auction.bid_count || 0}</td>
	                    <td><span class="status-badge ${safeStatusClass}">${statusLabel}</span></td>
                    <td>${auction.featured ? '✓' : ''}</td>
	                    <td>${winnerName || '<span style="color: #999;">-</span>'}</td>
                    <td>${new Date(auction.end_time).toLocaleString()}</td>
                    <td class="actions">
                        <button class="btn btn-small btn-primary edit-auction-btn" 
	                                data-auction-id="${safeId}" 
                                data-status="${statusEscaped}" 
                                data-featured="${auction.featured ? 'true' : 'false'}">Edit</button>
                        <button class="btn btn-small btn-danger delete-auction-btn" 
                                data-auction-id="${auction.id}">Delete</button>
                    </td>
                </tr>
            `;
            }).join('');
            
            // Attach event listeners after rendering
            tbody.querySelectorAll('.edit-auction-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    const id = parseInt(this.dataset.auctionId);
                    const status = this.dataset.status;
                    const featured = this.dataset.featured === 'true';
                    editAuction(id, status, featured);
                });
            });
            
            tbody.querySelectorAll('.delete-auction-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    const id = parseInt(this.dataset.auctionId);
                    deleteAuction(id);
                });
            });
            
            renderPagination(data, 'auctionPagination');
        } else {
            tbody.innerHTML = '<tr><td colspan="11">No auctions found</td></tr>';
        }
    } catch (error) {
        if (window.utils) window.utils.debugError('Error loading auctions:', error);
        const errorMsg = error.message || 'Unknown error';
        tbody.innerHTML = `<tr><td colspan="11">Error: ${errorMsg.replace(/</g, '&lt;').replace(/>/g, '&gt;')}</td></tr>`;
        showToast('Error loading auctions', 'error');
    }
}

function resetAuctionFilters() {
    document.getElementById('statusFilter').value = '';
    loadAuctions(1);
}

function editAuction(auctionId, status, featured) {
    document.getElementById('editAuctionId').value = auctionId;
    document.getElementById('editStatus').value = status;
    document.getElementById('editFeatured').checked = featured;
    const modal = document.getElementById('editAuctionModal');
    modal.classList.add('active');
    modal.style.display = 'flex';
}

async function handleUpdateAuction(event) {
    event.preventDefault();
    
    const auctionId = document.getElementById('editAuctionId').value;
    const data = {
        status: document.getElementById('editStatus').value,
        featured: document.getElementById('editFeatured').checked
    };
    
    try {
        await AdminAPI.updateAuction(auctionId, data);
        showToast('Auction updated successfully', 'success');
        closeModal('editAuctionModal');
        await loadAuctions(currentPage);
    } catch (error) {
        showToast(error.message || 'Failed to update auction', 'error');
    }
}

async function deleteAuction(auctionId) {
    if (!confirm('Are you sure you want to delete this auction? This action cannot be undone.')) {
        return;
    }
    
    try {
        await AdminAPI.deleteAuction(auctionId);
        showToast('Auction deleted successfully', 'success');
        await loadAuctions(currentPage);
    } catch (error) {
        showToast(error.message || 'Failed to delete auction', 'error');
    }
}

function renderPagination(data, containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;
    
    if (data.pages <= 1) {
        container.innerHTML = '';
        return;
    }
    
    let html = '<div class="pagination-controls">';
    
    if (data.page > 1) {
        html += `<button class="btn btn-outline" onclick="loadAuctions(${data.page - 1})">Previous</button>`;
    }
    
    for (let i = 1; i <= data.pages; i++) {
        if (i === data.page) {
            html += `<button class="btn btn-primary">${i}</button>`;
        } else if (i === 1 || i === data.pages || (i >= data.page - 2 && i <= data.page + 2)) {
            html += `<button class="btn btn-outline" onclick="loadAuctions(${i})">${i}</button>`;
        } else if (i === data.page - 3 || i === data.page + 3) {
            html += `<span>...</span>`;
        }
    }
    
    if (data.page < data.pages) {
        html += `<button class="btn btn-outline" onclick="loadAuctions(${data.page + 1})">Next</button>`;
    }
    
    html += '</div>';
    container.innerHTML = html;
}

// Load categories for create auction form
async function loadCategoriesForCreate() {
    try {
        const categories = await CategoryAPI.getAll();
        const select = document.getElementById('createCategory');
        select.innerHTML = '<option value="">Select Category</option>';
        categories.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id;
            option.textContent = cat.name;
            select.appendChild(option);
        });
    } catch (error) {
        if (window.utils) window.utils.debugError('Error loading categories:', error);
    }
}

function openCreateAuctionModal() {
    const modal = document.getElementById('createAuctionModal');
    modal.classList.add('active');
    modal.style.display = 'flex';
    loadCategoriesForCreate();
    // Reset form
    document.getElementById('createAuctionForm').reset();
    document.getElementById('createFormError').textContent = '';
    document.getElementById('imagePreviewContainer').innerHTML = '';
    uploadedImages = []; // Clear uploaded images array
}

// Store uploaded images as base64
// Store uploaded images with metadata
let uploadedImageData = []; // Array of {base64, previewDiv, index}

function previewUploadedImages(event) {
    const files = Array.from(event.target.files);
    const previewContainer = document.getElementById('imagePreviewContainer');
    
    if (files.length === 0) {
        if (uploadedImageData.length === 0) {
            previewContainer.innerHTML = '';
        }
        return;
    }
    
    // Validate file sizes (max 5MB)
    const maxSize = 5 * 1024 * 1024;
    const invalidFiles = files.filter(file => file.size > maxSize);
    
    if (invalidFiles.length > 0) {
        alert(`Some files are too large. Maximum size is 5MB per image.`);
        event.target.value = '';
        return;
    }
    
    const startIndex = uploadedImageData.length;
    
    files.forEach((file, i) => {
        const imageIndex = startIndex + i;
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
                
                // Create preview div
                const previewDiv = document.createElement('div');
                previewDiv.className = 'image-preview-item';
                previewDiv.dataset.index = imageIndex;
                previewDiv.style.position = 'relative';
                previewDiv.style.width = '100%';
                previewDiv.style.aspectRatio = '1';
                previewDiv.style.overflow = 'hidden';
                previewDiv.style.borderRadius = '8px';
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
                
                const previewImg = document.createElement('img');
                previewImg.src = compressedBase64;
                previewImg.style.width = '100%';
                previewImg.style.height = '100%';
                previewImg.style.objectFit = 'cover';
                
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
                removeBtn.onclick = function(e) {
                    e.stopPropagation();
                    removeAdminImage(imageIndex);
                };
                
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
                    moveAdminImage(imageIndex, -1);
                };
                
                const moveDownBtn = document.createElement('button');
                moveDownBtn.innerHTML = '↓';
                moveDownBtn.className = 'image-move-btn';
                moveDownBtn.title = 'Move down';
                moveDownBtn.onclick = (e) => {
                    e.stopPropagation();
                    moveAdminImage(imageIndex, 1);
                };
                
                moveControls.appendChild(moveUpBtn);
                moveControls.appendChild(moveDownBtn);
                
                previewDiv.appendChild(previewImg);
                previewDiv.appendChild(numberBadge);
                previewDiv.appendChild(removeBtn);
                previewDiv.appendChild(moveControls);
                previewContainer.appendChild(previewDiv);
                
                // Store image data
                const imageData = {
                    base64: compressedBase64,
                    previewDiv: previewDiv,
                    index: imageIndex
                };
                uploadedImageData.push(imageData);
                updateAdminImageNumbers();
            };
            
            img.src = e.target.result;
        };
        
        reader.readAsDataURL(file);
    });
    
    // Clear file input
    event.target.value = '';
}

// Admin video upload state
let adminUploadedVideoUrl = null;
let adminUploadedVideoFile = null;

// Admin featured image upload state
let adminUploadedFeaturedImageUrl = null;
let adminUploadedFeaturedImageFile = null;

// Handle admin video file upload
async function handleAdminVideoFileChange(event) {
    const file = event.target.files[0];
    const previewContainer = document.getElementById('adminVideoPreviewContainer');
    const preview = document.getElementById('adminVideoPreview');
    const videoUrlInput = document.getElementById('createVideoUrl');
    
    if (!file) {
        previewContainer.style.display = 'none';
        adminUploadedVideoUrl = null;
        adminUploadedVideoFile = null;
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
    adminUploadedVideoFile = file;
    
    // Clear URL input when file is selected
    if (videoUrlInput) {
        videoUrlInput.value = '';
    }
    
    // Upload video file
    try {
        const result = await VideoAPI.upload(file);
        
        // Construct full URL
        const baseUrl = API_BASE_URL.replace('/api', '');
        const fullUrl = baseUrl + result.url;
        adminUploadedVideoUrl = fullUrl;
        
        showToast('Video uploaded successfully!', 'success');
    } catch (error) {
        console.error('Error uploading video:', error);
        showToast(error.message || 'Failed to upload video', 'error');
        previewContainer.style.display = 'none';
        event.target.value = '';
        adminUploadedVideoFile = null;
        adminUploadedVideoUrl = null;
    }
}

// Handle admin featured image upload
async function handleAdminFeaturedImageChange(event) {
    const file = event.target.files[0];
    const previewContainer = document.getElementById('adminFeaturedImagePreviewContainer');
    const preview = document.getElementById('adminFeaturedImagePreview');
    
    if (!file) {
        previewContainer.style.display = 'none';
        adminUploadedFeaturedImageUrl = null;
        adminUploadedFeaturedImageFile = null;
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
    const allowedExts = ['png', 'jpg', 'jpeg', 'gif', 'webp'];
    const fileExt = file.name.split('.').pop().toLowerCase();
    
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
    adminUploadedFeaturedImageFile = file;
    
        // Upload featured image file with high quality flag
        try {
            const result = await ImageAPI.upload(file, true); // Pass true for featured image
            
            // Construct full URL
            const baseUrl = API_BASE_URL.replace('/api', '');
            const fullUrl = baseUrl + result.url;
            adminUploadedFeaturedImageUrl = fullUrl;
            
            showToast('Featured image uploaded successfully with enhanced quality!', 'success');
    } catch (error) {
        console.error('Error uploading featured image:', error);
        showToast(error.message || 'Failed to upload featured image', 'error');
        previewContainer.style.display = 'none';
        event.target.value = '';
        adminUploadedFeaturedImageFile = null;
        adminUploadedFeaturedImageUrl = null;
    }
}

// Remove admin featured image
function removeAdminFeaturedImage() {
    const featuredImageInput = document.getElementById('createFeaturedImageFile');
    const previewContainer = document.getElementById('adminFeaturedImagePreviewContainer');
    const preview = document.getElementById('adminFeaturedImagePreview');
    
    if (preview && preview.src) {
        URL.revokeObjectURL(preview.src);
    }
    
    if (featuredImageInput) {
        featuredImageInput.value = '';
    }
    
    previewContainer.style.display = 'none';
    adminUploadedFeaturedImageUrl = null;
    adminUploadedFeaturedImageFile = null;
}

// Remove admin video file
function removeAdminVideoFile() {
    const videoFileInput = document.getElementById('createVideoFile');
    const previewContainer = document.getElementById('adminVideoPreviewContainer');
    const preview = document.getElementById('adminVideoPreview');
    
    if (preview && preview.src) {
        URL.revokeObjectURL(preview.src);
    }
    
    if (videoFileInput) {
        videoFileInput.value = '';
    }
    
    previewContainer.style.display = 'none';
    adminUploadedVideoUrl = null;
    adminUploadedVideoFile = null;
}

// Remove an image from admin form
function removeAdminImage(index) {
    const imageData = uploadedImageData[index];
    if (!imageData) return;
    
    // Remove from array
    uploadedImageData.splice(index, 1);
    
    // Remove from DOM
    if (imageData.previewDiv) {
        imageData.previewDiv.remove();
    }
    
    // Update indices
    uploadedImageData.forEach((img, i) => {
        img.index = i;
        if (img.previewDiv) {
            img.previewDiv.dataset.index = i;
        }
    });
    
    updateAdminImageNumbers();
    
    // Hide container if no images
    const previewContainer = document.getElementById('imagePreviewContainer');
    if (uploadedImageData.length === 0) {
        previewContainer.innerHTML = '';
    }
}

// Move an image in admin form
function moveAdminImage(index, direction) {
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
    const previewContainer = document.getElementById('imagePreviewContainer');
    const items = Array.from(previewContainer.children);
    if (items[index] && items[newIndex]) {
        if (direction > 0) {
            previewContainer.insertBefore(items[newIndex], items[index]);
        } else {
            previewContainer.insertBefore(items[index], items[newIndex].nextSibling);
        }
    }
    
    updateAdminImageNumbers();
}

// Update image number badges in admin form
function updateAdminImageNumbers() {
    uploadedImageData.forEach((img, i) => {
        const badge = img.previewDiv?.querySelector('.image-number-badge');
        if (badge) {
            badge.textContent = i + 1;
        }
    });
}

async function handleCreateAuction(event) {
    event.preventDefault();
    
    const errorElement = document.getElementById('createFormError');
    errorElement.textContent = '';
    
    // Use uploaded images or default placeholder
    const images = uploadedImageData.length > 0 
        ? uploadedImageData.map(img => img.base64)
        : ['https://via.placeholder.com/600x400?text=No+Image+Available'];
    
        const marketPriceInput = document.getElementById('createMarketPrice').value;
        const marketPrice = marketPriceInput ? parseFloat(marketPriceInput) : null;
        
        const realPriceInput = document.getElementById('createRealPrice').value;
        const realPrice = realPriceInput ? parseFloat(realPriceInput) : null;
        
        // Validate real price if provided
        if (realPrice !== null && realPrice !== undefined) {
            const startingBid = parseFloat(document.getElementById('createStartingBid').value);
            if (realPrice <= 0) {
                showToast('Real price must be greater than 0', 'error');
                return;
            }
            if (realPrice <= startingBid) {
                showToast('Real price must be higher than starting bid', 'error');
                return;
            }
        }
        
        const videoUrlInput = document.getElementById('createVideoUrl');
        const videoUrl = adminUploadedVideoUrl || (videoUrlInput ? videoUrlInput.value.trim() : '') || null;
        
        const auctionData = {
            item_name: document.getElementById('createItemName').value,
            description: document.getElementById('createDescription').value,
            category_id: parseInt(document.getElementById('createCategory').value),
            starting_bid: parseFloat(document.getElementById('createStartingBid').value),
            bid_increment: parseFloat(document.getElementById('createBidIncrement').value),
            market_price: marketPrice,
            real_price: realPrice,  // Buy It Now / Real Price
            end_time: new Date(document.getElementById('createEndTime').value).toISOString(),
            featured: document.getElementById('createFeatured').checked,
            images: images,  // Send base64 images or placeholder URL
            video_url: videoUrl,
            featured_image_url: adminUploadedFeaturedImageUrl || null
        };
    
    const submitBtn = event.target.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.textContent = 'Creating...';
    
    try {
        // Admin creates auctions on behalf of the system/admin user
        await AuctionAPI.create(auctionData);
        showToast('Auction created successfully', 'success');
        closeModal('createAuctionModal');
        uploadedImageData = []; // Clear uploaded images
        document.getElementById('imagePreviewContainer').innerHTML = '';
        adminUploadedVideoUrl = null; // Clear uploaded video
        adminUploadedVideoFile = null;
        adminUploadedFeaturedImageUrl = null; // Clear uploaded featured image
        adminUploadedFeaturedImageFile = null;
        await loadAuctions(currentPage);
    } catch (error) {
        if (window.utils) window.utils.debugError('Error creating auction:', error);
        errorElement.textContent = error.message || 'Failed to create auction';
        showToast(error.message || 'Failed to create auction', 'error');
    } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
        modal.style.display = 'none';
    }
}

window.onclick = function(event) {
    const modals = document.querySelectorAll('.admin-modal, .modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.classList.remove('active');
            modal.style.display = 'none';
        }
    });
};

