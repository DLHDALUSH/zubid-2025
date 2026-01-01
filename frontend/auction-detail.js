// Auction detail page functionality
let auctionId = null;
let auctionData = null;
let bidInterval = null;
let countdownInterval = null;

// SVG Placeholder for missing images
const SVG_PLACEHOLDER = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAwIiBoZWlnaHQ9IjQwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZmY2NjAwIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIyNCIgZmlsbD0iI2ZmZmZmZiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPk5vIEltYWdlPC90ZXh0Pjwvc3ZnPg==';

// Helper function to convert data URI to blob URL (more reliable)
function dataUriToBlobUrl(dataUri) {
    try {
        // Validate data URI format
        if (!dataUri || !dataUri.startsWith('data:image/')) {
            return null;
        }
        
        // Check if data URI is truncated (common issue: database column limit)
        // A valid data URI should be much longer than 500 characters
        if (dataUri.length <= 500) {
            console.warn('⚠️ Data URI appears truncated (length:', dataUri.length, ')');
            console.warn('This usually means the database column was too small.');
            console.warn('The image data is incomplete and cannot be displayed.');
            return null;
        }
        
        // Check if data URI is complete (has comma and data after)
        const commaIndex = dataUri.indexOf(',');
        if (commaIndex === -1 || commaIndex === dataUri.length - 1) {
            console.warn('Incomplete data URI - missing data after comma');
            return null;
        }
        
        // Extract base64 data
        const base64Data = dataUri.substring(commaIndex + 1);
        if (!base64Data || base64Data.length < 100) {
            console.warn('Data URI too short or empty (base64 data:', base64Data.length, 'chars)');
            return null;
        }
        
        // Convert base64 to binary
        const byteCharacters = atob(base64Data);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        
        // Determine MIME type
        const mimeMatch = dataUri.match(/data:image\/([^;]+)/);
        const mimeType = mimeMatch ? `image/${mimeMatch[1]}` : 'image/jpeg';
        
        // Create blob and URL
        const blob = new Blob([byteArray], { type: mimeType });
        return URL.createObjectURL(blob);
    } catch (error) {
        console.error('Error converting data URI to blob:', error);
        return null;
    }
}

