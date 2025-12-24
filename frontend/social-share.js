// Social Sharing and Cashback functionality

// Show cashback offer modal when user wins an auction
function showCashbackOfferModal(auctionId, auctionName) {
    // Check if modal already exists
    let modal = document.getElementById('cashbackOfferModal');
    if (!modal) {
        // Create modal
        modal = document.createElement('div');
        modal.id = 'cashbackOfferModal';
        modal.className = 'modal cashback-modal';
        modal.style.cssText = 'display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.8);backdrop-filter:blur(8px);z-index:10000;justify-content:center;align-items:center;padding:1rem;';
        modal.innerHTML = `
            <div class="cashback-modal-content">
                <!-- Close Button -->
                <button onclick="closeCashbackModal()" class="cashback-close-btn">&times;</button>

                <!-- Confetti Animation Container -->
                <div class="cashback-confetti" id="cashbackConfetti"></div>

                <!-- Header with Glow Effect -->
                <div class="cashback-header">
                    <div class="cashback-trophy">🏆</div>
                    <h2 class="cashback-title">Congratulations!</h2>
                    <p class="cashback-subtitle">You won the auction!</p>
                    <div class="cashback-auction-name">${auctionName}</div>
                </div>

                <!-- Premium Cashback Offer Card -->
                <div class="cashback-offer-card">
                    <div class="cashback-offer-badge">LIMITED OFFER</div>
                    <div class="cashback-amount-container">
                        <span class="cashback-currency">$</span>
                        <span class="cashback-amount">5</span>
                        <span class="cashback-label">CASHBACK</span>
                    </div>
                    <p class="cashback-description">
                        Share your win on <strong>3 social platforms</strong> and get <strong>$5 off</strong> your invoice!
                    </p>

                    <!-- Progress Section -->
                    <div class="cashback-progress-section">
                        <div class="cashback-progress-header">
                            <span class="cashback-progress-label">Your Progress</span>
                            <span class="cashback-progress-count" id="shareCount">0 / 3</span>
                        </div>
                        <div class="cashback-progress-bar">
                            <div class="cashback-progress-fill" id="shareProgressBar"></div>
                            <div class="cashback-progress-glow"></div>
                        </div>
                    </div>
                </div>

                <!-- Social Share Buttons - Premium Design -->
                <div class="cashback-share-section">
                    <h3 class="cashback-share-title">Share on Social Media</h3>
                    <div class="cashback-share-grid" id="socialShareButtons">
                        <!-- Social share buttons will be inserted here -->
                    </div>
                </div>

                <!-- Success Status -->
                <div class="cashback-success" id="cashbackStatus">
                    <div class="cashback-success-icon">✓</div>
                    <div class="cashback-success-content">
                        <h4>Cashback Earned!</h4>
                        <p>$5 will be applied to your invoice</p>
                    </div>
                </div>

                <!-- Footer Actions -->
                <div class="cashback-footer">
                    <button onclick="closeCashbackModal()" class="cashback-btn-secondary">Maybe Later</button>
                    <button onclick="goToPayments()" class="cashback-btn-primary">View Invoice</button>
                </div>
            </div>
        `;
        document.body.appendChild(modal);

        // Add confetti animation
        createConfetti();
    }

    // Store auction ID for later use
    modal.dataset.auctionId = auctionId;

    // Load current share status
    loadShareStatus(auctionId);

    // Setup social share buttons
    setupSocialShareButtons(auctionId, auctionName);

    // Show modal with animation
    modal.style.display = 'flex';
    setTimeout(() => modal.classList.add('active'), 10);
}

// Create confetti animation
function createConfetti() {
    const container = document.getElementById('cashbackConfetti');
    if (!container) return;

    const colors = ['#ff6600', '#fbbf24', '#10b981', '#6366f1', '#ec4899'];
    for (let i = 0; i < 50; i++) {
        const confetti = document.createElement('div');
        confetti.className = 'confetti-piece';
        confetti.style.cssText = `
            left: ${Math.random() * 100}%;
            background: ${colors[Math.floor(Math.random() * colors.length)]};
            animation-delay: ${Math.random() * 3}s;
            animation-duration: ${3 + Math.random() * 2}s;
        `;
        container.appendChild(confetti);
    }
}

// Go to payments page
function goToPayments() {
    closeCashbackModal();
    window.location.href = 'payments.html';
}

