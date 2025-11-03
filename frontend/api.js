// API Configuration
const API_BASE_URL = 'http://localhost:5000/api';

// Helper function for API requests
async function apiRequest(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;
    const defaultOptions = {
        headers: {
            'Content-Type': 'application/json',
        },
        credentials: 'include', // Include cookies for session
    };

    const config = { ...defaultOptions, ...options };
    
    try {
        const response = await fetch(url, config);
        
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
            throw new Error(data.error || `Request failed with status ${response.status}`);
        }
        
        return data;
    } catch (error) {
        console.error('API Error:', error);
        
        // More specific error messages
        if (error.name === 'TypeError' && error.message.includes('fetch')) {
            throw new Error('Cannot connect to server. Make sure the backend is running on http://localhost:5000');
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
        return apiRequest('/user/profile');
    },
    
    updateProfile: async (userData) => {
        return apiRequest('/user/profile', {
            method: 'PUT',
            body: JSON.stringify(userData),
        });
    },
};

// Auction API
const AuctionAPI = {
    getAll: async (params = {}) => {
        const queryString = new URLSearchParams(params).toString();
        return apiRequest(`/auctions?${queryString}`);
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

// Category API
const CategoryAPI = {
    getAll: async () => {
        return apiRequest('/categories');
    },
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { UserAPI, AuctionAPI, BidAPI, CategoryAPI };
}