// Helper function to convert image URLs
function convertImageUrl(imageUrl) {
    if (!imageUrl) return SVG_PLACEHOLDER;

    let urlString = String(imageUrl).trim();
    if (urlString === '' || urlString === 'null' || urlString === 'undefined') {
        return SVG_PLACEHOLDER;
    }

    // Fix corrupted URLs: handle /https:// or /http:// (leading slash before protocol)
    if (urlString.startsWith('/https://') || urlString.startsWith('/http://')) {
        urlString = urlString.substring(1); // Remove leading slash
    }

    // Fix double URL: detect if URL contains another full URL (https://...https://)
    const doubleHttpsMatch = urlString.match(/^(https?:\/\/[^/]+\/)(https?:\/\/.+)$/);
    if (doubleHttpsMatch) {
        console.warn('Detected double URL, extracting inner URL:', urlString.substring(0, 100));
        urlString = doubleHttpsMatch[2]; // Use the inner (correct) URL
    }

    // Detect corrupted/truncated URLs and return placeholder
    if (urlString.includes('cloudinar') && !urlString.includes('cloudinary')) {
        console.warn('Corrupted Cloudinary URL detected:', urlString.substring(0, 100));
        return SVG_PLACEHOLDER;
    }
    if (urlString.startsWith('https://res.') && !urlString.includes('.com/') && !urlString.includes('.net/') && !urlString.includes('.org/')) {
        console.warn('Malformed URL detected (missing TLD):', urlString.substring(0, 100));
        return SVG_PLACEHOLDER;
    }
    if (/\.(jp|pn|gi|we|sv|bm)$/i.test(urlString)) {
        console.warn('Truncated file extension detected:', urlString.substring(0, 100));
        return SVG_PLACEHOLDER;
    }

    // Data URIs - return as-is (no conversion to blob needed)
    if (urlString.startsWith('data:image/')) {
        return urlString;
    }

    // Absolute URLs - validate and return
    if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
        try {
            const parsedUrl = new URL(urlString);
            if (!parsedUrl.hostname.includes('.') || parsedUrl.hostname.length < 4) {
                console.warn('Invalid domain in URL:', urlString.substring(0, 100));
                return SVG_PLACEHOLDER;
            }
            return urlString;
        } catch (e) {
            console.warn('Invalid URL:', urlString);
            return SVG_PLACEHOLDER;
        }
    }

    // Relative URLs - construct full URL
    const baseUrl = window.API_BASE || (window.location.hostname === 'localhost' ? 'http://localhost:5000' : window.location.origin);
    const relativeUrl = urlString.startsWith('/') ? urlString : '/' + urlString;
    return baseUrl + relativeUrl;
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', async () => {
    console.log('Auction detail page loaded');
    
    // Check if required APIs are loaded
    if (typeof AuctionAPI === 'undefined') {
        console.error('AuctionAPI is not defined. Make sure api.js is loaded before auction-detail.js');
        const loadingIndicator = document.getElementById('loadingIndicator');
        if (loadingIndicator) {
            loadingIndicator.innerHTML = '<div class="error-state"><p>API not loaded. Please refresh the page.</p></div>';
        }
        return;
    }
    
    const urlParams = new URLSearchParams(window.location.search);
    auctionId = urlParams.get('id');
    
    console.log('Auction ID from URL:', auctionId);
    
    if (auctionId) {
        try {
            await loadAuctionDetail();
            await loadBidHistory();
            startRealTimeUpdates();
            startCountdown();
            
            // Check if user won this auction and show cashback offer
            setTimeout(() => {
                checkWinnerStatus();
            }, 2000);
            
            // Check if page was loaded with #video hash and auto-play video
            if (window.location.hash === '#video') {
                // Wait for auction to load, then show video
                setTimeout(() => {
                    if (window.currentVideoUrl) {
                        showVideo();
                    }
                }, 500);
            }
        } catch (error) {
            console.error('Error initializing auction detail page:', error);
            if (window.ErrorHandler) {
                ErrorHandler.handle(error, 'auctionDetailInit');
            }
        }
    } else {
        const loadingIndicator = document.getElementById('loadingIndicator');
        if (loadingIndicator) {
            loadingIndicator.innerHTML = '<div class="error-state"><p>Invalid auction ID. Please select an auction from the list.</p><button class="btn btn-primary" onclick="window.location.href=\'auctions.html\'">Go to Auctions</button></div>';
        }
        if (window.ToastManager) {
            ToastManager.show('Invalid auction ID', 'error');
        } else if (window.showToast) {
            const errorMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.invalidAuctionId', 'Invalid auction ID') : 'Invalid auction ID';
            showToast(errorMsg, 'error');
        }
    }
});

