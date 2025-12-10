// Auctions page functionality
let currentPage = 1;
// Note: currentView is declared in app.js (global scope)
let filters = {
    search: '',
    category_id: '',
    sort_by: 'time_left',
    status: 'active',
    min_price: '',
    max_price: '',
};
let refreshInterval = null;
let searchDebounceTimer = null;
let isLoading = false;
let lastUpdateTime = null;

// Initialize on page load
document.addEventListener('DOMContentLoaded', async () => {
    console.log('Auctions page: DOMContentLoaded fired');
    
    // Parse URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    filters.search = urlParams.get('search') || '';
    filters.category_id = urlParams.get('category_id') || '';
    filters.sort_by = urlParams.get('sort_by') || 'time_left';
    filters.status = urlParams.get('status') || 'active';
    filters.min_price = urlParams.get('min_price') || '';
    filters.max_price = urlParams.get('max_price') || '';
    
    console.log('Auctions page: Filters initialized', filters);
    
    // Set filter values
    if (document.getElementById('searchFilter')) {
        document.getElementById('searchFilter').value = filters.search;
    }
    if (document.getElementById('categoryFilter')) {
        document.getElementById('categoryFilter').value = filters.category_id;
    }
    if (document.getElementById('sortFilter')) {
        document.getElementById('sortFilter').value = filters.sort_by;
    }
    if (document.getElementById('statusFilter')) {
        document.getElementById('statusFilter').value = filters.status;
    }
    if (document.getElementById('minPriceFilter')) {
        document.getElementById('minPriceFilter').value = filters.min_price;
    }
    if (document.getElementById('maxPriceFilter')) {
        document.getElementById('maxPriceFilter').value = filters.max_price;
    }
    
    // Set timeout to ensure loading indicator is hidden if something goes wrong
    const loadingTimeout = setTimeout(() => {
        const loadingIndicator = document.getElementById('loadingIndicator');
        const container = document.getElementById('auctionsContainer');
        if (loadingIndicator && loadingIndicator.style.display !== 'none') {
            console.warn('Loading timeout - forcing display');
            loadingIndicator.style.display = 'none';
            if (container) {
                container.style.display = 'block';
            }
        }
    }, 10000); // 10 second timeout
    
    try {
        console.log('Auctions page: Starting to load categories and auctions');
        await loadCategories();
        console.log('Auctions page: Categories loaded, now loading auctions');
        await loadAuctions();
        console.log('Auctions page: Auctions loaded successfully');
        clearTimeout(loadingTimeout);
	    } catch (error) {
	        clearTimeout(loadingTimeout);
	        console.error('Error during initialization:', error);
	        
	        // Show error to user
	        const loadingIndicator = document.getElementById('loadingIndicator');
	        const container = document.getElementById('auctionsContainer');
	        const errorMessage = document.getElementById('errorMessage');
	        
	        if (loadingIndicator) {
	            loadingIndicator.style.display = 'none';
	        }
	        
	        const rawMessage = (error && error.message) ? error.message : 'Failed to load auctions. Please refresh the page.';
	        const safeMessage = (typeof escapeHtml === 'function') ? escapeHtml(rawMessage) : rawMessage;
	        
	        if (errorMessage) {
	            errorMessage.textContent = rawMessage;
	            errorMessage.style.display = 'block';
	        }
	        
	        if (container) {
	            container.style.display = 'block';
	            container.innerHTML = `<div class="error-state">
	                <p>${safeMessage}</p>
	                <button class="btn btn-primary" onclick="location.reload()">Refresh Page</button>
	            </div>`;
	        }
	        
	        showToast(rawMessage, 'error');
	    }
    
    // Set up filter event listeners with debouncing
    setupEventListeners();
    
    // Start auto-refresh for active auctions
    if (filters.status === 'active') {
        startAutoRefresh();
    }
    
    // Update time left every second for active auctions
    startTimeLeftUpdates();
});