// Close cashback modal
function closeCashbackModal() {
    const modal = document.getElementById('cashbackOfferModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Setup social share buttons - Premium design with TikTok, Instagram, Snapchat, Facebook
function setupSocialShareButtons(auctionId, auctionName) {
    const container = document.getElementById('socialShareButtons');
    if (!container) return;

    const shareUrl = window.location.origin + '/auction-detail.html?id=' + auctionId;
    const shareText = `🎉 I just won this amazing item on ZUBID! Check it out: ${auctionName}`;

    // Primary platforms: TikTok, Instagram, Snapchat, Facebook
    const platforms = [
        {
            name: 'TikTok',
            icon: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19.59 6.69a4.83 4.83 0 0 1-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 0 1-5.2 1.74 2.89 2.89 0 0 1 2.31-4.64 2.93 2.93 0 0 1 .88.13V9.4a6.84 6.84 0 0 0-1-.05A6.33 6.33 0 0 0 5 20.1a6.34 6.34 0 0 0 10.86-4.43v-7a8.16 8.16 0 0 0 4.77 1.52v-3.4a4.85 4.85 0 0 1-1-.1z"/></svg>`,
            color: '#000000',
            gradient: 'linear-gradient(135deg, #00f2ea, #ff0050)',
            textColor: '#fff'
        },
        {
            name: 'Instagram',
            icon: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg>`,
            color: '#E4405F',
            gradient: 'linear-gradient(135deg, #f09433, #e6683c, #dc2743, #cc2366, #bc1888)',
            textColor: '#fff'
        },
        {
            name: 'Snapchat',
            icon: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12.206.793c.99 0 4.347.276 5.93 3.821.529 1.193.403 3.219.299 4.847l-.003.06c-.012.18-.022.345-.03.51.075.045.203.09.401.09.3-.016.659-.12 1.033-.301.165-.088.344-.104.464-.104.182 0 .359.029.509.09.45.149.734.479.734.838.015.449-.39.839-1.213 1.168-.089.029-.209.075-.344.119-.45.135-1.139.36-1.333.81-.09.224-.061.524.12.868l.015.015c.06.136 1.526 3.475 4.791 4.014.255.044.435.27.42.509 0 .075-.015.149-.045.225-.24.569-1.273.988-3.146 1.271-.059.091-.12.375-.164.57-.029.179-.074.36-.134.553-.076.271-.27.405-.555.405h-.03c-.135 0-.313-.031-.538-.074-.36-.075-.765-.135-1.273-.135-.3 0-.599.015-.913.074-.6.104-1.123.464-1.723.884-.853.599-1.826 1.288-3.294 1.288-.06 0-.119-.015-.18-.015h-.149c-1.468 0-2.427-.675-3.279-1.288-.599-.42-1.107-.779-1.707-.884-.314-.045-.629-.074-.928-.074-.54 0-.958.089-1.272.149-.211.043-.391.074-.54.074-.374 0-.523-.224-.583-.42-.061-.192-.09-.389-.135-.567-.046-.181-.105-.494-.166-.57-1.918-.222-2.95-.642-3.189-1.226-.031-.063-.052-.15-.055-.225-.015-.243.165-.465.42-.509 3.264-.54 4.73-3.879 4.791-4.02l.016-.029c.18-.345.224-.645.119-.869-.195-.434-.884-.658-1.332-.809-.121-.029-.24-.074-.346-.119-1.107-.435-1.257-.93-1.197-1.273.09-.479.674-.793 1.168-.793.146 0 .27.029.383.074.42.194.789.3 1.104.3.234 0 .384-.06.465-.105l-.046-.569c-.098-1.626-.225-3.651.307-4.837C7.392 1.077 10.739.807 11.727.807l.419-.015h.06z"/></svg>`,
            color: '#FFFC00',
            gradient: 'linear-gradient(135deg, #FFFC00, #fff200)',
            textColor: '#000'
        },
        {
            name: 'Facebook',
            icon: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>`,
            color: '#1877F2',
            gradient: 'linear-gradient(135deg, #1877F2, #3b5998)',
            textColor: '#fff'
        }
    ];

    container.innerHTML = platforms.map(platform => {
        const platformLower = platform.name.toLowerCase();
        return `
            <button onclick="shareOnPlatform('${platformLower}', ${auctionId})"
                    class="cashback-share-btn"
                    id="shareBtn_${platformLower}"
                    data-platform="${platformLower}">
                <div class="share-btn-bg" style="background: ${platform.gradient};"></div>
                <div class="share-btn-content">
                    <div class="share-btn-icon" style="color: ${platform.textColor};">${platform.icon}</div>
                    <span class="share-btn-name">${platform.name}</span>
                </div>
                <div class="share-btn-check">✓</div>
            </button>
        `;
    }).join('');
}

// Share on social media platform
async function shareOnPlatform(platform, auctionId) {
    const shareUrl = window.location.origin + '/auction-detail.html?id=' + auctionId;
    const shareText = `Check out this amazing auction on ZUBID!`;
    
    let shareLink = '';
    
    switch(platform) {
        case 'facebook':
            shareLink = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`;
            break;
        case 'twitter':
            shareLink = `https://twitter.com/intent/tweet?url=${encodeURIComponent(shareUrl)}&text=${encodeURIComponent(shareText)}`;
            break;
        case 'linkedin':
            shareLink = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(shareUrl)}`;
            break;
        case 'whatsapp':
            shareLink = `https://wa.me/?text=${encodeURIComponent(shareText + ' ' + shareUrl)}`;
            break;
        case 'telegram':
            shareLink = `https://t.me/share/url?url=${encodeURIComponent(shareUrl)}&text=${encodeURIComponent(shareText)}`;
            break;
        case 'reddit':
            shareLink = `https://reddit.com/submit?url=${encodeURIComponent(shareUrl)}&title=${encodeURIComponent(shareText)}`;
            break;
        case 'tiktok':
            // TikTok doesn't have a web share URL, so we'll copy to clipboard
            await copyToClipboard(shareUrl, shareText);
            await recordShareAfterDelay(platform, auctionId, shareUrl);
            return;
        case 'instagram':
            // Instagram doesn't have a web share URL, so we'll copy to clipboard
            // Users can paste it in Instagram app
            await copyToClipboard(shareUrl, shareText);
            await recordShareAfterDelay(platform, auctionId, shareUrl);
            return;
        case 'snapchat':
            // Snapchat share - use Web Share API if available, otherwise copy to clipboard
            if (navigator.share) {
                try {
                    await navigator.share({
                        title: shareText,
                        text: shareText,
                        url: shareUrl
                    });
                    await recordShareAfterDelay(platform, auctionId, shareUrl);
                    return;
                } catch (err) {
                    // User cancelled or error, fall through to clipboard
                    console.log('Web Share cancelled or failed:', err);
                }
            }
            // Fallback: copy to clipboard
            await copyToClipboard(shareUrl, shareText);
            await recordShareAfterDelay(platform, auctionId, shareUrl);
            return;
        default:
            return;
    }
    
    // Open share window
    const shareWindow = window.open(shareLink, '_blank', 'width=600,height=400');
    
    // Record share after a delay (to allow user to complete share)
    setTimeout(async () => {
        try {
            const response = await fetch(`${window.API_BASE_URL || 'http://localhost:5000/api'}/user/social-share`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                credentials: 'include',
                body: JSON.stringify({
                    platform: platform,
                    auction_id: auctionId
                })
            });
            
            const data = await response.json();
            
            if (response.ok) {
                // Update UI
                const btn = document.getElementById(`shareBtn_${platform}`);
                if (btn) {
                    btn.style.background = 'rgba(0, 200, 83, 0.1)';
                    btn.style.borderColor = '#00c853';
                    btn.disabled = true;
                    btn.innerHTML = '<span style="font-size: 1.5rem;">✅</span><span style="font-size: 0.8rem;">Shared!</span>';
                }
                
                // Reload share status
                await loadShareStatus(auctionId);
                
                // Show success message
                if (typeof showToast === 'function') {
                    const shareMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.shareSuccess', 'Shared successfully!') : `Shared on ${platform.charAt(0).toUpperCase() + platform.slice(1)}!`;
                    showToast(shareMsg, 'success');
                }
                
                // Check if cashback earned
                if (data.cashback_created) {
                    showCashbackEarned();
                }
            } else {
                if (typeof showToast === 'function') {
                    showToast(data.error || 'Failed to record share', 'error');
                }
            }
        } catch (error) {
            console.error('Error recording share:', error);
            if (typeof showToast === 'function') {
                const errorMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.errorRecordingShare', 'Error recording share. Please try again.') : 'Error recording share. Please try again.';
                showToast(errorMsg, 'error');
            }
        }
    }, 2000);
}

// Copy to clipboard helper function
async function copyToClipboard(url, text) {
    const fullText = `${text} ${url}`;
    try {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            await navigator.clipboard.writeText(fullText);
            if (typeof showToast === 'function') {
                const successMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.linkCopied', 'Link copied to clipboard! Paste it in the app.') : 'Link copied to clipboard! Paste it in the app.';
                showToast(successMsg, 'success');
            }
        } else {
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = fullText;
            textArea.style.position = 'fixed';
            textArea.style.opacity = '0';
            document.body.appendChild(textArea);
            textArea.select();
            try {
                document.execCommand('copy');
                if (typeof showToast === 'function') {
                    const successMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.linkCopied', 'Link copied to clipboard! Paste it in the app.') : 'Link copied to clipboard! Paste it in the app.';
                showToast(successMsg, 'success');
                }
            } catch (err) {
                console.error('Failed to copy:', err);
                if (typeof showToast === 'function') {
                    const errorMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.copyLinkManually', 'Please copy the link manually') + ': ' + url : 'Please copy the link manually: ' + url;
                    showToast(errorMsg, 'info');
                }
            }
            document.body.removeChild(textArea);
        }
    } catch (error) {
        console.error('Error copying to clipboard:', error);
        if (typeof showToast === 'function') {
            showToast('Please copy the link manually: ' + url, 'info');
        }
    }
}