// Load auction details
async function loadAuctionDetail() {
    console.log('Loading auction with ID:', auctionId);
    const loadingIndicator = document.getElementById('loadingIndicator');
    
    if (!auctionId) {
        const errorMsg = 'No auction ID provided in URL';
        console.error(errorMsg);
        if (loadingIndicator) {
            loadingIndicator.innerHTML = `<div class="error-state">
                <p>${errorMsg}</p>
                <button class="btn btn-primary" onclick="window.location.href='auctions.html'">Go to Auctions</button>
            </div>`;
        }
        if (window.ErrorHandler) {
            ErrorHandler.handle(new Error(errorMsg), 'loadAuctionDetail');
        } else if (window.showToast) {
            showToast(errorMsg, 'error');
        }
        return;
    }
    
    try {
        // Show loading state
        if (loadingIndicator) {
            loadingIndicator.style.display = 'block';
            loadingIndicator.innerHTML = '<div class="loading-container"><div class="loading-spinner"></div><p>Loading auction details...</p></div>';
        }
        
        // Check if AuctionAPI is available
        if (typeof AuctionAPI === 'undefined' || !AuctionAPI.getById) {
            throw new Error('AuctionAPI is not available. Please check if api.js is loaded.');
        }
        
        console.log('Calling AuctionAPI.getById with ID:', auctionId);
        
        // Add timeout to prevent hanging
        const timeoutPromise = new Promise((_, reject) => {
            setTimeout(() => reject(new Error('Request timeout: Server did not respond within 10 seconds')), 10000);
        });
        
        const apiPromise = AuctionAPI.getById(auctionId);
        auctionData = await Promise.race([apiPromise, timeoutPromise]);
        
        console.log('Auction data loaded successfully:', auctionData);
        
        if (!auctionData) {
            throw new Error('No auction data returned from server');
        }
        
        displayAuctionDetail(auctionData);
    } catch (error) {
        console.error('Error loading auction:', error);
        
        // Use enhanced error handler if available
        if (window.ErrorHandler) {
            ErrorHandler.handle(error, 'loadAuctionDetail');
        } else if (window.utils && window.utils.debugError) {
            window.utils.debugError('Error loading auction:', error);
        }
        
        // Show error in loading indicator
        if (loadingIndicator) {
            const errorMsg = error.message || 'Failed to load auction details';
            const safeErrorMsg = escapeHtml(errorMsg);
            loadingIndicator.innerHTML = `<div class="error-state">
                <p><strong>Error:</strong> ${safeErrorMsg}</p>
                <p>Please check:</p>
                <ul style="text-align: left; display: inline-block; margin: 1rem 0;">
                    <li>Is the backend server running on port 5000?</li>
                    <li>Is the auction ID valid?</li>
                    <li>Check the browser console for more details</li>
                </ul>
                <div style="margin-top: 1rem;">
                    <button class="btn btn-primary" onclick="loadAuctionDetail()" style="margin-right: 0.5rem;">Retry</button>
                    <button class="btn btn-outline" onclick="window.location.href='auctions.html'">Go to Auctions</button>
                </div>
            </div>`;
            loadingIndicator.style.display = 'block';
        }
        
        // Show toast notification
        if (window.ToastManager) {
            ToastManager.show(error.message || 'Failed to load auction details', 'error', 5000);
        } else if (window.showToast) {
            showToast(error.message || 'Failed to load auction details', 'error');
        }
    }
}