// Setup event listeners with debouncing
function setupEventListeners() {
    const searchFilter = document.getElementById('searchFilter');
    if (searchFilter) {
        // Debounced search
        searchFilter.addEventListener('input', (e) => {
            clearTimeout(searchDebounceTimer);
            searchDebounceTimer = setTimeout(() => {
                filters.search = e.target.value;
                applyFilters();
            }, 500); // 500ms debounce
        });
        
        searchFilter.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                clearTimeout(searchDebounceTimer);
                filters.search = e.target.value;
                applyFilters();
            }
        });
    }
    
    // Immediate filter changes
    const categoryFilter = document.getElementById('categoryFilter');
    if (categoryFilter) {
        categoryFilter.addEventListener('change', () => applyFilters());
    }
    
    const sortFilter = document.getElementById('sortFilter');
    if (sortFilter) {
        sortFilter.addEventListener('change', () => applyFilters());
    }
    
    const statusFilter = document.getElementById('statusFilter');
    if (statusFilter) {
        statusFilter.addEventListener('change', () => {
            filters.status = statusFilter.value;
            applyFilters();
            // Start/stop auto-refresh based on status
            if (filters.status === 'active') {
                startAutoRefresh();
            } else {
                stopAutoRefresh();
            }
        });
    }
    
    const minPriceFilter = document.getElementById('minPriceFilter');
    if (minPriceFilter) {
        minPriceFilter.addEventListener('change', () => applyFilters());
    }
    
    const maxPriceFilter = document.getElementById('maxPriceFilter');
    if (maxPriceFilter) {
        maxPriceFilter.addEventListener('change', () => applyFilters());
    }
}

// Load categories for filter dropdown
async function loadCategories() {
    try {
        const categories = await CategoryAPI.getAll();
        const select = document.getElementById('categoryFilter');
        if (select) {
            select.innerHTML = '<option value="">All Categories</option>' +
                categories.map(cat => {
                    const safeId = Number(cat.id) || 0;
                    const safeName = escapeHtml(cat.name || '');
                    return `<option value="${safeId}">${safeName}</option>`;
                }).join('');
        }
    } catch (error) {
        console.error('Error loading categories:', error);
    }
}

