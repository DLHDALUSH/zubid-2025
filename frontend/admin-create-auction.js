// Admin Create Auction Page
let uploadedImages = [];

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
});

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
    const category = document.getElementById('category').value;
    const startingBid = parseFloat(document.getElementById('startingBid').value);
    const bidIncrement = parseFloat(document.getElementById('bidIncrement').value);
    const endTime = document.getElementById('endTime').value;
    const featured = document.getElementById('featured').checked;
    const imageUrlsText = document.getElementById('imageUrls').value;
    
    // Validate
    if (!itemName || !description || !category || !startingBid || !endTime) {
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
            category_id: parseInt(category),
            starting_bid: startingBid,
            bid_increment: bidIncrement,
            end_time: endTimeISO,
            featured: featured,
            images: images
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