// Record share after delay (for clipboard-based sharing)
async function recordShareAfterDelay(platform, auctionId, shareUrl) {
    // Record share after a delay
    setTimeout(async () => {
        try {
            const response = await fetch(`${window.API_BASE_URL || 'http://localhost:5000/api'}/user/social-share`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                credentials: 'include',
                body: JSON.stringify({
                    platform: platform,
                    auction_id: auctionId
                })
            });
            
            const data = await response.json();
            
            if (response.ok) {
                // Update UI
                const btn = document.getElementById(`shareBtn_${platform}`);
                if (btn) {
                    btn.style.background = 'rgba(0, 200, 83, 0.1)';
                    btn.style.borderColor = '#00c853';
                    btn.disabled = true;
                    btn.innerHTML = '<span style="font-size: 1.5rem;">✅</span><span style="font-size: 0.8rem;">Shared!</span>';
                }
                
                // Reload share status
                await loadShareStatus(auctionId);
                
                // Check if cashback earned
                if (data.cashback_created) {
                    showCashbackEarned();
                }
            } else {
                if (typeof showToast === 'function') {
                    showToast(data.error || 'Failed to record share', 'error');
                }
            }
        } catch (error) {
            console.error('Error recording share:', error);
            if (typeof showToast === 'function') {
                const errorMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.errorRecordingShare', 'Error recording share. Please try again.') : 'Error recording share. Please try again.';
                showToast(errorMsg, 'error');
            }
        }
    }, 1000);
}