// Load auctions with enhanced error handling and loading states
async function loadAuctions(page = 1, showLoading = true) {
    if (isLoading) return; // Prevent concurrent loads
    
    currentPage = page;
    isLoading = true;
    
    const loadingIndicator = document.getElementById('loadingIndicator');
    const container = document.getElementById('auctionsContainer');
    const noResults = document.getElementById('noResults');
    const errorMessage = document.getElementById('errorMessage');
    
    if (showLoading && loadingIndicator) {
        loadingIndicator.style.display = 'block';
        loadingIndicator.innerHTML = '<div class="spinner"></div> Loading auctions...';
    }
    
    if (container) {
        if (showLoading) {
            container.innerHTML = ''; // Clear only on first load
            // Don't hide container completely, just make it empty
            // container.style.display = 'none'; // Removed - let it stay visible
        }
    }
    
    if (noResults) noResults.style.display = 'none';
    if (errorMessage) errorMessage.style.display = 'none';
    
    try {
        // Build params, filtering out empty values
        const params = {
            page: page,
            per_page: 12,
        };
        
        // Add filters only if they have values
        if (filters.search) params.search = filters.search;
        if (filters.category_id) params.category_id = filters.category_id;
        if (filters.sort_by) params.sort_by = filters.sort_by;
        if (filters.status) params.status = filters.status;
        if (filters.min_price) params.min_price = filters.min_price;
        if (filters.max_price) params.max_price = filters.max_price;
        
        const response = await AuctionAPI.getAll(params);
        
        // Debug logging - always log to help diagnose issues
        console.log('Auctions API Response:', response);
        
        // Debug logging
        if (window.DEBUG_MODE) {
            console.log('API Response:', response);
        }
        
        // Debug logging (can be removed in production)
        if (window.DEBUG_MODE) {
            console.log('Auctions loaded:', response);
            if (response && response.auctions && response.auctions.length > 0) {
                console.log('Sample auction video_url:', response.auctions[0]?.video_url);
                console.log('Video URL type:', typeof response.auctions[0]?.video_url);
                const auctionsWithVideo = response.auctions.filter(a => a.video_url && typeof a.video_url === 'string' && a.video_url.trim() !== '');
                console.log('Auctions with video:', auctionsWithVideo.length);
            }
        }
        
        lastUpdateTime = new Date();
        isLoading = false;
        
        // Hide loading indicator immediately
        if (loadingIndicator) {
            loadingIndicator.style.display = 'none';
            loadingIndicator.innerHTML = '';
        }
        
        // Check if response is valid
        if (!response) {
            console.error('No response from API');
            if (errorMessage) {
                errorMessage.textContent = 'No response from server. Please try again.';
                errorMessage.style.display = 'block';
            }
            if (container) {
                container.style.display = 'block';
                container.innerHTML = '<div class="error-state">No response from server. <button class="btn btn-primary" onclick="loadAuctions(1)">Retry</button></div>';
            }
            return;
        }
        
        // Validate response has auctions array
        if (!response.auctions) {
            console.error('Invalid response structure - missing auctions array:', response);
            if (errorMessage) {
                errorMessage.textContent = 'Invalid response from server. Please try again.';
                errorMessage.style.display = 'block';
            }
            if (container) {
                container.style.display = 'block';
                container.innerHTML = '<div class="error-state">Invalid response format. <button class="btn btn-primary" onclick="loadAuctions(1)">Retry</button></div>';
            }
            return;
        }
        
        if (response.auctions && response.auctions.length > 0) {
            if (container) {
                // Show container
                container.style.display = 'grid';
                container.style.opacity = '1';
                container.style.visibility = 'visible';

                const view = currentView || 'grid';

                if (view === 'grid') {
                    container.className = 'auctions-grid';
                    container.innerHTML = response.auctions.map(auction => createAuctionCard(auction)).join('');
                } else {
                    container.className = 'auctions-list';
                    container.innerHTML = response.auctions.map(auction => createAuctionListItem(auction)).join('');
                }
            }
            renderPagination(response);
            if (noResults) noResults.style.display = 'none';
            if (errorMessage) errorMessage.style.display = 'none';
            
            // Initialize previous auctions state for change detection
            if (!window.previousAuctionsState) {
                window.previousAuctionsState = {};
            }
            response.auctions.forEach(auction => {
                window.previousAuctionsState[auction.id] = {
                    status: auction.status,
                    current_bid: auction.current_bid,
                    bid_count: auction.bid_count
                };
            });
        } else {
            // No auctions found
            if (container) {
                container.innerHTML = '';
                container.style.display = 'block'; // Show container even when empty
            }
            if (noResults) noResults.style.display = 'block';
            if (errorMessage) errorMessage.style.display = 'none';
        }
    } catch (error) {
        isLoading = false;
        console.error('Error loading auctions:', error);
        console.error('Error details:', {
            message: error.message,
            stack: error.stack,
            response: error.response
        });
        
        // Hide loading indicator
        if (loadingIndicator) {
            loadingIndicator.style.display = 'none';
        }
        
        const errorMsg = error.message || 'Failed to load auctions. Please try again.';
        showToast(errorMsg, 'error');
        
        if (errorMessage) {
            errorMessage.textContent = errorMsg;
            errorMessage.style.display = 'block';
        }
        
        if (container) {
            container.style.display = 'block';
            container.innerHTML = '<div class="error-state">Failed to load auctions. <button class="btn btn-primary" onclick="loadAuctions(1)">Retry</button></div>';
        }
    } finally {
        // Ensure loading state is reset
        isLoading = false;
    }
}

