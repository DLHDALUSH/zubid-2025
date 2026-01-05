// API Configuration
// Can be configured via window.API_BASE_URL or defaults to current origin
// For production: Set window.API_BASE_URL before loading this script
// Example: <script>window.API_BASE_URL = 'https://api.yourdomain.com/api';</script>
const API_BASE_URL = window.API_BASE_URL || (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'
    ? 'http://localhost:5000/api'
    : window.location.origin + '/api');

// Export base URL without /api suffix for image URLs
const API_BASE = API_BASE_URL.replace('/api', '');
window.API_BASE = API_BASE; // Make available globally

/**
 * Convert relative image URLs to full URLs
 * Handles: /uploads/xxx, uploads/xxx, and validates existing URLs
 * @param {string} imageUrl - The image URL to convert
 * @returns {string} - Full URL or original if already absolute
 */
function getFullImageUrl(imageUrl) {
    if (!imageUrl) return null;

    // Already a full URL or data URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://') || imageUrl.startsWith('data:')) {
        return imageUrl;
    }

    // Relative URL - convert to full URL
    const baseUrl = API_BASE || API_BASE_URL.replace('/api', '');
    return baseUrl + (imageUrl.startsWith('/') ? imageUrl : '/' + imageUrl);
}

// Make globally available
window.getFullImageUrl = getFullImageUrl;

// CSRF Token Management
let csrfToken = null;

// Fetch CSRF token from server
async function fetchCSRFToken() {
    try {
        const baseUrl = API_BASE_URL.replace('/api', '');
        const response = await fetch(`${baseUrl}/api/csrf-token`, {
            credentials: 'include'
        });
        if (response.ok) {
            const data = await response.json();
            csrfToken = data.csrf_token;
            return csrfToken;
        }
    } catch (error) {
        console.warn('Failed to fetch CSRF token:', error);
    }
    return null;
}

// Initialize CSRF token on load
if (typeof window !== 'undefined') {
    fetchCSRFToken();
}

// Helper function for API requests
async function apiRequest(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;

    // Prepare headers
    const headers = {
        'Content-Type': 'application/json',
    };

    // Add CSRF token if available and it's a modifying request
    if (csrfToken && options.method && ['POST', 'PUT', 'DELETE', 'PATCH'].includes(options.method.toUpperCase())) {
        headers['X-CSRFToken'] = csrfToken;
    }

    const defaultOptions = {
        headers,
        credentials: 'include', // Include cookies for session
    };

    const config = { ...defaultOptions, ...options };

    // Merge headers properly
    if (options.headers) {
        config.headers = { ...config.headers, ...options.headers };
    }

    try {
        // Add timeout to fetch request if not already provided
        let timeoutId;
        if (!config.signal) {
            const controller = new AbortController();
            timeoutId = setTimeout(() => controller.abort(), 15000); // 15 second timeout
            config.signal = controller.signal;
        }

        console.log(`[API] ${options.method || 'GET'} ${endpoint}`, { credentials: config.credentials });
        const response = await fetch(url, config);
        
        if (timeoutId) {
            clearTimeout(timeoutId);
        }
        
        // Refresh CSRF token if expired (400 with CSRF error)
        if (response.status === 400) {
            const text = await response.clone().text();
            try {
                const errorData = JSON.parse(text);
                if (errorData.error && (errorData.error.includes('CSRF') || errorData.error.includes('csrf'))) {
                    await fetchCSRFToken();
                    // Retry with new token only if we got a valid token
                    if (csrfToken && options.method && ['POST', 'PUT', 'DELETE', 'PATCH'].includes(options.method.toUpperCase())) {
                        config.headers['X-CSRFToken'] = csrfToken;
                        const retryResponse = await fetch(url, config);
                        if (retryResponse.ok) {
                            const retryData = await retryResponse.json();
                            return retryData;
                        }
                    }
                }
            } catch (parseError) {
                // If response is not JSON, continue with normal error handling
            }
        }
        
        // Check if response is JSON
        let data;
        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
            data = await response.json();
        } else {
            const text = await response.text();
            throw new Error(`Server error: ${text || 'Unknown error'}`);
        }
        
        if (!response.ok) {
            // Don't log 401 errors as they're expected for unauthenticated users
            if (response.status === 401) {
                const error = new Error(data.error || 'Authentication required');
                error.status = 401;
                throw error;
            }
            throw new Error(data.error || `Request failed with status ${response.status}`);
        }
        
        return data;
    } catch (error) {
        // Handle abort/timeout errors
        if (error.name === 'AbortError') {
            throw new Error('Request timeout: Server did not respond. Please check if the backend is running.');
        }
        
        // Only log non-401 errors to console
        if (error.status !== 401) {
            console.error('API Error:', error);
        }
        
        // More specific error messages
        if (error.name === 'TypeError' && error.message.includes('fetch')) {
            throw new Error('Cannot connect to server. Please check your internet connection and try again.');
        }
        
        if (error.message.includes('CORS')) {
            throw new Error('CORS error: Backend server CORS configuration issue');
        }
        
        throw error;
    }
}