// Display auction details
function displayAuctionDetail(auction) {
    auctionData = auction;
    
    // Debug logging
    console.log('Displaying auction:', auction.id);
    console.log('Images array:', auction.images);
    if (auction.images && auction.images.length > 0) {
        console.log('First image URL length:', auction.images[0].url.length);
        console.log('First image URL start:', auction.images[0].url.substring(0, 100));
    }
    
    document.getElementById('loadingIndicator').style.display = 'none';
    document.getElementById('auctionDetail').style.display = 'block';
    
    // Set basic info
    document.getElementById('auctionItemName').textContent = auction.item_name || 'Unnamed Auction';
    const descriptionEl = document.getElementById('auctionDescription');
    if (descriptionEl) {
        const description = auction.description || 'No description available.';
        // Use textContent to prevent XSS, but preserve line breaks
        descriptionEl.textContent = description;
        // Ensure description is visible and properly styled
        const descriptionSection = descriptionEl.closest('.auction-description');
        if (descriptionSection) {
            descriptionSection.style.display = 'block';
        }
        // Ensure the paragraph has proper styling for line breaks
        descriptionEl.style.whiteSpace = 'pre-wrap';
        descriptionEl.style.wordWrap = 'break-word';
        
        // Initialize description as minimized
        const descriptionContent = document.getElementById('descriptionContent');
        const descriptionToggleBtn = document.getElementById('descriptionToggleBtn');
        const descriptionToggleText = document.getElementById('descriptionToggleText');
        const descriptionToggleIcon = document.getElementById('descriptionToggleIcon');
        
        if (descriptionContent) {
            // Use setTimeout to ensure the element is rendered before checking height
            setTimeout(() => {
                // Check if description is long enough to need truncation
                const descriptionHeight = descriptionEl.scrollHeight;
                if (descriptionHeight > 150) {
                    // Description is long, show toggle button
                    if (descriptionToggleBtn) {
                        descriptionToggleBtn.style.display = 'block';
                    }
                    // Set initial state to minimized
                    descriptionContent.style.maxHeight = '150px';
                    descriptionContent.classList.add('description-minimized');
                } else {
                    // Description is short, hide toggle button
                    if (descriptionToggleBtn) {
                        descriptionToggleBtn.style.display = 'none';
                    }
                    descriptionContent.style.maxHeight = 'none';
                    descriptionContent.classList.remove('description-minimized');
                }
            }, 100);
        }
    }
    document.getElementById('currentBid').textContent = `$${(auction.current_bid || 0).toFixed(2)}`;
    document.getElementById('startingBid').textContent = `$${(auction.starting_bid || 0).toFixed(2)}`;
    document.getElementById('bidIncrement').textContent = `$${(auction.bid_increment || 1).toFixed(2)}`;
    document.getElementById('bidCount').textContent = auction.bid_count || 0;
    
    // Set market price if available
    console.log('Market Price from API:', auction.market_price);
    console.log('Real Price from API:', auction.real_price);

    const marketPriceStat = document.getElementById('marketPriceStat');
    const marketPriceEl = document.getElementById('marketPrice');
    if (marketPriceStat && marketPriceEl) {
        if (auction.market_price && auction.market_price > 0) {
            marketPriceEl.textContent = `$${parseFloat(auction.market_price).toFixed(2)}`;
            marketPriceStat.style.display = 'block';
            console.log('Market Price displayed:', auction.market_price);
        } else {
            marketPriceStat.style.display = 'none';
        }
    }

    // Set real price (Buy It Now) if available
    const realPriceStat = document.getElementById('realPriceStat');
    const realPriceEl = document.getElementById('realPrice');
    const buyNowSection = document.getElementById('buyNowSection');
    const buyNowPriceEl = document.getElementById('buyNowPrice');

    console.log('Real Price elements found:', { stat: !!realPriceStat, el: !!realPriceEl, buyNow: !!buyNowSection });
    console.log('Real Price value:', auction.real_price, 'Type:', typeof auction.real_price);

    const realPriceValue = parseFloat(auction.real_price) || 0;

    if (realPriceStat && realPriceEl) {
        if (realPriceValue > 0) {
            realPriceEl.textContent = `$${realPriceValue.toFixed(2)}`;
            realPriceStat.style.display = 'block';
            realPriceStat.style.visibility = 'visible';
            realPriceStat.style.opacity = '1';
            console.log('✅ Real Price displayed:', realPriceValue);
        } else {
            realPriceStat.style.display = 'none';
            console.log('❌ Real Price hidden - value is 0 or null');
        }
    } else {
        console.log('❌ Real Price elements NOT found in DOM');
    }

    // Show Buy Now section if real price exists and auction is active
    if (buyNowSection && buyNowPriceEl && realPriceValue > 0 && auction.status === 'active') {
        buyNowPriceEl.textContent = `$${realPriceValue.toFixed(2)}`;
        buyNowSection.style.display = 'block';
        // Store the real price for use in buyNow function
        window.currentAuctionRealPrice = realPriceValue;
        console.log('✅ Buy Now section displayed with price:', realPriceValue);
    } else if (buyNowSection) {
        buyNowSection.style.display = 'none';
    }
    
    // Set warning section
    const warningSection = document.getElementById('auctionWarning');
    const warningContent = document.getElementById('warningContent');
    if (auction.warning || auction.warning_message) {
        const warningText = auction.warning || auction.warning_message;
        warningContent.innerHTML = typeof warningText === 'string' ? `<p>${escapeHtml(warningText)}</p>` : warningText;
        warningSection.style.display = 'block';
    } else {
        warningSection.style.display = 'none';
    }
    
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
        console.log('Setting main image...');
        console.log('Number of images:', auction.images.length);
        console.log('First image URL type:', auction.images[0].url ? auction.images[0].url.substring(0, 50) : 'null');
        
        const mainImage = document.getElementById('mainAuctionImage');
        if (!mainImage) {
            console.error('Main image element not found!');
            return;
        }
        
        const imageUrl = auction.images[0].url;
        const convertedUrl = convertImageUrl(imageUrl);
        
        console.log('Original URL length:', imageUrl ? imageUrl.length : 0);
        console.log('Converted URL type:', convertedUrl.substring(0, 50));
        
        // Set image source
        mainImage.src = convertedUrl;
        
        mainImage.onload = function() {
            console.log('✅ Main image loaded successfully!');
        };
        mainImage.onerror = function(e) {
            console.error('❌ Main image failed to load!', e);
            console.error('Failed URL:', convertedUrl.substring(0, 100));
            this.src = SVG_PLACEHOLDER;
        };
        
        // Set thumbnails
        const thumbnails = document.getElementById('imageThumbnails');
        if (!thumbnails) {
            console.error('Thumbnails container not found!');
            return;
        }
        
        thumbnails.innerHTML = '';
        
        auction.images.forEach((img, index) => {
            const thumbImg = document.createElement('img');
            thumbImg.alt = `Thumbnail ${index + 1}`;
            thumbImg.className = `thumbnail ${index === 0 ? 'active' : ''}`;
            
            const thumbUrl = convertImageUrl(img.url);
            thumbImg.src = thumbUrl;
            
            thumbImg.onload = function() {
                console.log(`✅ Thumbnail ${index + 1} loaded`);
            };
            
            thumbImg.onerror = function() {
                console.error(`❌ Thumbnail ${index + 1} failed to load`);
                this.src = SVG_PLACEHOLDER;
            };
            
            thumbImg.onclick = function() {
                const newMainUrl = convertImageUrl(img.url);
                changeMainImage(newMainUrl);
                document.querySelectorAll('.thumbnail').forEach(t => t.classList.remove('active'));
                this.classList.add('active');
            };
            
            thumbnails.appendChild(thumbImg);
        });
    } else {
        console.log('No images found, using placeholder');
        const mainImage = document.getElementById('mainAuctionImage');
        if (mainImage) {
            mainImage.src = SVG_PLACEHOLDER;
        }
    }
    
    // Set video if available
    if (auction.video_url) {
        const videoThumbnail = document.getElementById('videoThumbnail');
        const videoContainer = document.getElementById('videoContainer');
        const mainImage = document.getElementById('mainAuctionImage');
        
        // Store video URL globally for showVideo function
        window.currentVideoUrl = auction.video_url;
        
        // Show video button
        videoThumbnail.style.display = 'block';
        
        // Add video thumbnail to thumbnails
        const thumbnails = document.getElementById('imageThumbnails');
        const videoThumb = document.createElement('div');
        videoThumb.className = 'thumbnail video-thumbnail';
        videoThumb.style.cssText = 'width: 110px; height: 110px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; display: flex; align-items: center; justify-content: center; cursor: pointer; color: white; font-size: 2rem;';
        videoThumb.onclick = () => showVideo();
        videoThumb.innerHTML = '🎥';
        videoThumb.title = 'Play Video';
        thumbnails.appendChild(videoThumb);
    } else {
        document.getElementById('videoThumbnail').style.display = 'none';
        document.getElementById('videoContainer').style.display = 'none';
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
    const mainImage = document.getElementById('mainAuctionImage');
    const videoContainer = document.getElementById('videoContainer');
    
    // Hide video, show image
    videoContainer.style.display = 'none';
    mainImage.style.display = 'block';
    mainImage.src = imageUrl;
    
    document.querySelectorAll('.thumbnail').forEach(thumb => {
        thumb.classList.remove('active');
        if (thumb.src && thumb.src === imageUrl) {
            thumb.classList.add('active');
        }
    });
}

