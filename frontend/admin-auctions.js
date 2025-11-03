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
    tbody.innerHTML = '<tr><td colspan="9" class="loading">Loading auctions...</td></tr>';
    
    try {
        const data = await AdminAPI.getAuctions(page, currentStatus);
        
        if (data.auctions && data.auctions.length > 0) {
            tbody.innerHTML = data.auctions.map(auction => `
                <tr>
                    <td>${auction.id}</td>
                    <td>${auction.item_name}</td>
                    <td>${auction.seller}</td>
                    <td>$${(auction.current_bid || 0).toFixed(2)}</td>
                    <td>${auction.bid_count}</td>
                    <td><span class="status-badge ${auction.status}">${auction.status}</span></td>
                    <td>${auction.featured ? '✓' : ''}</td>
                    <td>${new Date(auction.end_time).toLocaleString()}</td>
                    <td class="actions">
                        <button class="btn btn-small btn-primary" onclick="editAuction(${auction.id}, '${auction.status}', ${auction.featured})">Edit</button>
                        <button class="btn btn-small btn-danger" onclick="deleteAuction(${auction.id})">Delete</button>
                    </td>
                </tr>
            `).join('');
            
            renderPagination(data, 'auctionPagination');
        } else {
            tbody.innerHTML = '<tr><td colspan="9">No auctions found</td></tr>';
        }
    } catch (error) {
        console.error('Error loading auctions:', error);
        tbody.innerHTML = `<tr><td colspan="9">Error: ${error.message}</td></tr>`;
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
    document.getElementById('editAuctionModal').style.display = 'block';
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
        console.error('Error loading categories:', error);
    }
}

function openCreateAuctionModal() {
    document.getElementById('createAuctionModal').style.display = 'block';
    loadCategoriesForCreate();
    // Reset form
    document.getElementById('createAuctionForm').reset();
    document.getElementById('createFormError').textContent = '';
    document.getElementById('imagePreviewContainer').innerHTML = '';
    uploadedImages = []; // Clear uploaded images array
}

// Store uploaded images as base64
let uploadedImages = [];

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
                    document.getElementById('createImages').value = '';
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

async function handleCreateAuction(event) {
    event.preventDefault();
    
    const errorElement = document.getElementById('createFormError');
    errorElement.textContent = '';
    
    // Use uploaded images or default placeholder
    const images = uploadedImages.length > 0 
        ? uploadedImages 
        : ['https://via.placeholder.com/600x400?text=No+Image+Available'];
    
    const auctionData = {
        item_name: document.getElementById('createItemName').value,
        description: document.getElementById('createDescription').value,
        category_id: parseInt(document.getElementById('createCategory').value),
        starting_bid: parseFloat(document.getElementById('createStartingBid').value),
        bid_increment: parseFloat(document.getElementById('createBidIncrement').value),
        end_time: new Date(document.getElementById('createEndTime').value).toISOString(),
        featured: document.getElementById('createFeatured').checked,
        images: images  // Send base64 images or placeholder URL
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
        uploadedImages = []; // Clear uploaded images
        await loadAuctions(currentPage);
    } catch (error) {
        console.error('Error creating auction:', error);
        errorElement.textContent = error.message || 'Failed to create auction';
        showToast(error.message || 'Failed to create auction', 'error');
    } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
    }
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });
};

