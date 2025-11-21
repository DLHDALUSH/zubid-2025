// My Bids page functionality
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
            showToast('Please login to view your bids', 'error');
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
        if (loadingIndicator) loadingIndicator.style.display = 'block';
        if (container) container.style.display = 'none';
        if (noBids) noBids.style.display = 'none';
        if (errorMessage) errorMessage.style.display = 'none';
        
        if (!currentUser) {
            throw new Error('Please login to view your bids');
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
                    // Check if user won (for ended auctions) or is winning (for active auctions)
                    let statusBadge = '';
                    let bidClass = 'losing-bid';
                    
                    if (bid.auction_status === 'ended') {
                        // For ended auctions, check if user won
                        if (bid.is_winner || (bid.winner_id && bid.amount === bid.current_bid)) {
                            statusBadge = '<span class="winner-badge">🏆 WON</span>';
                            bidClass = 'winner-bid';
                        } else {
                            statusBadge = '<span class="losing-badge">❌ OUTBID</span>';
                            bidClass = 'losing-bid';
                        }
                    } else if (bid.auction_status === 'active') {
                        // For active auctions, check if user is currently winning
                        const isWinning = bid.is_winning || (Math.abs(bid.amount - bid.current_bid) <= 0.01);
                        if (isWinning) {
                            statusBadge = '<span class="winner-badge">🏆 WINNING</span>';
                            bidClass = 'winner-bid';
                        } else {
                            statusBadge = '<span class="losing-badge">❌ OUTBID</span>';
                            bidClass = 'losing-bid';
                        }
                    } else {
                        // For cancelled or other statuses
                        statusBadge = '<span class="losing-badge">❌ OUTBID</span>';
                        bidClass = 'losing-bid';
                    }
                    
                    return `
                        <div class="bid-history-item ${bidClass}" onclick="window.location.href='auction-detail.html?id=${bid.auction_id}'">
                            <div class="bid-info">
                                <div>
                                    <div class="bid-header">
                                        <strong>${bid.auction_name || 'Unknown Auction'}</strong>
                                        ${statusBadge}
                                    </div>
                                    <div class="bid-details">
                                        <span class="bid-amount">$${(bid.amount || 0).toFixed(2)}</span>
                                        ${bid.auction_status === 'active' ? `<span class="current-bid-info">Current: $${(bid.current_bid || 0).toFixed(2)}</span>` : ''}
                                        ${bid.auction_status === 'ended' ? `<span class="auction-status-badge">Auction Ended</span>` : ''}
                                        ${bid.is_auto_bid ? '<span class="auto-bid-badge">Auto-Bid</span>' : ''}
                                    </div>
                                </div>
                            </div>
                            <div class="bid-time">${bid.timestamp ? new Date(bid.timestamp).toLocaleString() : 'Unknown time'}</div>
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
                        <p style="color: var(--text-secondary); margin-bottom: 1rem; font-size: 1.125rem;">You don't have any winning bids yet.</p>
                        <p style="color: var(--text-light); margin-bottom: 1.5rem;">Keep bidding to win amazing auctions!</p>
                        <a href="auctions.html" class="btn btn-primary">Browse Auctions</a>
                    `;
                    noBids.style.display = 'block';
                }
            }
        } else {
            if (container) container.style.display = 'none';
            if (noBids) {
                noBids.innerHTML = `
                    <p style="color: var(--text-secondary); margin-bottom: 1rem; font-size: 1.125rem;">You haven't placed any bids yet.</p>
                    <a href="auctions.html" class="btn btn-primary">Browse Auctions</a>
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
            errorMessage.textContent = error.message || 'Failed to load your bids. Please try again.';
            errorMessage.style.display = 'block';
        }
        
        showToast(error.message || 'Failed to load your bids', 'error');
        
        // Redirect to login if not authenticated
        if (error.message.includes('login') || error.message.includes('Authentication')) {
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
        }
    }
}