// SVG Placeholder Data URI (always works, no external dependency)
const PLACEHOLDER_IMAGE = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZmY2NjAwIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIyNCIgZmlsbD0iI2ZmZmZmZiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPk5vIEltYWdlPC90ZXh0Pjwvc3ZnPg==';

// Get and normalize image URL
function getAuctionImageUrl(imageUrl) {
    // Check for null, undefined, or empty string
    if (!imageUrl || imageUrl === 'null' || imageUrl === 'undefined') {
        return PLACEHOLDER_IMAGE;
    }

    const urlString = String(imageUrl).trim();
    if (urlString === '' || urlString === 'null' || urlString === 'undefined') {
        return PLACEHOLDER_IMAGE;
    }

    // Data URIs - return as-is if valid
    if (urlString.startsWith('data:image/')) {
        return urlString;
    }

    // HTTP URLs - return as-is
    if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
        return urlString;
    }

    // Relative URLs - prepend base URL (use global API_BASE from api.js)
    const baseUrl = window.API_BASE || (window.location.hostname === 'localhost' ? 'http://localhost:5000' : window.location.origin);
    return baseUrl + (urlString.startsWith('/') ? urlString : '/' + urlString);
}

// Helper function to truncate text
function truncateText(text, maxLength) {
    if (!text) return '';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
}

// Create auction card for grid view with enhanced features
function createAuctionCard(auction) {
    const timeLeft = formatTimeLeft(auction.time_left);
    const statusClass = auction.status === 'active' ? 'active' : 'ended';
    const isEndingSoon = auction.time_left && auction.time_left < 3600; // Less than 1 hour
    const featuredBadge = auction.featured ? '<span class="featured-badge">⭐ Featured</span>' : '';
    const bidCountText = auction.bid_count === 0 ? 'No bids yet' : `${auction.bid_count} ${auction.bid_count === 1 ? 'bid' : 'bids'}`;
    
    // Escape HTML to prevent XSS
    const escapeHtml = (text) => {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    };
    
    // Get image URL
    const imageUrl = getAuctionImageUrl(auction.image_url);

    return `
        <div class="auction-card ${isEndingSoon ? 'ending-soon' : ''}"
             onclick="window.location.href='auction-detail.html?id=${auction.id}'"
             data-auction-id="${auction.id}"
             data-time-left="${auction.time_left || 0}">
            <div class="auction-image">
                <img src="${imageUrl}"
                     style="width: 100%; height: 200px; object-fit: cover; display: block;"
                     onerror="this.onerror=null; this.src='${PLACEHOLDER_IMAGE}';">
                <span class="status-badge ${statusClass}">${auction.status}</span>
                ${featuredBadge}
                ${isEndingSoon ? '<span class="ending-soon-badge">⏰ Ending Soon</span>' : ''}
                ${(auction.video_url && typeof auction.video_url === 'string' && auction.video_url.trim() !== '') ? '<button class="video-button" onclick="event.stopPropagation(); window.location.href=\'auction-detail.html?id=' + auction.id + '#video\'" title="Watch Video"><span class="video-icon">🎥</span> Video</button>' : ''}
            </div>
            <div class="auction-card-content">
                <h3>${escapeHtml(auction.item_name)}</h3>
                <p class="auction-description">${escapeHtml(truncateText(auction.description || '', 80))}</p>
                <div class="auction-stats">
                    <div class="stat">
                        <label>Current Bid</label>
                        <span class="price">$${auction.current_bid.toFixed(2)}</span>
                    </div>
                    <div class="stat">
                        <label>Time Left</label>
                        <span class="time-left" data-auction-id="${auction.id}">${timeLeft}</span>
                    </div>
                    <div class="stat">
                        <label>Bids</label>
                        <span>${bidCountText}</span>
                    </div>
                </div>
                ${auction.market_price || auction.real_price ? `
                <div class="auction-prices">
                    ${auction.market_price ? `<span class="market-price-tag">Market: <s>$${parseFloat(auction.market_price).toFixed(2)}</s></span>` : ''}
                    ${auction.real_price ? `<span class="real-price-tag">Buy Now: $${parseFloat(auction.real_price).toFixed(2)}</span>` : ''}
                </div>` : ''}
                <div class="auction-meta">
                    <small class="category-name">${escapeHtml(auction.category_name || 'Uncategorized')}</small>
                </div>
                <button class="btn btn-primary btn-block">View Auction</button>
            </div>
        </div>
    `;
}

