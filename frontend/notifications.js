// 🔔 ZUBID Notifications System
// ==============================

// Basic HTML escaping to prevent XSS in notification content
function escapeNotificationHtml(text) {
    if (text == null) return '';
    const div = document.createElement('div');
    div.textContent = String(text);
    return div.innerHTML;
}

const NotificationManager = {
    STORAGE_KEY: 'zubid-notifications',
    notifications: [],
    unreadCount: 0,

    init() {
        this.loadNotifications();
        this.setupEventListeners();
        this.updateBadge();
        
        // Check for new notifications periodically (every 30 seconds)
        setInterval(() => this.checkForNewNotifications(), 30000);
        
        // Initial check
        this.checkForNewNotifications();
    },

    loadNotifications() {
        const saved = localStorage.getItem(this.STORAGE_KEY);
        if (saved) {
            this.notifications = JSON.parse(saved);
        } else {
            // Initialize with some sample notifications
            this.notifications = this.getSampleNotifications();
            this.saveNotifications();
        }
        this.calculateUnreadCount();
    },

    saveNotifications() {
        localStorage.setItem(this.STORAGE_KEY, JSON.stringify(this.notifications));
    },

    getSampleNotifications() {
        return [
            {
                id: 1,
                type: 'system',
                title: 'Welcome to ZUBID! 🎉',
                message: 'Start exploring auctions and place your first bid.',
                time: new Date().toISOString(),
                read: false
            }
        ];
    },

    async checkForNewNotifications() {
        // Check if user is logged in via global currentUser
        if (!window.currentUser && typeof currentUser === 'undefined') return;
        
        try {
            // Fetch notifications from API using session cookies
            const response = await fetch('/api/notifications', {
                headers: { 'Accept': 'application/json' }
            });
            
            if (response.ok) {
                const data = await response.json();
                // API returns array directly
                const notificationsList = Array.isArray(data) ? data : (data.notifications || []);
                
                if (notificationsList && notificationsList.length > 0) {
                    // Add new notifications
                    notificationsList.forEach(n => {
                        // Handle both backend field names (timestamp, isRead) and frontend expectations
                        const formattedNotif = {
                            id: n.id,
                            title: n.title,
                            message: n.message,
                            time: n.timestamp ? new Date(n.timestamp).toISOString() : new Date().toISOString(),
                            type: n.type || 'system',
                            read: n.isRead !== undefined ? n.isRead : !!n.read
                        };
                        
                        if (!this.notifications.find(existing => String(existing.id) === String(formattedNotif.id))) {
                            this.notifications.unshift(formattedNotif);
                        }
                    });
                    this.saveNotifications();
                    this.calculateUnreadCount();
                    this.updateBadge();
                    this.renderNotifications();
                }
            }
        } catch (error) {
            // API not available or error, fail silently
            console.debug('Notification fetch failed:', error);
        }
    },

    calculateUnreadCount() {
        this.unreadCount = this.notifications.filter(n => !n.read).length;
    },

    updateBadge() {
        const badges = document.querySelectorAll('.notification-badge');
        badges.forEach(badge => {
            badge.textContent = this.unreadCount > 99 ? '99+' : this.unreadCount;
            badge.setAttribute('data-count', this.unreadCount);
        });
    },

	    setupEventListeners() {
	        // Toggle dropdown (support multiple navbars if present)
	        document.addEventListener('click', (e) => {
	            const btn = e.target.closest('.notifications-btn');
	            const wrapper = btn ? btn.closest('.notifications-wrapper') : null;
	            const dropdown = wrapper ? wrapper.querySelector('.notifications-dropdown') : document.querySelector('.notifications-dropdown');

	            // Close any open dropdowns when clicking outside
	            const allDropdowns = document.querySelectorAll('.notifications-dropdown');
	            if (!btn && !e.target.closest('.notifications-dropdown')) {
	                allDropdowns.forEach(d => d.classList.remove('active'));
	                return;
	            }

	            if (btn && dropdown) {
	                e.stopPropagation();
	                const isActive = dropdown.classList.contains('active');
	                allDropdowns.forEach(d => d.classList.remove('active'));
	                if (!isActive) {
	                    dropdown.classList.add('active');
	                    this.renderNotifications();
	                }
	            }
	        });

	        // Mark all as read
	        document.addEventListener('click', (e) => {
	            if (e.target.closest('.mark-all-read-btn')) {
	                this.markAllAsRead();
	            }
	        });
	    },

    renderNotifications() {
        const list = document.querySelector('.notifications-list');
        if (!list) return;

        if (this.notifications.length === 0) {
            list.innerHTML = `
                <div class="notifications-empty">
                    <div class="notifications-empty-icon">🔔</div>
                    <p>No notifications yet</p>
                </div>
            `;
            return;
        }

        list.innerHTML = this.notifications.slice(0, 10).map(n => this.renderNotificationItem(n)).join('');
    },

	    renderNotificationItem(notification) {
	        const icons = { bid: '🏷️', win: '🏆', outbid: '⚠️', payment: '💳', system: '📢' };
	        const typeRaw = notification.type || 'system';
	        const allowedTypes = ['bid', 'win', 'outbid', 'payment', 'system'];
	        const safeTypeClass = allowedTypes.includes(typeRaw) ? typeRaw : 'system';
	        const icon = icons[typeRaw] || '📌';
	        const timeAgo = this.getTimeAgo(new Date(notification.time));
	        const safeTitle = escapeNotificationHtml(notification.title);
	        const safeMessage = escapeNotificationHtml(notification.message);
	        const safeId = Number(notification.id) || 0;

	        return `
	            <div class="notification-item ${notification.read ? '' : 'unread'}" data-id="${safeId}" onclick="NotificationManager.markAsRead(${safeId})">
	                <div class="notification-icon ${safeTypeClass}">${icon}</div>
	                <div class="notification-content">
	                    <div class="notification-title">${safeTitle}</div>
	                    <div class="notification-message">${safeMessage}</div>
	                    <div class="notification-time">${timeAgo}</div>
	                </div>
	            </div>
	        `;
	    },

    getTimeAgo(date) {
        const seconds = Math.floor((new Date() - date) / 1000);
        const intervals = { year: 31536000, month: 2592000, week: 604800, day: 86400, hour: 3600, minute: 60 };
        for (const [unit, secondsInUnit] of Object.entries(intervals)) {
            const interval = Math.floor(seconds / secondsInUnit);
            if (interval >= 1) return `${interval} ${unit}${interval > 1 ? 's' : ''} ago`;
        }
        return 'Just now';
    },

    async markAsRead(id) {
        const n = this.notifications.find(n => String(n.id) === String(id));
        if (n && !n.read) {
            n.read = true;
            this.saveNotifications();
            this.calculateUnreadCount();
            this.updateBadge();
            this.renderNotifications();
            
            // Try to notify backend
            try {
                await fetch(`/api/notifications/${id}/read`, {
                    method: 'PUT',
                    headers: { 'Accept': 'application/json' }
                });
            } catch (error) {
                console.debug('Failed to sync notification read status to backend:', error);
            }
        }
    },

    markAllAsRead() {
        this.notifications.forEach(n => n.read = true);
        this.saveNotifications(); this.calculateUnreadCount(); this.updateBadge(); this.renderNotifications();
        if (typeof showToast === 'function') showToast('All notifications marked as read', 'success');
    },

    addNotification(notification) {
        const newNotif = { id: Date.now(), time: new Date().toISOString(), read: false, ...notification };
        this.notifications.unshift(newNotif);
        if (this.notifications.length > 50) this.notifications.pop();
        this.saveNotifications(); this.calculateUnreadCount(); this.updateBadge(); this.renderNotifications();
    }
};

document.addEventListener('DOMContentLoaded', () => NotificationManager.init());
window.NotificationManager = NotificationManager;

