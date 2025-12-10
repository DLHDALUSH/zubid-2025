// My Bids page functionality

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
	            const t = (window.i18n && window.i18n.t)
	                ? window.i18n.t
	                : (key, def) => def || key;
	            showToast(t('myBidsPage.loginRequired', 'Please login to view your bids'), 'error');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
            return;
        }
    }
    
    // Load user bids
    await loadMyBids();
});

// Load user's bids
async function loadMyBids() {
    const loadingIndicator = document.getElementById('loadingIndicator');
    const container = document.getElementById('myBidsContainer');
    const noBids = document.getElementById('noBids');
    const errorMessage = document.getElementById('errorMessage');
    
    try {
	        const t = (window.i18n && window.i18n.t)
	            ? window.i18n.t
	            : (key, def) => def || key;
        if (loadingIndicator) loadingIndicator.style.display = 'block';
        if (container) container.style.display = 'none';
        if (noBids) noBids.style.display = 'none';
        if (errorMessage) errorMessage.style.display = 'none';
	        
	        if (!currentUser) {
	            const loginMsg = t('myBidsPage.loginRequired', 'Please login to view your bids');
	            throw new Error(loginMsg);
	        }
        
        const bids = await BidAPI.getUserBids();
        
        if (loadingIndicator) loadingIndicator.style.display = 'none';
        
        if (bids && bids.length > 0) {
            // Filter to show only winning bids (won or currently winning)
            const winningBids = bids.filter(bid => {
                // For ended auctions: show if user won
                if (bid.auction_status === 'ended') {
                    return bid.is_winner === true;
                }
                // For active auctions: show if user is currently winning
                else if (bid.auction_status === 'active') {
                    return bid.is_winning === true;
                }
                // For other statuses, don't show
                return false;
            });
            
            if (winningBids.length > 0) {
                if (container) {
                    container.style.display = 'block';
                    
                    // Group bids by auction_id and keep only the highest bid per auction
                    const bidsByAuction = {};
                    winningBids.forEach(bid => {
                        const auctionId = bid.auction_id;
                        if (!bidsByAuction[auctionId] || bid.amount > bidsByAuction[auctionId].amount) {
                            bidsByAuction[auctionId] = bid;
                        } else if (bid.amount === bidsByAuction[auctionId].amount) {
                            // If same amount, keep the most recent one
                            const existingDate = new Date(bidsByAuction[auctionId].timestamp);
                            const newDate = new Date(bid.timestamp);
                            if (newDate > existingDate) {
                                bidsByAuction[auctionId] = bid;
                            }
                        }
                    });
                    
                    // Convert back to array and sort by timestamp (newest first)
                    const uniqueBids = Object.values(bidsByAuction).sort((a, b) => {
                        return new Date(b.timestamp) - new Date(a.timestamp);
                    });
                
	                container.innerHTML = uniqueBids.map(bid => {
	                    // Localized status texts
	                    const wonText = t('myBidsPage.statusWon', 'WON');
	                    const winningText = t('myBidsPage.statusWinning', 'WINNING');
	                    const outbidText = t('myBidsPage.statusOutbid', 'OUTBID');
	                    const unknownAuction = t('myBidsPage.unknownAuction', 'Unknown Auction');
	                    const currentLabel = t('myBidsPage.currentLabel', 'Current:');
	                    const auctionEndedBadge = t('myBidsPage.auctionEndedBadge', 'Auction Ended');
	                    const autoBidBadge = t('myBidsPage.autoBidBadge', 'Auto-Bid');
	                    const unknownTime = t('myBidsPage.unknownTime', 'Unknown time');
	
	                    // Check if user won (for ended auctions) or is winning (for active auctions)
	                    let statusBadge = '';
	                    let bidClass = 'losing-bid';
	                    
	                    if (bid.auction_status === 'ended') {
	                        // For ended auctions, check if user won
	                        if (bid.is_winner || (bid.winner_id && bid.amount === bid.current_bid)) {
	                            statusBadge = `<span class="winner-badge">🏆 ${wonText}</span>`;
	                            bidClass = 'winner-bid';
	                        } else {
	                            statusBadge = `<span class="losing-badge">❌ ${outbidText}</span>`;
	                            bidClass = 'losing-bid';
	                        }
	                    } else if (bid.auction_status === 'active') {
	                        // For active auctions, check if user is currently winning
	                        const isWinning = bid.is_winning || (Math.abs(bid.amount - bid.current_bid) <= 0.01);
	                        if (isWinning) {
	                            statusBadge = `<span class="winner-badge">🏆 ${winningText}</span>`;
	                            bidClass = 'winner-bid';
	                        } else {
	                            statusBadge = `<span class="losing-badge">❌ ${outbidText}</span>`;
	                            bidClass = 'losing-bid';
	                        }
	                    } else {
	                        // For cancelled or other statuses
	                        statusBadge = `<span class="losing-badge">❌ ${outbidText}</span>`;
	                        bidClass = 'losing-bid';
	                    }
	                    
	                    const safeAuctionName = escapeHtml(bid.auction_name || unknownAuction);
	                    const safeAuctionId = Number(bid.auction_id) || 0;
	                    
	                    return `
	                        <div class="bid-history-item ${bidClass}" onclick="window.location.href='auction-detail.html?id=${safeAuctionId}'">
	                            <div class="bid-info">
	                                <div>
	                                    <div class="bid-header">
	                                        <strong>${safeAuctionName}</strong>
	                                        ${statusBadge}
	                                    </div>
	                                    <div class="bid-details">
	                                        <span class="bid-amount">$${(bid.amount || 0).toFixed(2)}</span>
	                                        ${bid.auction_status === 'active' ? `<span class="current-bid-info">${currentLabel} $${(bid.current_bid || 0).toFixed(2)}</span>` : ''}
	                                        ${bid.auction_status === 'ended' ? `<span class="auction-status-badge">${auctionEndedBadge}</span>` : ''}
	                                        ${bid.is_auto_bid ? `<span class="auto-bid-badge">${autoBidBadge}</span>` : ''}
	                                    </div>
	                                </div>
	                            </div>
	                            <div class="bid-time">${bid.timestamp ? new Date(bid.timestamp).toLocaleString() : unknownTime}</div>
	                        </div>
	                    `;
	                }).join('');
                }
                if (noBids) noBids.style.display = 'none';
            } else {
                // No winning bids
                if (container) container.style.display = 'none';
                if (noBids) {
                    noBids.innerHTML = `
                        <p style="color: var(--text-secondary); margin-bottom: 1rem; font-size: 1.125rem;">${t('myBidsPage.noWinningTitle', "You don't have any winning bids yet.")}</p>
                        <p style="color: var(--text-light); margin-bottom: 1.5rem;">${t('myBidsPage.noWinningSubtitle', 'Keep bidding to win amazing auctions!')}</p>
                        <a href="auctions.html" class="btn btn-primary">${t('myBidsPage.browseAuctions', 'Browse Auctions')}</a>
                    `;
                    noBids.style.display = 'block';
                }
            }
        } else {
            if (container) container.style.display = 'none';
            if (noBids) {
                noBids.innerHTML = `
                    <p style="color: var(--text-secondary); margin-bottom: 1rem; font-size: 1.125rem;">${t('myBidsPage.noBidsTitle', "You haven't placed any bids yet.")}</p>
                    <a href="auctions.html" class="btn btn-primary">${t('myBidsPage.browseAuctions', 'Browse Auctions')}</a>
                `;
                noBids.style.display = 'block';
            }
        }
    } catch (error) {
        console.error('Error loading my bids:', error);
        if (loadingIndicator) loadingIndicator.style.display = 'none';
        if (container) container.style.display = 'none';
        if (noBids) noBids.style.display = 'none';
        
        if (errorMessage) {
            const defaultMsg = 'Failed to load your bids. Please try again.';
            errorMessage.textContent = error.message || t('myBidsPage.loadError', defaultMsg);
            errorMessage.style.display = 'block';
        }
        
        showToast(error.message || t('myBidsPage.loadErrorShort', 'Failed to load your bids'), 'error');
        
        // Redirect to login if not authenticated
        if (error.message.includes('login') || error.message.includes('Authentication')) {
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
        }
    }
}