// Convert video URL to embed URL or return direct video URL
function convertToEmbedUrl(url) {
    if (!url || typeof url !== 'string') return null;
    
    // Check if it's a local upload (starts with /uploads/)
    if (url.startsWith('/uploads/')) {
        // Construct full URL for local videos
        const baseUrl = window.API_BASE || (window.location.hostname === 'localhost' ? 'http://localhost:5000' : window.location.origin);
        return baseUrl + url;
    }
    
    // YouTube URLs
    if (url.includes('youtube.com/watch?v=')) {
        const videoId = url.split('v=')[1]?.split('&')[0];
        if (videoId) {
            return `https://www.youtube.com/embed/${videoId}`;
        }
    }
    if (url.includes('youtu.be/')) {
        const videoId = url.split('youtu.be/')[1]?.split('?')[0];
        if (videoId) {
            return `https://www.youtube.com/embed/${videoId}`;
        }
    }
    if (url.includes('youtube.com/embed/')) {
        return url; // Already an embed URL
    }
    
    // Vimeo URLs
    if (url.includes('vimeo.com/')) {
        const videoId = url.split('vimeo.com/')[1]?.split('?')[0];
        if (videoId) {
            return `https://player.vimeo.com/video/${videoId}`;
        }
    }
    if (url.includes('player.vimeo.com/video/')) {
        return url; // Already an embed URL
    }
    
    // Direct video URLs (mp4, webm, etc.) - check if absolute URL
    if (url.match(/\.(mp4|webm|ogg|mov|avi|mkv|m4v)(\?.*)?$/i)) {
        // If it's already a full URL, return as-is
        if (url.startsWith('http://') || url.startsWith('https://')) {
            return url;
        }
        // If relative URL, construct full URL
        const baseUrl = window.API_BASE || (window.location.hostname === 'localhost' ? 'http://localhost:5000' : window.location.origin);
        return baseUrl + (url.startsWith('/') ? url : '/' + url);
    }
    
    return null;
}

