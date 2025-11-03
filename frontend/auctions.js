// Auctions page functionality
let currentPage = 1;
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
    // Parse URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    filters.search = urlParams.get('search') || '';
    filters.category_id = urlParams.get('category_id') || '';
    filters.sort_by = urlParams.get('sort_by') || 'time_left';
    filters.status = urlParams.get('status') || 'active';
    filters.min_price = urlParams.get('min_price') || '';
    filters.max_price = urlParams.get('max_price') || '';
    
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
    
    await loadCategories();
    await loadAuctions();
    
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
                categories.map(cat => `<option value="${cat.id}">${cat.name}</option>`).join('');
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
        
        lastUpdateTime = new Date();
        isLoading = false;
        
        if (showLoading && loadingIndicator) loadingIndicator.style.display = 'none';
        
        if (response.auctions && response.auctions.length > 0) {
            if (container) {
                const view = currentView || 'grid';
                if (view === 'grid') {
                    container.className = 'auctions-grid';
                    container.innerHTML = response.auctions.map(auction => createAuctionCard(auction)).join('');
                } else {
                    container.className = 'auctions-list';
                    container.innerHTML = response.auctions.map(auction => createAuctionListItem(auction)).join('');
                }
                
                // Add fade-in animation
                container.style.opacity = '0';
                setTimeout(() => {
                    container.style.transition = 'opacity 0.3s';
                    container.style.opacity = '1';
                }, 10);
            }
            renderPagination(response);
            if (noResults) noResults.style.display = 'none';
            if (errorMessage) errorMessage.style.display = 'none';
        } else {
            if (container) container.innerHTML = '';
            if (noResults) noResults.style.display = 'block';
            if (errorMessage) errorMessage.style.display = 'none';
        }
    } catch (error) {
        isLoading = false;
        console.error('Error loading auctions:', error);
        
        if (showLoading && loadingIndicator) loadingIndicator.style.display = 'none';
        
        const errorMsg = error.message || 'Failed to load auctions. Please try again.';
        showToast(errorMsg, 'error');
        
        if (errorMessage) {
            errorMessage.textContent = errorMsg;
            errorMessage.style.display = 'block';
        }
        
        if (container) {
            container.innerHTML = '<div class="error-state">Failed to load auctions. <button class="btn btn-primary" onclick="loadAuctions(1)">Retry</button></div>';
        }
    }
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
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    };
    
    return `
        <div class="auction-card ${isEndingSoon ? 'ending-soon' : ''}" 
             onclick="window.location.href='auction-detail.html?id=${auction.id}'"
             data-auction-id="${auction.id}"
             data-time-left="${auction.time_left || 0}">
            <div class="auction-image">
                <img src="${auction.image_url || 'https://via.placeholder.com/300x200?text=No+Image'}" 
                     alt="${escapeHtml(auction.item_name)}"
                     loading="lazy"
                     onerror="this.src='https://via.placeholder.com/300x200?text=No+Image'">
                <span class="status-badge ${statusClass}">${auction.status}</span>
                ${featuredBadge}
                ${isEndingSoon ? '<span class="ending-soon-badge">⏰ Ending Soon</span>' : ''}
            </div>
            <div class="auction-card-content">
                <h3>${escapeHtml(auction.item_name)}</h3>
                <p class="auction-description">${escapeHtml(auction.description || '').substring(0, 100)}${auction.description && auction.description.length > 100 ? '...' : ''}</p>
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
    
    return `
        <div class="auction-list-item" onclick="window.location.href='auction-detail.html?id=${auction.id}'">
            <div class="auction-list-image">
                <img src="${auction.image_url || 'https://via.placeholder.com/200x150?text=No+Image'}" alt="${auction.item_name}">
            </div>
            <div class="auction-list-content">
                <h3>${auction.item_name}</h3>
                <p class="auction-description">${auction.description}</p>
                <div class="auction-list-stats">
                    <div class="stat">
                        <label>Current Bid</label>
                        <span class="price">$${auction.current_bid.toFixed(2)}</span>
                    </div>
                    <div class="stat">
                        <label>Time Left</label>
                        <span class="time-left">${timeLeft}</span>
                    </div>
                    <div class="stat">
                        <label>Bids</label>
                        <span>${auction.bid_count}</span>
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
    
    // Refresh every 30 seconds for active auctions
    refreshInterval = setInterval(() => {
        if (filters.status === 'active' && !isLoading) {
            loadAuctions(currentPage, false); // Don't show loading indicator on refresh
        }
    }, 30000); // 30 seconds
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