// Create auction item for list view
function createAuctionListItem(auction) {
    const timeLeft = formatTimeLeft(auction.time_left);
    const statusClass = auction.status === 'active' ? 'active' : 'ended';
    
    // Escape HTML helper
    const escapeHtml = (text) => {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    };
    
    // Get image URL
    const imageUrl = getAuctionImageUrl(auction.image_url);

    return `
        <div class="auction-list-item" onclick="window.location.href='auction-detail.html?id=${auction.id}'">
            <div class="auction-list-image">
                <img src="${imageUrl}"
                     alt="${escapeHtml(auction.item_name || 'Auction item')}"
                     onerror="this.src='${PLACEHOLDER_IMAGE}'">
                ${(auction.video_url && typeof auction.video_url === 'string' && auction.video_url.trim() !== '') ? '<button class="video-button" onclick="event.stopPropagation(); window.location.href=\'auction-detail.html?id=' + auction.id + '#video\'" title="Watch Video"><span class="video-icon">🎥</span> Video</button>' : ''}
            </div>
            <div class="auction-list-content">
                <h3>${escapeHtml(auction.item_name || 'Auction')}</h3>
                <p class="auction-description">${escapeHtml(truncateText(auction.description || '', 120))}</p>
                <div class="auction-list-stats">
                    <div class="stat">
                        <label>Current Bid</label>
                        <span class="price">$${(auction.current_bid || 0).toFixed(2)}</span>
                    </div>
                    <div class="stat">
                        <label>Time Left</label>
                        <span class="time-left">${timeLeft}</span>
                    </div>
                    <div class="stat">
                        <label>Bids</label>
                        <span>${auction.bid_count || 0}</span>
                    </div>
                    <span class="status-badge ${statusClass}">${auction.status}</span>
                </div>
            </div>
            <div class="auction-list-action">
                <button class="btn btn-primary">View Auction</button>
            </div>
        </div>
    `;
}

// Render pagination
function renderPagination(response) {
    const pagination = document.getElementById('pagination');
    if (!pagination) return;
    
    if (response.pages <= 1) {
        pagination.innerHTML = '';
        return;
    }
    
    let html = '<div class="pagination-controls">';
    
    // Previous button
    if (currentPage > 1) {
        html += `<button class="btn btn-outline" onclick="loadAuctions(${currentPage - 1})">Previous</button>`;
    }
    
    // Page numbers
    for (let i = 1; i <= response.pages; i++) {
        if (i === currentPage) {
            html += `<button class="btn btn-primary">${i}</button>`;
        } else if (i === 1 || i === response.pages || (i >= currentPage - 2 && i <= currentPage + 2)) {
            html += `<button class="btn btn-outline" onclick="loadAuctions(${i})">${i}</button>`;
        } else if (i === currentPage - 3 || i === currentPage + 3) {
            html += `<span>...</span>`;
        }
    }
    
    // Next button
    if (currentPage < response.pages) {
        html += `<button class="btn btn-outline" onclick="loadAuctions(${currentPage + 1})">Next</button>`;
    }
    
    html += '</div>';
    pagination.innerHTML = html;
}

