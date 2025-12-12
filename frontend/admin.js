// Admin Portal JavaScript
let currentAdmin = null;

// Check if user is admin on page load
document.addEventListener('DOMContentLoaded', async () => {
	    // Add a delay to ensure session is properly established
	    // This is important for cross-origin requests with credentials
	    await new Promise(resolve => setTimeout(resolve, 500));

	    await checkAdminAuth();

	    // Load dashboard stats if on dashboard
	    if (window.location.pathname.includes('admin.html') || window.location.pathname === '/admin.html' || window.location.pathname.includes('index.html')) {
	        await loadAdminStats();
	    }
});

// Check admin authentication
async function checkAdminAuth() {
    try {
        console.log('Checking admin authentication...');
        const response = await UserAPI.getProfile();
        console.log('Profile response:', response);

        if (!response) {
            console.error('No response from profile endpoint');
            showToast('Please login to access admin portal', 'error');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
            return;
        }

        if (response.role !== 'admin') {
            console.error('User role is not admin:', response.role);
            showToast('Access denied. Admin privileges required.', 'error');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
            return;
        }

        console.log('Admin authentication successful');
        currentAdmin = response;

        // Update nav
        const adminUserName = document.getElementById('adminUserName');
        if (adminUserName) {
            adminUserName.textContent = response.username;
        }

	        const adminAvatar = document.getElementById('adminAvatar');
	        if (adminAvatar && response.username) {
	            adminAvatar.textContent = (response.username[0] || 'A').toUpperCase();
	        }
    } catch (error) {
        console.error('Admin auth error:', error);
        console.error('Error message:', error.message);
        console.error('Error status:', error.status);

        // Check if it's an authentication error
        if (error.status === 401 || error.message.includes('Authentication required')) {
            showToast('Please login to access admin portal', 'error');
        } else {
            showToast('Error checking admin privileges: ' + error.message, 'error');
        }

        setTimeout(() => {
            window.location.href = 'index.html';
        }, 2000);
    }
}

// Toast notification
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    if (toast) {
        toast.textContent = message;
        toast.className = `toast ${type}`;
        toast.style.display = 'block';
        setTimeout(() => {
            toast.style.display = 'none';
        }, 3000);
    }
}

// Load admin dashboard stats
async function loadAdminStats() {
    try {
	        const data = await AdminAPI.getStats();
	        
        // Update stat cards
        document.getElementById('totalUsers').textContent = data.total_users || 0;
        document.getElementById('totalAdmins').textContent = data.total_admins || 0;
        document.getElementById('totalAuctions').textContent = data.total_auctions || 0;
        document.getElementById('activeAuctions').textContent = data.active_auctions || 0;
	        document.getElementById('endedAuctions').textContent = data.ended_auctions || 0;
	        document.getElementById('totalBids').textContent = data.total_bids || 0;
	        document.getElementById('recentUsers').textContent = data.recent_users || 0;

	        // Reflect recent user activity in header badge (simple, clean)
	        const notifBadge = document.querySelector('.admin-notification-btn .badge');
	        if (notifBadge && typeof data.recent_users !== 'undefined') {
	            notifBadge.textContent = String(data.recent_users);
	        }
    } catch (error) {
        console.error('Error loading stats:', error);
        showToast('Error loading dashboard statistics', 'error');
	    }
	}

// Logout
async function logout() {
    try {
        await UserAPI.logout();
        window.location.href = 'index.html';
    } catch (error) {
        showToast('Logout failed', 'error');
    }
}

// Admin API helpers
const AdminAPI = {
    getApiBase: () => {
        return window.API_BASE || (window.location.hostname === 'localhost' ? 'http://localhost:5000' : window.location.origin);
    },
    
    getUsers: async (page = 1, search = '') => {
        const params = new URLSearchParams({ page, per_page: 20 });
        if (search) params.append('search', search);
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/users?${params}`, {
            credentials: 'include'
        });
        if (!response.ok) throw new Error('Failed to fetch users');
        return response.json();
    },
    
    updateUser: async (userId, data) => {
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/users/${userId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify(data)
        });
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to update user');
        }
        return response.json();
    },
    
    deleteUser: async (userId) => {
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/users/${userId}`, {
            method: 'DELETE',
            credentials: 'include'
        });
        if (!response.ok) {
            // Check if response is JSON before trying to parse
            const contentType = response.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                const error = await response.json();
                throw new Error(error.error || 'Failed to delete user');
            } else {
                // If response is HTML (error page), extract status text
                throw new Error(`Failed to delete user: ${response.status} ${response.statusText}`);
            }
        }
        // Check if response has content before parsing
        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
            return response.json();
        } else {
            // If no JSON content, return success message
            return { message: 'User deleted successfully' };
        }
    },
    
    getAuctions: async (page = 1, status = '') => {
        const params = new URLSearchParams({ page, per_page: 20 });
        if (status) params.append('status', status);
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/auctions?${params}`, {
            credentials: 'include'
        });
        if (!response.ok) throw new Error('Failed to fetch auctions');
        return response.json();
    },
    
    updateAuction: async (auctionId, data) => {
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/auctions/${auctionId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify(data)
        });
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to update auction');
        }
        return response.json();
    },
    
    deleteAuction: async (auctionId) => {
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/auctions/${auctionId}`, {
            method: 'DELETE',
            credentials: 'include'
        });
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to delete auction');
        }
        return response.json();
    },
    
    getStats: async () => {
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/stats`, {
            credentials: 'include'
        });
        if (!response.ok) throw new Error('Failed to fetch stats');
        return response.json();
    },
    
    getUserDetails: async (userId) => {
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/users/${userId}`, {
            credentials: 'include'
        });
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to fetch user details');
        }
        return response.json();
    }
};

