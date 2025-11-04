// Auction detail page functionality
let auctionId = null;
let auctionData = null;
let bidInterval = null;
let countdownInterval = null;

// Initialize on page load
document.addEventListener('DOMContentLoaded', async () => {
    const urlParams = new URLSearchParams(window.location.search);
    auctionId = urlParams.get('id');
    
    if (auctionId) {
        await loadAuctionDetail();
        await loadBidHistory();
        startRealTimeUpdates();
        startCountdown();
    } else {
        document.getElementById('loadingIndicator').innerHTML = 'Invalid auction ID';
    }
});

// Load auction details
async function loadAuctionDetail() {
    try {
        auctionData = await AuctionAPI.getById(auctionId);
        displayAuctionDetail(auctionData);
    } catch (error) {
        console.error('Error loading auction:', error);
        document.getElementById('loadingIndicator').innerHTML = 'Error loading auction details';
        showToast('Error loading auction', 'error');
    }
}

// Display auction details
function displayAuctionDetail(auction) {
    auctionData = auction;
    
    document.getElementById('loadingIndicator').style.display = 'none';
    document.getElementById('auctionDetail').style.display = 'block';
    
    // Set basic info
    document.getElementById('auctionItemName').textContent = auction.item_name;
    document.getElementById('auctionDescription').textContent = auction.description;
    document.getElementById('currentBid').textContent = `$${auction.current_bid.toFixed(2)}`;
    document.getElementById('startingBid').textContent = `$${auction.starting_bid.toFixed(2)}`;
    document.getElementById('bidIncrement').textContent = `$${auction.bid_increment.toFixed(2)}`;
    document.getElementById('bidCount').textContent = auction.bid_count;
    
    // Set category and status
    const categoryEl = document.getElementById('auctionCategory');
    if (categoryEl) {
        categoryEl.textContent = auction.category_name || 'Uncategorized';
    }
    
    const statusEl = document.getElementById('auctionStatus');
    if (statusEl) {
        statusEl.textContent = auction.status;
        statusEl.className = `status-badge ${auction.status}`;
    }
    
    
    // Set images
    if (auction.images && auction.images.length > 0) {
        const mainImage = document.getElementById('mainAuctionImage');
        mainImage.src = auction.images[0].url;
        mainImage.onerror = function() {
            this.src = 'https://via.placeholder.com/600x400?text=No+Image';
        };
        
        const thumbnails = document.getElementById('imageThumbnails');
        thumbnails.innerHTML = auction.images.map((img, index) => `
            <img src="${img.url}" alt="Thumbnail ${index + 1}" 
                 onclick="changeMainImage('${img.url}')" 
                 class="thumbnail ${index === 0 ? 'active' : ''}"
                 onerror="this.src='https://via.placeholder.com/100x100?text=No+Image'">
        `).join('');
    } else {
        document.getElementById('mainAuctionImage').src = 'https://via.placeholder.com/600x400?text=No+Image';
    }
    
    // Update bid form
    updateBidForm();
    
    // Update bidding section based on status
    if (auction.status === 'ended') {
        document.getElementById('biddingForm').style.display = 'none';
        document.getElementById('biddingClosed').style.display = 'block';
        const winnerInfo = document.getElementById('winnerInfo');
        if (auction.winner_id) {
            winnerInfo.textContent = 'Winner has been determined.';
        } else {
            winnerInfo.textContent = 'No bids were placed on this auction.';
        }
    } else {
        document.getElementById('biddingForm').style.display = 'block';
        document.getElementById('biddingClosed').style.display = 'none';
    }
    
    // Restart countdown with updated auction data
    startCountdown();
}

// Change main image
function changeMainImage(imageUrl) {
    document.getElementById('mainAuctionImage').src = imageUrl;
    document.querySelectorAll('.thumbnail').forEach(thumb => {
        thumb.classList.remove('active');
        if (thumb.src === imageUrl) {
            thumb.classList.add('active');
        }
    });
}

// Update bid form
function updateBidForm() {
    if (!auctionData || auctionData.status !== 'active') return;
    
    const minBid = auctionData.current_bid + auctionData.bid_increment;
    const bidAmountInput = document.getElementById('bidAmount');
    const minBidInfo = document.getElementById('minBidInfo');
    
    if (bidAmountInput) {
        bidAmountInput.min = minBid;
        bidAmountInput.placeholder = `Minimum: $${minBid.toFixed(2)}`;
    }
    
    if (minBidInfo) {
        minBidInfo.textContent = `Minimum bid: $${minBid.toFixed(2)}`;
    }
}