// User API
const UserAPI = {
    register: async (userData) => {
        return apiRequest('/register', {
            method: 'POST',
            body: JSON.stringify(userData),
        });
    },
    
    login: async (username, password) => {
        return apiRequest('/login', {
            method: 'POST',
            body: JSON.stringify({ username, password }),
        });
    },
    
    logout: async () => {
        return apiRequest('/logout', {
            method: 'POST',
        });
    },
    
    getProfile: async () => {
        const response = await apiRequest('/user/profile');
        // Backend wraps profile in 'profile' key, unwrap it for frontend
        return response.profile || response;
    },
    
    updateProfile: async (userData) => {
        return apiRequest('/user/profile', {
            method: 'PUT',
            body: JSON.stringify(userData),
        });
    },

    // Password management
    forgotPassword: async (identifier, type = 'email') => {
        const body = type === 'phone' ? { phone: identifier } : { email: identifier };
        return apiRequest('/forgot-password', {
            method: 'POST',
            body: JSON.stringify(body),
        });
    },

    resetPassword: async (identifier, token, newPassword, type = 'email') => {
        const body = {
            token,
            new_password: newPassword
        };
        if (type === 'phone') {
            body.phone = identifier;
        } else {
            body.email = identifier;
        }
        return apiRequest('/reset-password', {
            method: 'POST',
            body: JSON.stringify(body),
        });
    },

    changePassword: async (currentPassword, newPassword) => {
        return apiRequest('/change-password', {
            method: 'POST',
            body: JSON.stringify({
                current_password: currentPassword,
                new_password: newPassword
            }),
        });
    },
};

// Auction API
const AuctionAPI = {
    getAll: async (params = {}) => {
        // Build query string, handling empty params
        const queryParams = new URLSearchParams();
        Object.keys(params).forEach(key => {
            if (params[key] !== null && params[key] !== undefined && params[key] !== '') {
                queryParams.append(key, params[key]);
            }
        });
        const queryString = queryParams.toString();
        const endpoint = queryString ? `/auctions?${queryString}` : '/auctions';
        return apiRequest(endpoint);
    },
    
    getById: async (id) => {
        return apiRequest(`/auctions/${id}`);
    },
    
    create: async (auctionData) => {
        return apiRequest('/auctions', {
            method: 'POST',
            body: JSON.stringify(auctionData),
        });
    },
    
    update: async (id, auctionData) => {
        return apiRequest(`/auctions/${id}`, {
            method: 'PUT',
            body: JSON.stringify(auctionData),
        });
    },
    
    getFeatured: async () => {
        return apiRequest('/featured');
    },
    
    getUserAuctions: async () => {
        return apiRequest('/user/auctions');
    },
};

// Bid API
const BidAPI = {
    getByAuctionId: async (auctionId) => {
        return apiRequest(`/auctions/${auctionId}/bids`);
    },
    
    place: async (auctionId, bidData) => {
        return apiRequest(`/auctions/${auctionId}/bids`, {
            method: 'POST',
            body: JSON.stringify(bidData),
        });
    },
    
    getUserBids: async () => {
        return apiRequest('/user/bids');
    },
};

// Payment API
const PaymentAPI = {
    getPayments: async () => {
        return apiRequest('/user/payments');
    },
    
    processPayment: async (invoiceId, paymentMethod, extraData = {}) => {
        return apiRequest(`/payments/${invoiceId}/pay`, {
            method: 'POST',
            body: JSON.stringify({
                payment_method: paymentMethod,
                ...extraData
            }),
        });
    },
};

// Category API
const CategoryAPI = {
    getAll: async () => {
        return apiRequest('/categories');
    },
};

// Image Upload API
const ImageAPI = {
    upload: async (file, isFeatured = false) => {
        const formData = new FormData();
        formData.append('image', file);
        if (isFeatured) {
            formData.append('is_featured', 'true');
        }
        
        const baseUrl = API_BASE_URL.replace('/api', '');
        const url = `${baseUrl}/api/upload/image`;
        
        // Get CSRF token for the request
        if (!csrfToken) {
            await fetchCSRFToken();
        }
        
        const headers = {};
        if (csrfToken) {
            headers['X-CSRFToken'] = csrfToken;
        }
        
        const response = await fetch(url, {
            method: 'POST',
            headers,
            credentials: 'include',
            body: formData,
        });
        
        if (!response.ok) {
            const error = await response.json().catch(() => ({ error: 'Upload failed' }));
            throw new Error(error.error || 'Failed to upload image');
        }
        
        return await response.json();
    },
};

// Video Upload API
const VideoAPI = {
    upload: async (file) => {
        const formData = new FormData();
        formData.append('video', file);
        
        const baseUrl = API_BASE_URL.replace('/api', '');
        const url = `${baseUrl}/api/upload/video`;
        
        // Get CSRF token for the request
        if (!csrfToken) {
            await fetchCSRFToken();
        }
        
        const headers = {};
        if (csrfToken) {
            headers['X-CSRFToken'] = csrfToken;
        }
        
        const response = await fetch(url, {
            method: 'POST',
            headers,
            credentials: 'include',
            body: formData,
        });
        
        if (!response.ok) {
            const error = await response.json().catch(() => ({ error: 'Upload failed' }));
            throw new Error(error.error || 'Failed to upload video');
        }
        
        return await response.json();
    },
};

// Return Request API
const ReturnRequestAPI = {
    getAll: async () => {
        return apiRequest('/return-requests');
    },
    
    getById: async (id) => {
        return apiRequest(`/return-requests/${id}`);
    },
    
    create: async (returnData) => {
        return apiRequest('/return-requests', {
            method: 'POST',
            body: JSON.stringify(returnData),
        });
    },
    
    cancel: async (id) => {
        return apiRequest(`/return-requests/${id}/cancel`, {
            method: 'POST',
        });
    },
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { UserAPI, AuctionAPI, BidAPI, CategoryAPI, PaymentAPI, ImageAPI, VideoAPI, ReturnRequestAPI };
}

