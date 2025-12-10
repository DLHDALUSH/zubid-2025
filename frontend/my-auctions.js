// My Auctions page functionality

// Basic HTML escaping helper for safely displaying auction titles, etc.
function escapeHtml(text) {
	if (text === null || text === undefined) return '';
	const div = document.createElement('div');
	div.textContent = String(text);
	return div.innerHTML;
}

document.addEventListener('DOMContentLoaded', async () => {
    // Wait for app.js to load and check authentication
    // Check if checkAuth exists, if not wait a bit
    let retries = 0;
    while (typeof checkAuth === 'undefined' && retries < 10) {
        await new Promise(resolve => setTimeout(resolve, 100));
        retries++;
    }
    
    if (typeof checkAuth !== 'undefined') {
        await checkAuth();
    } else {
        // Fallback: try to get profile directly
        try {
            const response = await UserAPI.getProfile();
            currentUser = response;
            updateNavAuth(true);
        } catch (error) {
            updateNavAuth(false);
            showToast('Please login to view your auctions', 'error');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
            return;
        }
    }
    
    // Load user auctions
    await loadMyAuctions();
});

// Load user's auctions
async function loadMyAuctions() {
    const loadingIndicator = document.getElementById('loadingIndicator');
    const container = document.getElementById('myAuctionsContainer');
    const noAuctions = document.getElementById('noAuctions');
    const errorMessage = document.getElementById('errorMessage');
    
    try {
        if (loadingIndicator) loadingIndicator.style.display = 'block';
        if (container) container.style.display = 'none';
        if (noAuctions) noAuctions.style.display = 'none';
        if (errorMessage) errorMessage.style.display = 'none';
        
        if (!currentUser) {
            throw new Error('Please login to view your auctions');
        }
        
	        const auctions = await AuctionAPI.getUserAuctions();
        
        if (loadingIndicator) loadingIndicator.style.display = 'none';
        
	        if (auctions && auctions.length > 0) {
            if (container) {
                container.style.display = 'grid';
	                container.innerHTML = auctions.map(auction => {
	                    const safeTitle = escapeHtml(auction.item_name || '');
	                    const rawStatus = auction.status || 'active';
	                    const allowedStatuses = ['active', 'ended', 'cancelled', 'pending'];
	                    const safeStatusClass = allowedStatuses.includes(rawStatus) ? rawStatus : 'other';
	                    const safeStatusLabel = escapeHtml(rawStatus);
	                    const safeAuctionId = Number(auction.id) || 0;
	                    return `
	                    <div class="auction-card" onclick="window.location.href='auction-detail.html?id=${safeAuctionId}'">
	                        <div class="auction-card-content">
	                            <h3>${safeTitle}</h3>
                            <div class="auction-stats">
                                <div class="stat">
                                    <label>Current Bid</label>
                                    <span class="price">$${(auction.current_bid || 0).toFixed(2)}</span>
                                </div>
                                <div class="stat">
                                    <label>Status</label>
	                                    <span class="status-badge ${safeStatusClass}">${safeStatusLabel}</span>
                                </div>
                                <div class="stat">
                                    <label>Bids</label>
                                    <span>${auction.bid_count || 0}</span>
                                </div>
                            </div>
                            <div class="auction-meta">
                                <small>Ends: ${new Date(auction.end_time).toLocaleString()}</small>
                            </div>
                            <button class="btn btn-primary btn-block">View Auction</button>
                        </div>
                    </div>
	                `; }).join('');
            }
            if (noAuctions) noAuctions.style.display = 'none';
        } else {
            if (container) container.style.display = 'none';
            if (noAuctions) noAuctions.style.display = 'block';
        }
    } catch (error) {
        console.error('Error loading my auctions:', error);
        if (loadingIndicator) loadingIndicator.style.display = 'none';
        if (container) container.style.display = 'none';
        if (noAuctions) noAuctions.style.display = 'none';
        
        if (errorMessage) {
            errorMessage.textContent = error.message || 'Failed to load your auctions. Please try again.';
            errorMessage.style.display = 'block';
        }
        
        showToast(error.message || 'Failed to load your auctions', 'error');
        
        // Redirect to login if not authenticated
        if (error.message.includes('login') || error.message.includes('Authentication')) {
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
        }
    }
}