// Toggle auto-bid
function toggleAutoBid() {
    const enableAutoBid = document.getElementById('enableAutoBid');
    const autoBidAmount = document.getElementById('autoBidAmount');
    const autoBidInfo = document.getElementById('autoBidInfo');
    
    if (enableAutoBid.checked) {
        autoBidAmount.style.display = 'block';
        autoBidInfo.style.display = 'block';
    } else {
        autoBidAmount.style.display = 'none';
        autoBidInfo.style.display = 'none';
    }
}

// Place bid with enhanced validation and feedback
async function placeBid() {
    if (!currentUser) {
        showToast('Please login to place a bid', 'error');
        showLogin();
        return;
    }
    
    if (!auctionData || auctionData.status !== 'active') {
        showToast('This auction is no longer active', 'error');
        return;
    }
    
    const bidAmountInput = document.getElementById('bidAmount');
    const enableAutoBid = document.getElementById('enableAutoBid');
    const autoBidAmountInput = document.getElementById('autoBidAmount');
    const bidError = document.getElementById('bidError');
    const placeBidBtn = document.querySelector('button[onclick="placeBid()"]');
    
    if (!bidAmountInput || !bidError) return;
    
    const bidAmount = parseFloat(bidAmountInput.value);
    const minBid = (auctionData.current_bid || auctionData.starting_bid) + auctionData.bid_increment;
    
    // Enhanced validation
    if (isNaN(bidAmount) || bidAmount <= 0) {
        bidError.textContent = 'Please enter a valid bid amount';
        bidAmountInput.focus();
        return;
    }
    
    if (bidAmount < minBid) {
        bidError.textContent = `Bid must be at least $${minBid.toFixed(2)} (current: $${(auctionData.current_bid || auctionData.starting_bid).toFixed(2)} + increment: $${auctionData.bid_increment.toFixed(2)})`;
        bidAmountInput.focus();
        return;
    }
    
    if (enableAutoBid && enableAutoBid.checked) {
        const autoBidAmount = parseFloat(autoBidAmountInput.value);
        if (isNaN(autoBidAmount) || autoBidAmount <= 0) {
            bidError.textContent = 'Please enter a valid auto-bid limit';
            autoBidAmountInput.focus();
            return;
        }
        if (autoBidAmount < bidAmount) {
            bidError.textContent = 'Auto-bid limit must be higher than or equal to bid amount';
            autoBidAmountInput.focus();
            return;
        }
    }
    
    // Disable button and show loading state
    if (placeBidBtn) {
        placeBidBtn.disabled = true;
        placeBidBtn.textContent = 'Placing Bid...';
    }
    bidError.textContent = '';
    
    try {
        const bidData = {
            amount: bidAmount,
        };
        
        if (enableAutoBid && enableAutoBid.checked) {
            bidData.auto_bid_amount = parseFloat(autoBidAmountInput.value);
        }
        
        const response = await BidAPI.place(auctionId, bidData);
        
        // Show immediate success
        showToast('Bid placed successfully!', 'success');
        
        // Check if time was extended
        if (response.time_extended && response.new_end_time) {
            // Update auctionData with new end_time
            auctionData.end_time = response.new_end_time;
            auctionData.time_left = response.time_left;
            
            // Show time extension notification
            showToast('⏰ Auction time extended by 2 minutes!', 'info');
            
            // Visual feedback for time extension
            const timer = document.getElementById('countdownTimer');
            if (timer) {
                timer.style.transition = 'all 0.5s';
                timer.style.transform = 'scale(1.2)';
                timer.style.color = '#4CAF50';
                setTimeout(() => {
                    timer.style.transform = 'scale(1)';
                    updateCountdown(); // Update countdown immediately
                }, 500);
            }
        }
        
        // Reset form
        bidAmountInput.value = '';
        if (autoBidAmountInput) autoBidAmountInput.value = '';
        if (enableAutoBid) {
            enableAutoBid.checked = false;
            toggleAutoBid();
        }
        
        // Reload auction and bid history with animation
        await Promise.all([
            loadAuctionDetail(),
            loadBidHistory()
        ]);
        
        // Update bid form
        updateBidForm();
        
        // Show success message based on whether user is now winning
        setTimeout(async () => {
            try {
                const updatedBids = await BidAPI.getByAuctionId(auctionId);
                if (updatedBids && updatedBids.length > 0) {
                    const sortedBids = [...updatedBids].sort((a, b) => b.amount - a.amount);
                    const highestBid = sortedBids[0];
                    if (highestBid && currentUser && highestBid.user_id === currentUser.id && highestBid.is_winning) {
                        showToast('🎉 You are now the highest bidder!', 'success');
                        // Add visual feedback
                        const bidHistory = document.getElementById('bidHistory');
                        if (bidHistory) {
                            const userBids = bidHistory.querySelectorAll('.current-user-bid');
                            userBids.forEach(bid => {
                                bid.classList.add('winning-pulse');
                                setTimeout(() => bid.classList.remove('winning-pulse'), 2000);
                            });
                        }
                    }
                }
            } catch (error) {
                console.error('Error checking winning status:', error);
            }
        }, 500);
    } catch (error) {
        console.error('Error placing bid:', error);
        const errorMsg = error.message || 'Failed to place bid. Please try again.';
        bidError.textContent = errorMsg;
        showToast(errorMsg, 'error');
        
        // Re-enable button
        if (placeBidBtn) {
            placeBidBtn.disabled = false;
            placeBidBtn.textContent = 'Place Bid';
        }
    }
}