// Apply filters
function applyFilters() {
    const searchFilter = document.getElementById('searchFilter');
    const categoryFilter = document.getElementById('categoryFilter');
    const sortFilter = document.getElementById('sortFilter');
    const statusFilter = document.getElementById('statusFilter');
    const minPriceFilter = document.getElementById('minPriceFilter');
    const maxPriceFilter = document.getElementById('maxPriceFilter');
    
    if (searchFilter) filters.search = searchFilter.value.trim();
    if (categoryFilter) filters.category_id = categoryFilter.value;
    if (sortFilter) filters.sort_by = sortFilter.value;
    if (statusFilter) filters.status = statusFilter.value;
    if (minPriceFilter) filters.min_price = minPriceFilter.value.trim();
    if (maxPriceFilter) filters.max_price = maxPriceFilter.value.trim();
    
    // Validate price range
    if (filters.min_price && filters.max_price && parseFloat(filters.min_price) > parseFloat(filters.max_price)) {
        showToast('Minimum price cannot be greater than maximum price', 'error');
        return;
    }
    
    // Update URL without reload
    updateURL();
    
    loadAuctions(1);
}

// Reset filters
function resetFilters() {
    filters = {
        search: '',
        category_id: '',
        sort_by: 'time_left',
        status: 'active',
        min_price: '',
        max_price: '',
    };
    
    const searchFilter = document.getElementById('searchFilter');
    const categoryFilter = document.getElementById('categoryFilter');
    const sortFilter = document.getElementById('sortFilter');
    const statusFilter = document.getElementById('statusFilter');
    const minPriceFilter = document.getElementById('minPriceFilter');
    const maxPriceFilter = document.getElementById('maxPriceFilter');
    
    if (searchFilter) searchFilter.value = '';
    if (categoryFilter) categoryFilter.value = '';
    if (sortFilter) sortFilter.value = 'time_left';
    if (statusFilter) statusFilter.value = 'active';
    if (minPriceFilter) minPriceFilter.value = '';
    if (maxPriceFilter) maxPriceFilter.value = '';
    
    // Update URL
    updateURL();
    
    loadAuctions(1);
}

// Update URL parameters without page reload
function updateURL() {
    const params = new URLSearchParams();
    
    if (filters.search) params.set('search', filters.search);
    if (filters.category_id) params.set('category_id', filters.category_id);
    if (filters.sort_by && filters.sort_by !== 'time_left') params.set('sort_by', filters.sort_by);
    if (filters.status && filters.status !== 'active') params.set('status', filters.status);
    if (filters.min_price) params.set('min_price', filters.min_price);
    if (filters.max_price) params.set('max_price', filters.max_price);
    
    const newURL = params.toString() ? `auctions.html?${params.toString()}` : 'auctions.html';
    window.history.replaceState({}, '', newURL);
}

// Toggle view
function setView(view) {
    currentView = view;
    const gridBtn = document.getElementById('gridViewBtn');
    const listBtn = document.getElementById('listViewBtn');
    
    if (gridBtn && listBtn) {
        if (view === 'grid') {
            gridBtn.classList.add('active');
            listBtn.classList.remove('active');
        } else {
            listBtn.classList.add('active');
            gridBtn.classList.remove('active');
        }
    }
    
    loadAuctions(currentPage);
}

