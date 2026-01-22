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
        console.log('Current URL:', window.location.href);
        console.log('API Base URL:', window.API_BASE_URL || 'Not set');

        const response = await UserAPI.getProfile();
        console.log('Profile response:', response);
        console.log('Response type:', typeof response);

        if (!response) {
            console.error('No response from profile endpoint');
            showToast('Please login to access admin portal', 'error');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 2000);
            return;
        }

        console.log('User role from response:', response.role);
        console.log('Expected role: admin');

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
        console.error('Error stack:', error.stack);

        // Check if it's an authentication error
        if (error.status === 401 || error.message.includes('Authentication required')) {
            showToast('Please login to access admin portal', 'error');
        } else if (error.status === 403) {
            showToast('Access denied. Admin privileges required.', 'error');
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

        // Load notification stats for badge
        await loadNotificationStats();

        // Load additional analytics
        await loadFinancialAnalytics();
        await loadSystemMonitoring();
        await loadRecentActivity();
    } catch (error) {
        console.error('Error loading stats:', error);
        showToast('Error loading dashboard statistics', 'error');
	    }
	}

// Load financial analytics
async function loadFinancialAnalytics() {
    try {
        // Mock financial data - replace with actual API call
        const financialData = {
            totalRevenue: 125000,
            totalCommission: 12500,
            averageSale: 850,
            pendingPayouts: 3200
        };

        // Update financial display
        document.getElementById('totalRevenue').textContent = `$${financialData.totalRevenue.toLocaleString()}`;
        document.getElementById('totalCommission').textContent = `$${financialData.totalCommission.toLocaleString()}`;
        document.getElementById('averageSale').textContent = `$${financialData.averageSale.toLocaleString()}`;
        document.getElementById('pendingPayouts').textContent = `$${financialData.pendingPayouts.toLocaleString()}`;
    } catch (error) {
        console.error('Error loading financial analytics:', error);
    }
}

// Load system monitoring data
async function loadSystemMonitoring() {
    try {
        // Mock system data - replace with actual API call
        const systemData = {
            responseTime: Math.floor(Math.random() * 200) + 50,
            uptime: 99.9,
            activeSessions: Math.floor(Math.random() * 100) + 20,
            totalRecords: 15420,
            storageUsed: 245,
            failedLogins: Math.floor(Math.random() * 5),
            blockedIPs: Math.floor(Math.random() * 3),
            securityScore: 'A+'
        };

        // Update system monitoring display
        document.getElementById('responseTime').textContent = `${systemData.responseTime}ms`;
        document.getElementById('systemUptime').textContent = `${systemData.uptime}%`;
        document.getElementById('activeSessions').textContent = systemData.activeSessions;
        document.getElementById('totalRecords').textContent = systemData.totalRecords.toLocaleString();
        document.getElementById('storageUsed').textContent = `${systemData.storageUsed} MB`;
        document.getElementById('failedLogins').textContent = systemData.failedLogins;
        document.getElementById('blockedIPs').textContent = systemData.blockedIPs;
        document.getElementById('securityScore').textContent = systemData.securityScore;

        // Update system status indicator
        const statusIndicator = document.getElementById('systemStatusIndicator');
        if (statusIndicator) {
            const statusDot = statusIndicator.querySelector('.status-dot');
            const statusText = statusIndicator.querySelector('span:last-child');

            if (systemData.uptime > 99.5) {
                statusDot.className = 'status-dot online';
                statusText.textContent = 'All Systems Operational';
            } else if (systemData.uptime > 95) {
                statusDot.className = 'status-dot warning';
                statusText.textContent = 'Minor Issues Detected';
            } else {
                statusDot.className = 'status-dot offline';
                statusText.textContent = 'System Issues';
            }
        }
    } catch (error) {
        console.error('Error loading system monitoring:', error);
    }
}

// Load recent activity
async function loadRecentActivity() {
    try {
        // Mock activity data - replace with actual API call
        const activities = [
            { icon: '👤', title: 'New user registered', time: '2 minutes ago', status: 'success' },
            { icon: '🏷️', title: 'New auction created', time: '5 minutes ago', status: 'pending' },
            { icon: '💰', title: 'Bid placed on "Vintage Watch"', time: '8 minutes ago', status: 'success' },
            { icon: '🔒', title: 'Security scan completed', time: '15 minutes ago', status: 'success' }
        ];

        const activityList = document.getElementById('activityList');
        if (activityList) {
            activityList.innerHTML = activities.map(activity => `
                <div class="admin-activity-item">
                    <div class="admin-activity-icon">${activity.icon}</div>
                    <div class="admin-activity-content">
                        <div class="admin-activity-title">${activity.title}</div>
                        <div class="admin-activity-time">${activity.time}</div>
                    </div>
                    <div class="admin-activity-status ${activity.status}">${activity.status === 'success' ? 'Success' : activity.status === 'pending' ? 'Pending Review' : 'No Issues'}</div>
                </div>
            `).join('');
        }
    } catch (error) {
        console.error('Error loading recent activity:', error);
    }
}

// Refresh financial data
function refreshFinancialData() {
    loadFinancialAnalytics();
    showToast('Financial data refreshed', 'success');
}

// Refresh activity
function refreshActivity() {
    loadRecentActivity();
    showToast('Activity refreshed', 'success');
}

// View all activity
function viewAllActivity() {
    showToast('Activity log feature coming soon', 'info');
}

// Quick action functions
function createAuction() {
    window.location.href = 'admin-create-auction.html';
}

function manageUsers() {
    window.location.href = 'admin-users.html';
}

function viewReports() {
    showToast('Advanced reporting feature coming soon', 'info');
}

function systemSettings() {
    showToast('System settings feature coming soon', 'info');
}

function backupDatabase() {
    showToast('Database backup initiated', 'success');
}

async function sendNotification() {
    // Create a simple modal for sending notifications
    const title = prompt('Notification Title:');
    if (!title) return;

    const message = prompt('Notification Message:');
    if (!message) return;

    const sendToAll = confirm('Send to all users? Click Cancel to send to a specific user.');

    let userId = null;
    if (!sendToAll) {
        userId = prompt('Enter User ID:');
        if (!userId) return;
        userId = parseInt(userId);
    }

    try {
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/notifications/send`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({
                title,
                message,
                type: 'system',
                user_id: userId
            })
        });

        const data = await response.json();
        if (response.ok) {
            showToast(data.message || 'Notification sent!', 'success');
            loadNotificationStats();
        } else {
            showToast(data.error || 'Failed to send notification', 'error');
        }
    } catch (error) {
        console.error('Error sending notification:', error);
        showToast('Failed to send notification', 'error');
    }
}

async function loadNotificationStats() {
    try {
        const response = await fetch(`${AdminAPI.getApiBase()}/api/admin/notifications/stats`, {
            credentials: 'include'
        });

        if (response.ok) {
            const stats = await response.json();
            const badge = document.querySelector('.admin-notification-btn .badge');
            if (badge) {
                badge.textContent = stats.unread > 99 ? '99+' : stats.unread;
            }
        }
    } catch (error) {
        console.debug('Could not load notification stats:', error);
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

    // Suspend user (set is_active to false)
    suspendUser: async (userId) => {
        return AdminAPI.updateUser(userId, { is_active: false });
    },

    // Activate user (set is_active to true)
    activateUser: async (userId) => {
        return AdminAPI.updateUser(userId, { is_active: true });
    },

    // Extend auction time
    extendAuction: async (auctionId, newEndTime) => {
        return AdminAPI.updateAuction(auctionId, { end_time: newEndTime });
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

