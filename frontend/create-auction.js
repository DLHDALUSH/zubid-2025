// Create auction page functionality
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
    }
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
    
    // Parse image URLs
    const imageUrls = imageUrlsText
        .split('\n')
        .map(url => url.trim())
        .filter(url => url.length > 0);
    
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
            category_id: parseInt(category),
            starting_bid: startingBid,
            bid_increment: bidIncrement,
            end_time: endTimeISO,
            featured: featured,
            images: imageUrls
        };
        
        const response = await AuctionAPI.create(auctionData);
        
        showToast('Auction created successfully!', 'success');
        
        // Redirect to auction detail page
        setTimeout(() => {
            window.location.href = `auction-detail.html?id=${response.id}`;
        }, 1500);
    } catch (error) {
        formError.textContent = error.message || 'Failed to create auction';
        showToast(error.message || 'Failed to create auction', 'error');
    }
}

