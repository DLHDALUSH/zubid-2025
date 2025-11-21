// Social Sharing and Cashback functionality

// Show cashback offer modal when user wins an auction
function showCashbackOfferModal(auctionId, auctionName) {
    // Check if modal already exists
    let modal = document.getElementById('cashbackOfferModal');
    if (!modal) {
        // Create modal
        modal = document.createElement('div');
        modal.id = 'cashbackOfferModal';
        modal.className = 'modal';
        modal.style.display = 'none';
        modal.innerHTML = `
            <div class="modal-content" style="max-width: 600px; background: var(--glass-bg); backdrop-filter: blur(20px); border-radius: 24px; padding: 2.5rem; box-shadow: var(--shadow-xl); border: 2px solid var(--glass-border);">
                <div style="text-align: center; margin-bottom: 2rem;">
                    <div style="font-size: 4rem; margin-bottom: 1rem;">🎉</div>
                    <h2 style="font-size: 2rem; margin-bottom: 0.5rem; color: var(--primary-color);">Congratulations!</h2>
                    <p style="font-size: 1.2rem; color: var(--text-secondary);">You won the auction!</p>
                </div>
                
                <div style="background: rgba(255, 102, 0, 0.1); padding: 1.5rem; border-radius: 16px; margin-bottom: 2rem; border-left: 4px solid var(--primary-color);">
                    <h3 style="font-size: 1.3rem; margin-bottom: 1rem; color: var(--primary-color);">💰 Get $5 Cashback!</h3>
                    <p style="color: var(--text-color); line-height: 1.8; margin-bottom: 1rem;">
                        Share ZUBID on <strong>3 different social media platforms</strong> and get <strong>$5 cashback</strong> applied to your invoice!
                    </p>
                    <div id="shareProgress" style="margin-top: 1rem;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                            <span style="color: var(--text-secondary);">Progress:</span>
                            <span id="shareCount" style="font-weight: 600; color: var(--primary-color);">0 / 3</span>
                        </div>
                        <div style="background: var(--bg-light); border-radius: 12px; height: 12px; overflow: hidden;">
                            <div id="shareProgressBar" style="background: var(--bg-gradient-warm); height: 100%; width: 0%; transition: width 0.3s ease; border-radius: 12px;"></div>
                        </div>
                    </div>
                </div>
                
                <div id="socialShareButtons" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; margin-bottom: 1.5rem; max-width: 100%;">
                    <!-- Social share buttons will be inserted here -->
                </div>
                
                <div id="cashbackStatus" style="display: none; padding: 1rem; background: rgba(0, 200, 83, 0.1); border-radius: 12px; margin-bottom: 1rem; border: 1px solid rgba(0, 200, 83, 0.3);">
                    <p style="color: #00c853; margin: 0; font-weight: 500;">✅ Cashback earned! $5 will be applied to your invoice.</p>
                </div>
                
                <div style="display: flex; gap: 1rem; justify-content: center;">
                    <button onclick="closeCashbackModal()" class="btn btn-outline" style="padding: 0.875rem 2rem;">Close</button>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }
    
    // Load current share status
    loadShareStatus(auctionId);
    
    // Setup social share buttons
    setupSocialShareButtons(auctionId, auctionName);
    
    // Show modal
    modal.style.display = 'flex';
}

// Close cashback modal
function closeCashbackModal() {
    const modal = document.getElementById('cashbackOfferModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Setup social share buttons
function setupSocialShareButtons(auctionId, auctionName) {
    const container = document.getElementById('socialShareButtons');
    if (!container) return;
    
    const shareUrl = window.location.origin + '/auction-detail.html?id=' + auctionId;
    const shareText = `Check out this amazing auction on ZUBID: ${auctionName}!`;
    
    const platforms = [
        { name: 'Facebook', icon: '📘', color: '#1877F2' },
        { name: 'Twitter', icon: '🐦', color: '#1DA1F2' },
        { name: 'LinkedIn', icon: '💼', color: '#0077B5' },
        { name: 'WhatsApp', icon: '💬', color: '#25D366' },
        { name: 'Telegram', icon: '✈️', color: '#0088CC' },
        { name: 'Reddit', icon: '🤖', color: '#FF4500' },
        { name: 'TikTok', icon: '🎵', color: '#000000' },
        { name: 'Instagram', icon: '📷', color: '#E4405F' },
        { name: 'Snapchat', icon: '👻', color: '#FFFC00' }
    ];
    
    container.innerHTML = platforms.map(platform => {
        const platformLower = platform.name.toLowerCase();
        return `
            <button onclick="shareOnPlatform('${platformLower}', ${auctionId})" 
                    class="social-share-btn" 
                    id="shareBtn_${platformLower}"
                    style="padding: 1rem; background: var(--bg-light); border: 2px solid var(--border-color); border-radius: 12px; cursor: pointer; transition: var(--transition-base); display: flex; flex-direction: column; align-items: center; gap: 0.5rem;"
                    onmouseover="this.style.borderColor='${platform.color}'; this.style.transform='translateY(-2px)'"
                    onmouseout="this.style.borderColor='var(--border-color)'; this.style.transform='translateY(0)'">
                <span style="font-size: 2rem;">${platform.icon}</span>
                <span style="font-size: 0.9rem; font-weight: 500; color: var(--text-color);">${platform.name}</span>
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
            const shareCountEl = document.getElementById('shareCount');
            const progressBar = document.getElementById('shareProgressBar');
            
            if (shareCountEl) {
                shareCountEl.textContent = `${shareCount} / 3`;
            }
            
            if (progressBar) {
                const percentage = (shareCount / 3) * 100;
                progressBar.style.width = `${percentage}%`;
            }
            
            // Mark shared platforms
            shares.forEach(share => {
                const btn = document.getElementById(`shareBtn_${share.platform}`);
                if (btn) {
                    btn.style.background = 'rgba(0, 200, 83, 0.1)';
                    btn.style.borderColor = '#00c853';
                    btn.disabled = true;
                    btn.innerHTML = `<span style="font-size: 1.5rem;">✅</span><span style="font-size: 0.8rem;">Shared!</span>`;
                }
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

// Show cashback earned message
function showCashbackEarned() {
    const statusEl = document.getElementById('cashbackStatus');
    if (statusEl) {
        statusEl.style.display = 'block';
    }
}

// Close modal when clicking outside
document.addEventListener('click', (e) => {
    const modal = document.getElementById('cashbackOfferModal');
    if (modal && e.target === modal) {
        closeCashbackModal();
    }
});