// Load share status
async function loadShareStatus(auctionId) {
    try {
        const response = await fetch(`${window.API_BASE_URL || 'http://localhost:5000/api'}/user/social-shares?auction_id=${auctionId}`, {
            credentials: 'include'
        });

        if (response.ok) {
            const data = await response.json();
            const shares = data.shares[auctionId] || [];
            const shareCount = shares.length;

            // Update progress
            updateShareProgress(shareCount);

            // Mark shared platforms with new premium style
            shares.forEach(share => {
                markButtonAsShared(share.platform);
            });

            // Check for cashback
            if (shareCount >= 3) {
                const cashbackResponse = await fetch(`${window.API_BASE_URL || 'http://localhost:5000/api'}/user/cashback?auction_id=${auctionId}`, {
                    credentials: 'include'
                });

                if (cashbackResponse.ok) {
                    const cashbackData = await cashbackResponse.json();
                    if (cashbackData.cashbacks && cashbackData.cashbacks.length > 0) {
                        showCashbackEarned();
                    }
                }
            }
        }
    } catch (error) {
        console.error('Error loading share status:', error);
    }
}

// Update share progress UI
function updateShareProgress(count) {
    const shareCountEl = document.getElementById('shareCount');
    const progressBar = document.getElementById('shareProgressBar');

    if (shareCountEl) {
        shareCountEl.textContent = `${count} / 3`;
    }

    if (progressBar) {
        const percentage = Math.min((count / 3) * 100, 100);
        progressBar.style.width = `${percentage}%`;
    }
}

// Mark a share button as shared
function markButtonAsShared(platform) {
    const btn = document.getElementById(`shareBtn_${platform}`);
    if (btn) {
        btn.classList.add('shared');
        btn.disabled = true;
    }
}

// Show cashback earned message with animation
function showCashbackEarned() {
    const statusEl = document.getElementById('cashbackStatus');
    if (statusEl) {
        statusEl.classList.add('show');

        // Also update progress to 100%
        updateShareProgress(3);

        // Trigger celebration animation
        const confetti = document.getElementById('cashbackConfetti');
        if (confetti) {
            confetti.innerHTML = '';
            createConfetti();
        }
    }
}

// Close modal when clicking outside
document.addEventListener('click', (e) => {
    const modal = document.getElementById('cashbackOfferModal');
    if (modal && e.target === modal) {
        closeCashbackModal();
    }
});