// Load bid history
async function loadBidHistory() {
    try {
        const bids = await BidAPI.getByAuctionId(auctionId);
        const container = document.getElementById('bidHistory');
        
        if (!container) return;
        
        if (bids && bids.length > 0) {
            // Group bids by user_id and keep only the highest bid per user
            const bidsByUser = {};
            bids.forEach(bid => {
                const userId = bid.user_id;
                if (!bidsByUser[userId] || bid.amount > bidsByUser[userId].amount) {
                    bidsByUser[userId] = bid;
                } else if (bid.amount === bidsByUser[userId].amount) {
                    // If same amount, keep the most recent one
                    const existingDate = new Date(bidsByUser[userId].timestamp);
                    const newDate = new Date(bid.timestamp);
                    if (newDate > existingDate) {
                        bidsByUser[userId] = bid;
                    }
                }
            });
            
            // Convert back to array and sort by amount (highest first) for display
            const sortedBids = Object.values(bidsByUser).sort((a, b) => b.amount - a.amount);
            
            container.innerHTML = `
                <div class="bid-history-list">
                    ${sortedBids.map((bid, index) => {
                        const isWinner = bid.is_winning || (index === 0 && auctionData.status === 'active');
                        const isCurrentUser = currentUser && bid.user_id === currentUser.id;
                        
                        return `
                        <div class="bid-history-item ${isWinner ? 'winner-bid' : 'losing-bid'} ${isCurrentUser ? 'current-user-bid' : ''}">
                            <div class="bid-info">
                                <div class="bid-header">
                                    <strong>${bid.username}</strong>
                                    ${isWinner ? '<span class="winner-badge">🏆 WINNER</span>' : '<span class="losing-badge">❌ LOSING</span>'}
                                </div>
                                <div class="bid-details">
                                    <span class="bid-amount">$${bid.amount.toFixed(2)}</span>
                                    ${bid.is_auto_bid ? '<span class="auto-bid-badge">Auto-Bid</span>' : ''}
                                    ${isCurrentUser ? '<span class="your-bid-badge">Your Bid</span>' : ''}
                                </div>
                            </div>
                            <div class="bid-time">${new Date(bid.timestamp).toLocaleString()}</div>
                        </div>
                    `;
                    }).join('')}
                </div>
            `;
            
            // Show current winner prominently if auction is active
            if (auctionData.status === 'active' && sortedBids.length > 0) {
                const winner = sortedBids[0];
                updateCurrentWinner(winner);
            }
        } else {
            container.innerHTML = '<p>No bids yet. Be the first to bid!</p>';
        }
    } catch (error) {
        console.error('Error loading bid history:', error);
    }
}

// Update current winner display
function updateCurrentWinner(winnerBid) {
    // Check if there's a winner display element, if not create it
    let winnerDisplay = document.getElementById('currentWinnerDisplay');
    if (!winnerDisplay && auctionData.status === 'active') {
        const biddingSection = document.querySelector('.bidding-section');
        if (biddingSection) {
            winnerDisplay = document.createElement('div');
            winnerDisplay.id = 'currentWinnerDisplay';
            winnerDisplay.className = 'current-winner-display';
            biddingSection.insertBefore(winnerDisplay, biddingSection.firstChild);
        }
    }
    
    if (winnerDisplay) {
        const isCurrentUser = currentUser && winnerBid.user_id === currentUser.id;
        winnerDisplay.innerHTML = `
            <div class="winner-announcement ${isCurrentUser ? 'your-winner' : ''}">
                <h3>🏆 Current Highest Bid</h3>
                <p><strong>${winnerBid.username}</strong> is currently winning with <strong>$${winnerBid.amount.toFixed(2)}</strong></p>
                ${isCurrentUser ? '<p class="congratulations">Congratulations! You are currently the highest bidder!</p>' : 
                  '<p class="outbid-notice">Place a higher bid to become the winner!</p>'}
            </div>
        `;
    }
}