// Show video player
function showVideo() {
    if (!window.currentVideoUrl) return;
    
    const mainImage = document.getElementById('mainAuctionImage');
    const videoContainer = document.getElementById('videoContainer');
    const videoPlayer = document.getElementById('videoPlayer');
    
    const embedUrl = convertToEmbedUrl(window.currentVideoUrl);
    
    if (embedUrl) {
        // Check if it's a local video file (not an embed URL)
        const isLocalVideo = (window.currentVideoUrl && typeof window.currentVideoUrl === 'string' && 
                            (window.currentVideoUrl.match(/\.(mp4|webm|ogg|mov|avi|mkv|m4v)(\?.*)?$/i) || 
                            window.currentVideoUrl.startsWith('/uploads/')));
        
        if (isLocalVideo) {
            // For local videos, use HTML5 video player instead of iframe
            // Determine video MIME type from URL
            let videoType = 'video/mp4';
            if (embedUrl && typeof embedUrl === 'string') {
                if (embedUrl.includes('.webm')) videoType = 'video/webm';
                else if (embedUrl.includes('.ogg')) videoType = 'video/ogg';
                else if (embedUrl.includes('.mov')) videoType = 'video/quicktime';
                else if (embedUrl.includes('.avi')) videoType = 'video/x-msvideo';
                else if (embedUrl.includes('.mkv')) videoType = 'video/x-matroska';
                else if (embedUrl.includes('.m4v')) videoType = 'video/mp4';
            }
            
	            const safeEmbedUrl = escapeHtml(embedUrl || '');
	            const safeVideoType = escapeHtml(videoType || 'video/mp4');
	            videoContainer.innerHTML = `
	                <video id="localVideoPlayer" controls style="width: 100%; height: 100%; border-radius: 20px; background: #000;" preload="metadata">
	                    <source src="${safeEmbedUrl}" type="${safeVideoType}">
	                    Your browser does not support the video tag.
	                </video>
	            `;
        } else {
            // For YouTube/Vimeo, use iframe
            videoPlayer.src = embedUrl;
        }
        
        mainImage.style.display = 'none';
        videoContainer.style.display = 'block';
        
        // Scroll to video
        videoContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
        
        // Update URL hash for direct video link
        if (window.history && window.history.pushState) {
            window.history.pushState(null, null, '#video');
        }
    } else {
        const errorMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.invalidVideoUrl', 'Invalid video URL format') : 'Invalid video URL format';
        showToast(errorMsg, 'error');
    }
}

// Check if page was loaded with #video hash and auto-play video
document.addEventListener('DOMContentLoaded', () => {
    if (window.location.hash === '#video') {
        // Wait for auction to load, then show video
        setTimeout(() => {
            if (window.currentVideoUrl) {
                showVideo();
            }
        }, 1000);
    }
});

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

