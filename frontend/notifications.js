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
        // Check if user is logged in
        const token = localStorage.getItem('token');
        if (!token) return;

        try {
            // Fetch notifications from API (if available)
            const response = await fetch('/api/notifications', {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            
            if (response.ok) {
                const data = await response.json();
                if (data.notifications && data.notifications.length > 0) {
                    // Add new notifications
                    data.notifications.forEach(n => {
                        if (!this.notifications.find(existing => existing.id === n.id)) {
                            this.notifications.unshift(n);
                        }
                    });
                    this.saveNotifications();
                    this.calculateUnreadCount();
                    this.updateBadge();
                    this.renderNotifications();
                }
            }
        } catch (error) {
            // API not available, use local notifications
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
        // Toggle dropdown
        document.addEventListener('click', (e) => {
            const btn = e.target.closest('.notifications-btn');
            const dropdown = document.querySelector('.notifications-dropdown');
            
            if (btn && dropdown) {
                e.stopPropagation();
                dropdown.classList.toggle('active');
                this.renderNotifications();
            } else if (dropdown && !e.target.closest('.notifications-dropdown')) {
                dropdown.classList.remove('active');
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
	        const icon = icons[notification.type] || '📌';
	        const timeAgo = this.getTimeAgo(new Date(notification.time));
	        const safeTitle = escapeNotificationHtml(notification.title);
	        const safeMessage = escapeNotificationHtml(notification.message);

	        return `
	            <div class="notification-item ${notification.read ? '' : 'unread'}" data-id="${notification.id}" onclick="NotificationManager.markAsRead(${notification.id})">
	                <div class="notification-icon ${notification.type}">${icon}</div>
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

    markAsRead(id) {
        const n = this.notifications.find(n => n.id === id);
        if (n && !n.read) { n.read = true; this.saveNotifications(); this.calculateUnreadCount(); this.updateBadge(); this.renderNotifications(); }
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