// Real-time updates with enhanced notifications
function startRealTimeUpdates() {
    if (bidInterval) clearInterval(bidInterval);
    
    let lastBidCount = auctionData ? auctionData.bid_count : 0;
    let lastCurrentBid = auctionData ? auctionData.current_bid : 0;
    
    bidInterval = setInterval(async () => {
        try {
            if (!auctionId || auctionData?.status === 'ended') {
                clearInterval(bidInterval);
                return;
            }
            
            const updatedAuction = await AuctionAPI.getById(auctionId);
            const oldCurrentBid = auctionData ? auctionData.current_bid : 0;
            const oldBidCount = auctionData ? auctionData.bid_count : 0;
            
            // Check if end_time changed (bid extension)
            const oldEndTime = new Date(auctionData.end_time).getTime();
            const newEndTime = new Date(updatedAuction.end_time).getTime();
            const timeExtended = newEndTime > oldEndTime;
            
            // Update auctionData with latest end_time for countdown
            if (updatedAuction.end_time) {
                auctionData.end_time = updatedAuction.end_time;
            }
            
            // Update current bid if changed
            if (updatedAuction.current_bid !== oldCurrentBid || updatedAuction.bid_count !== oldBidCount || timeExtended) {
                // Get previous bids to check if user was winning
                let wasWinning = false;
                if (currentUser && oldCurrentBid > 0) {
                    try {
                        const previousBids = await BidAPI.getByAuctionId(auctionId);
                        wasWinning = previousBids.some(b => 
                            b.user_id === currentUser.id && 
                            b.amount === oldCurrentBid && 
                            b.is_winning
                        );
                    } catch (error) {
                        console.error('Error checking previous bids:', error);
                    }
                }
                
                // Update auction data
                auctionData = updatedAuction;
                
                // Animate bid change
                const currentBidEl = document.getElementById('currentBid');
                if (currentBidEl) {
                    currentBidEl.style.transition = 'all 0.3s';
                    currentBidEl.style.transform = 'scale(1.1)';
                    currentBidEl.textContent = `$${updatedAuction.current_bid.toFixed(2)}`;
                    setTimeout(() => {
                        currentBidEl.style.transform = 'scale(1)';
                    }, 300);
                }
                
                const bidCountEl = document.getElementById('bidCount');
                if (bidCountEl) {
                    bidCountEl.textContent = updatedAuction.bid_count;
                    if (updatedAuction.bid_count > oldBidCount) {
                        bidCountEl.style.transition = 'all 0.3s';
                        bidCountEl.style.color = '#4CAF50';
                        setTimeout(() => {
                            bidCountEl.style.color = '';
                        }, 1000);
                    }
                }
                
                // Reload bid history to update winner/losing status
                await loadBidHistory();
                updateBidForm();
                
                // Update countdown if time was extended
                if (timeExtended) {
                    updateCountdown();
                    showToast('⏰ Auction time extended by 2 minutes!', 'info');
                }
                
                // Show notification about bid change
                if (oldCurrentBid > 0 && currentUser && updatedAuction.current_bid !== oldCurrentBid) {
                    try {
                        const newBids = await BidAPI.getByAuctionId(auctionId);
                        const nowWinning = newBids.find(b => 
                            b.user_id === currentUser.id && 
                            b.is_winning
                        );
                        
                        if (wasWinning && !nowWinning) {
                            // User was winning but got outbid
                            showToast('⚠️ You have been outbid! Someone placed a higher bid.', 'error');
                            // Add visual feedback
                            const bidForm = document.getElementById('biddingForm');
                            if (bidForm) {
                                bidForm.style.animation = 'shake 0.5s';
                                setTimeout(() => {
                                    bidForm.style.animation = '';
                                }, 500);
                            }
                        } else if (!wasWinning && nowWinning) {
                            // User is now winning
                            showToast('🎉 You are now the highest bidder!', 'success');
                        } else if (!wasWinning && !nowWinning && updatedAuction.bid_count > oldBidCount) {
                            // New bid placed by someone else
                            showToast('💰 New bid placed!', 'info');
                        }
                    } catch (error) {
                        console.error('Error checking winning status:', error);
                    }
                }
            }
            
            // Check if auction ended
            if (updatedAuction.status === 'ended' && auctionData.status === 'active') {
                auctionData = updatedAuction;
                displayAuctionDetail(updatedAuction);
                
                // Show winner information when auction ends
                if (updatedAuction.winner_id) {
                    try {
                        const bids = await BidAPI.getByAuctionId(auctionId);
                        const winner = bids.find(b => b.user_id === updatedAuction.winner_id);
                        if (winner) {
                            const winnerInfo = document.getElementById('winnerInfo');
                            if (winnerInfo) {
                                const isCurrentUser = currentUser && winner.user_id === currentUser.id;
                                winnerInfo.innerHTML = `
                                    <div class="winner-announcement-final ${isCurrentUser ? 'your-winner' : ''}">
                                        <h3>🎉 Auction Winner</h3>
                                        <p><strong>${winner.username}</strong> won with a bid of <strong>$${winner.amount.toFixed(2)}</strong></p>
                                        ${isCurrentUser ? '<p class="congratulations">Congratulations! You won this auction!</p>' : ''}
                                    </div>
                                `;
                                
                                if (isCurrentUser) {
                                    showToast('🎉 Congratulations! You won this auction!', 'success');
                                }
                            }
                        }
                    } catch (error) {
                        console.error('Error loading winner info:', error);
                    }
                } else {
                    const winnerInfo = document.getElementById('winnerInfo');
                    if (winnerInfo) {
                        winnerInfo.innerHTML = '<p>No bids were placed on this auction.</p>';
                    }
                }
                
                clearInterval(bidInterval);
                clearInterval(countdownInterval);
            }
        } catch (error) {
            console.error('Error updating auction:', error);
            // Don't show toast for every error to avoid spam
        }
    }, 3000); // Update every 3 seconds
}