// Buy Now - Purchase at real price instantly
async function buyNow() {
    if (!currentUser) {
        showToast('Please login to purchase this item', 'error');
        showLogin();
        return;
    }

    if (!auctionData || !window.currentAuctionRealPrice) {
        showToast('Unable to process purchase. Please refresh the page.', 'error');
        return;
    }

    const realPrice = window.currentAuctionRealPrice;

    // Confirm purchase
    const confirmed = confirm(`Are you sure you want to buy this item for $${realPrice.toFixed(2)}?\n\nThis will immediately end the auction and you will be the winner.`);

    if (!confirmed) {
        return;
    }

    try {
        // Disable button during processing
        const buyNowBtn = document.querySelector('.btn-buy-now');
        if (buyNowBtn) {
            buyNowBtn.disabled = true;
            buyNowBtn.innerHTML = '<span class="btn-icon">⏳</span><span class="btn-text">Processing...</span>';
        }

        const response = await fetch(`${window.API_BASE_URL || (window.location.hostname === 'localhost' ? 'http://localhost:5000/api' : window.location.origin + '/api')}/auctions/${auctionData.id}/buy-now`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include'
        });

        const data = await response.json();

        if (response.ok) {
            showToast('🎉 Congratulations! You purchased this item!', 'success');

            // Hide buy now section
            const buyNowSection = document.getElementById('buyNowSection');
            if (buyNowSection) {
                buyNowSection.style.display = 'none';
            }

            // Refresh auction details
            await loadAuctionDetail();

            // Show payment redirect option
            setTimeout(() => {
                if (confirm('Would you like to go to payments to complete your purchase?')) {
                    window.location.href = 'payments.html';
                }
            }, 1000);
        } else {
            showToast(data.error || 'Failed to complete purchase', 'error');

            // Re-enable button
            if (buyNowBtn) {
                buyNowBtn.disabled = false;
                buyNowBtn.innerHTML = '<span class="btn-icon">💰</span><span class="btn-text">Buy Now</span>';
            }
        }
    } catch (error) {
        console.error('Error processing buy now:', error);
        showToast('Error processing purchase. Please try again.', 'error');

        // Re-enable button
        const buyNowBtn = document.querySelector('.btn-buy-now');
        if (buyNowBtn) {
            buyNowBtn.disabled = false;
            buyNowBtn.innerHTML = '<span class="btn-icon">💰</span><span class="btn-text">Buy Now</span>';
        }
    }
}