// Auto-refresh for active auctions
function startAutoRefresh() {
    if (refreshInterval) clearInterval(refreshInterval);
    
    // Initialize previous auctions state if not exists
    if (!window.previousAuctionsState) {
        window.previousAuctionsState = {};
    }
    
    // Optimized: Refresh every 30 seconds for active auctions (reduced frequency to save resources)
    // Only refresh if page is visible and user is actively viewing
    refreshInterval = setInterval(async () => {
        // Skip refresh if page is hidden (tab not active)
        if (document.hidden) return;
        
        if (filters.status === 'active' && !isLoading) {
            try {
                const params = {
                    page: currentPage,
                    per_page: 12,
                };
                
                if (filters.search) params.search = filters.search;
                if (filters.category_id) params.category_id = filters.category_id;
                if (filters.sort_by) params.sort_by = filters.sort_by;
                if (filters.status) params.status = filters.status;
                if (filters.min_price) params.min_price = filters.min_price;
                if (filters.max_price) params.max_price = filters.max_price;
                
                const response = await AuctionAPI.getAll(params);
                
                // Check for changes: ended auctions or price changes
                let needsRefresh = false;
                
                if (response.auctions && response.auctions.length > 0) {
                    response.auctions.forEach(auction => {
                        const prevAuction = window.previousAuctionsState[auction.id];
                        
                        // Check if auction just ended
                        if (prevAuction && prevAuction.status === 'active' && auction.status === 'ended') {
                            needsRefresh = true;
                        }
                        
                        // Check if price increased
                        if (prevAuction && prevAuction.current_bid !== auction.current_bid && auction.current_bid > prevAuction.current_bid) {
                            needsRefresh = true;
                        }
                        
                        // Store current state
                        window.previousAuctionsState[auction.id] = {
                            status: auction.status,
                            current_bid: auction.current_bid,
                            bid_count: auction.bid_count
                        };
                    });
                }
                
                // If any auction ended or price changed, refresh the page
                if (needsRefresh) {
                    window.location.reload();
                    return;
                }
                
                // Otherwise just update the display silently
                if (response.auctions && response.auctions.length > 0) {
                    const container = document.getElementById('auctionsContainer');
                    if (container) {
                        const view = currentView || 'grid';
                        if (view === 'grid') {
                            container.className = 'auctions-grid';
                            container.innerHTML = response.auctions.map(auction => createAuctionCard(auction)).join('');
                        } else {
                            container.className = 'auctions-list';
                            container.innerHTML = response.auctions.map(auction => createAuctionListItem(auction)).join('');
                        }
                    }
                }
            } catch (error) {
                console.error('Error checking for updates:', error);
            }
        }
    }, 30000); // Optimized: Check every 30 seconds (reduced from 5s to save resources)
}

function stopAutoRefresh() {
    if (refreshInterval) {
        clearInterval(refreshInterval);
        refreshInterval = null;
    }
}

// Update time left for all visible auction cards
function startTimeLeftUpdates() {
    setInterval(() => {
        if (filters.status === 'active') {
            updateTimeLeftForAll();
        }
    }, 1000); // Update every second
}

function updateTimeLeftForAll() {
    const timeLeftElements = document.querySelectorAll('.time-left[data-auction-id]');
    timeLeftElements.forEach(element => {
        const auctionId = element.getAttribute('data-auction-id');
        const card = document.querySelector(`[data-auction-id="${auctionId}"]`);
        if (!card) return;
        
        const timeLeftAttr = card.getAttribute('data-time-left');
        if (!timeLeftAttr) return;
        
        let timeLeft = parseInt(timeLeftAttr);
        if (isNaN(timeLeft) || timeLeft <= 0) {
            element.textContent = 'Ended';
            return;
        }
        
        // Decrement time left
        timeLeft--;
        card.setAttribute('data-time-left', timeLeft);
        
        // Update display
        element.textContent = formatTimeLeft(timeLeft);
        
        // Update ending soon badge
        if (timeLeft < 3600 && !card.querySelector('.ending-soon-badge')) {
            const imageDiv = card.querySelector('.auction-image');
            if (imageDiv) {
                const badge = document.createElement('span');
                badge.className = 'ending-soon-badge';
                badge.textContent = '⏰ Ending Soon';
                imageDiv.appendChild(badge);
                card.classList.add('ending-soon');
            }
        }
    });
}

// Format time left with better formatting
function formatTimeLeft(seconds) {
    if (!seconds || seconds <= 0) return 'Ended';
    
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);
    
    if (days > 0) {
        return `${days}d ${hours}h`;
    } else if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else if (minutes > 0) {
        return `${minutes}m ${secs}s`;
    } else {
        return `${secs}s`;
    }
}

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
    stopAutoRefresh();
    if (searchDebounceTimer) clearTimeout(searchDebounceTimer);
});