// Countdown timer with live updates and color changes
function startCountdown() {
    if (countdownInterval) clearInterval(countdownInterval);
    
    // Update immediately
    updateCountdown();
    
    // Then update every second for live countdown
    countdownInterval = setInterval(() => {
        updateCountdown();
    }, 1000);
}

function updateCountdown() {
    if (!auctionData) return;
    
    const timer = document.getElementById('countdownTimer');
    if (!timer) return;
    
    // Calculate time left from end_time in real-time (live countdown)
    const now = new Date().getTime();
    const endTime = new Date(auctionData.end_time).getTime();
    let timeLeftSeconds = Math.max(0, Math.floor((endTime - now) / 1000));
    
    if (timeLeftSeconds <= 0) {
        timer.textContent = 'Auction Ended';
        timer.className = 'timer ended';
        if (auctionData.status !== 'ended') {
            loadAuctionDetail();
        }
        return;
    }
    
    // Calculate time components
    const days = Math.floor(timeLeftSeconds / (60 * 60 * 24));
    const hours = Math.floor((timeLeftSeconds % (60 * 60 * 24)) / (60 * 60));
    const minutes = Math.floor((timeLeftSeconds % (60 * 60)) / 60);
    const seconds = timeLeftSeconds % 60;
    
    // Format time string
    let timeString = '';
    if (days > 0) timeString += `${days}d `;
    if (hours > 0 || days > 0) timeString += `${String(hours).padStart(2, '0')}:`;
    timeString += `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    
    timer.textContent = timeString;
    
    // Color changes based on time remaining
    const minutesLeft = Math.floor(timeLeftSeconds / 60);
    timer.classList.remove('timer-normal', 'timer-warning', 'timer-critical', 'ended');
    
    if (minutesLeft <= 5) {
        // Red when 5 minutes or less remain
        timer.classList.add('timer-critical');
        timer.style.color = '#ff4444';
        timer.style.fontWeight = 'bold';
        timer.style.animation = 'pulse 1s infinite';
    } else if (minutesLeft <= 15) {
        // Orange/Yellow when 15 minutes or less remain
        timer.classList.add('timer-warning');
        timer.style.color = '#ff9800';
        timer.style.fontWeight = '600';
        timer.style.animation = '';
    } else {
        // Normal color when more than 15 minutes remain
        timer.classList.add('timer-normal');
        timer.style.color = '#4CAF50';
        timer.style.fontWeight = 'normal';
        timer.style.animation = '';
    }
}

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
    if (bidInterval) clearInterval(bidInterval);
    if (countdownInterval) clearInterval(countdownInterval);
});