// Place bid with enhanced validation and feedback
async function placeBid() {
    if (!currentUser) {
        const errorMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.loginRequired', 'Please login to place a bid') : 'Please login to place a bid';
        showToast(errorMsg, 'error');
        showLogin();
        return;
    }
    
    if (!auctionData || auctionData.status !== 'active') {
        const errorMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.auctionInactive', 'This auction is no longer active') : 'This auction is no longer active';
        showToast(errorMsg, 'error');
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
        showToast('Bid placed successfully! Refreshing page...', 'success');
        
        // Refresh the page after bid is placed to show updated price
        setTimeout(() => {
            window.location.reload();
        }, 1500);
    } catch (error) {
        if (window.utils) window.utils.debugError('Error placing bid:', error);
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
            
            // Escape HTML to prevent XSS
            const escapeHtml = (text) => {
                if (text == null) return '';
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            };
            
            container.innerHTML = `
                <div class="bid-history-list">
                    ${sortedBids.map((bid, index) => {
                        // Determine winner status based on auction state
                        let isWinner = false;
                        
                        if (auctionData.status === 'active') {
                            // For active auctions: highest bid is winning
                            isWinner = bid.is_winning || index === 0;
                        } else if (auctionData.status === 'ended') {
                            // For ended auctions: check if this bid won
                            // Use is_winning from backend OR check if user matches winner_id and amount is highest
                            isWinner = bid.is_winning || 
                                       (auctionData.winner_id && bid.user_id === auctionData.winner_id && index === 0);
                        }
                        
                        const isCurrentUser = currentUser && bid.user_id === currentUser.id;
                        const username = escapeHtml(bid.username || 'Unknown');
                        
                        return `
                        <div class="bid-history-item ${isWinner ? 'winner-bid' : 'losing-bid'} ${isCurrentUser ? 'current-user-bid' : ''}">
                            <div class="bid-info">
                                <div class="bid-header">
                                    <strong>${username}</strong>
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
        if (window.utils) window.utils.debugError('Error loading bid history:', error);
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
	        const safeUsername = escapeHtml(winnerBid.username || 'Unknown');
	        winnerDisplay.innerHTML = `
	            <div class="winner-announcement ${isCurrentUser ? 'your-winner' : ''}">
	                <h3>🏆 Current Highest Bid</h3>
	                <p><strong>${safeUsername}</strong> is currently winning with <strong>$${winnerBid.amount.toFixed(2)}</strong></p>
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
    let pollInterval = 5000; // Start with 5 seconds
    let consecutiveNoChanges = 0;
    
    const pollBids = async () => {
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
	                                const safeUsername = escapeHtml(winner.username || 'Unknown');
	                                winnerInfo.innerHTML = `
	                                    <div class="winner-announcement-final ${isCurrentUser ? 'your-winner' : ''}">
	                                        <h3>🎉 Auction Winner</h3>
	                                        <p><strong>${safeUsername}</strong> won with a bid of <strong>$${winner.amount.toFixed(2)}</strong></p>
	                                        ${isCurrentUser ? '<p class="congratulations">Congratulations! You won this auction!</p>' : ''}
	                                    </div>
	                                `;
                                
                                if (isCurrentUser) {
                                    showToast('🎉 Congratulations! You won this auction!', 'success');
                                    // Show cashback offer modal
                                    setTimeout(() => {
                                        if (typeof showCashbackOfferModal === 'function') {
                                            showCashbackOfferModal(auctionId, updatedAuction.item_name);
                                        }
                                    }, 2000);
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
                
                // Refresh page when auction ends
                setTimeout(() => {
                    window.location.reload();
                }, 2000);
            }
        } catch (error) {
            console.error('Error updating auction:', error);
            // Don't show toast for every error to avoid spam
        }
    };
    
    // Start polling
    bidInterval = setInterval(pollBids, pollInterval);
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
            // Refresh page when auction ends
            setTimeout(() => {
                window.location.reload();
            }, 1000);
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

// Toggle description expand/collapse
function toggleDescription() {
    const descriptionContent = document.getElementById('descriptionContent');
    const descriptionToggleBtn = document.getElementById('descriptionToggleBtn');
    const descriptionToggleText = document.getElementById('descriptionToggleText');
    const descriptionToggleIcon = document.getElementById('descriptionToggleIcon');
    
    if (!descriptionContent) return;
    
    const isMinimized = descriptionContent.classList.contains('description-minimized');
    
    if (isMinimized) {
        // Expand
        const fullHeight = descriptionContent.scrollHeight;
        descriptionContent.style.maxHeight = fullHeight + 'px';
        descriptionContent.classList.remove('description-minimized');
        descriptionContent.classList.add('description-expanded');
        
        if (descriptionToggleText) {
            descriptionToggleText.textContent = 'Show Less';
        }
        if (descriptionToggleIcon) {
            descriptionToggleIcon.textContent = '▲';
        }
    } else {
        // Collapse
        descriptionContent.style.maxHeight = '150px';
        descriptionContent.classList.remove('description-expanded');
        descriptionContent.classList.add('description-minimized');
        
        if (descriptionToggleText) {
            descriptionToggleText.textContent = 'Show More';
        }
        if (descriptionToggleIcon) {
            descriptionToggleIcon.textContent = '▼';
        }
    }
}

// Check if current user won the auction and show cashback offer
async function checkWinnerStatus() {
    try {
        if (!auctionData || !currentUser) return;
        
        // Check if auction ended and user is winner
        if (auctionData.status === 'ended' && auctionData.winner_id === currentUser.id) {
            // Check if we already showed the modal (using sessionStorage)
            const modalShown = sessionStorage.getItem(`cashback_modal_shown_${auctionId}`);
            if (!modalShown) {
                // Show cashback offer modal after a short delay
                setTimeout(() => {
                    if (typeof showCashbackOfferModal === 'function') {
                        showCashbackOfferModal(auctionId, auctionData.item_name);
                        sessionStorage.setItem(`cashback_modal_shown_${auctionId}`, 'true');
                    }
                }, 3000);
            }
        }
    } catch (error) {
        console.error('Error checking winner status:', error);
    }
}

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
    if (bidInterval) clearInterval(bidInterval);
    if (countdownInterval) clearInterval(countdownInterval);
});

