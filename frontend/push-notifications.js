// ZUBID Push Notifications Handler
// Uses Capacitor Push Notifications plugin

// Check if running in Capacitor
const isCapacitor = typeof window.Capacitor !== 'undefined';

// Push notification state
let pushNotificationsEnabled = false;
let deviceToken = null;

// Initialize push notifications
async function initPushNotifications() {
    if (!isCapacitor) {
        console.log('Push notifications only work in mobile app');
        return false;
    }

    try {
        const { PushNotifications } = await import('@capacitor/push-notifications');
        
        // Request permission
        const permResult = await PushNotifications.requestPermissions();
        
        if (permResult.receive === 'granted') {
            // Register for push notifications
            await PushNotifications.register();
            
            // Listen for registration success
            PushNotifications.addListener('registration', (token) => {
                console.log('Push registration success, token:', token.value);
                deviceToken = token.value;
                pushNotificationsEnabled = true;
                
                // Send token to backend
                sendTokenToBackend(token.value);
            });

            // Listen for registration errors
            PushNotifications.addListener('registrationError', (error) => {
                console.error('Push registration error:', error);
                pushNotificationsEnabled = false;
            });

            // Listen for push notifications received
            PushNotifications.addListener('pushNotificationReceived', (notification) => {
                console.log('Push notification received:', notification);
                handleNotificationReceived(notification);
            });

            // Listen for notification action (when user taps notification)
            PushNotifications.addListener('pushNotificationActionPerformed', (action) => {
                console.log('Push notification action:', action);
                handleNotificationAction(action);
            });

            return true;
        } else {
            console.log('Push notification permission denied');
            return false;
        }
    } catch (error) {
        console.error('Error initializing push notifications:', error);
        return false;
    }
}

// Send device token to backend
async function sendTokenToBackend(token) {
    try {
        const response = await fetch(`${window.API_BASE_URL}/register-device`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            },
            body: JSON.stringify({
                token: token,
                platform: window.Capacitor?.getPlatform() || 'unknown'
            })
        });
        
        if (response.ok) {
            console.log('Device token registered with backend');
        }
    } catch (error) {
        console.error('Failed to register device token:', error);
    }
}

// Handle received notification (app in foreground)
function handleNotificationReceived(notification) {
    // Show in-app notification
    if (typeof showToast === 'function') {
        showToast(notification.title || 'New Notification', 'info');
    }
    
    // Update notification badge if needed
    updateNotificationBadge();
}

// Handle notification action (user tapped notification)
function handleNotificationAction(action) {
    const data = action.notification.data;
    
    // Navigate based on notification type
    if (data && data.type) {
        switch (data.type) {
            case 'auction_bid':
                window.location.href = `/auction-detail.html?id=${data.auctionId}`;
                break;
            case 'auction_won':
                window.location.href = '/my-bids.html';
                break;
            case 'auction_ending':
                window.location.href = `/auction-detail.html?id=${data.auctionId}`;
                break;
            case 'payment':
                window.location.href = '/payments.html';
                break;
            default:
                window.location.href = '/index.html';
        }
    }
}

// Update notification badge count
async function updateNotificationBadge() {
    if (!isCapacitor) return;
    
    try {
        const { Badge } = await import('@capacitor/badge');
        const count = await getUnreadNotificationCount();
        await Badge.set({ count: count });
    } catch (error) {
        // Badge plugin may not be installed
        console.log('Badge update not available');
    }
}

// Get unread notification count from API
async function getUnreadNotificationCount() {
    try {
        const response = await fetch(`${window.API_BASE_URL}/notifications/unread-count`, {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });
        if (response.ok) {
            const data = await response.json();
            return data.count || 0;
        }
    } catch (error) {
        console.error('Failed to get notification count:', error);
    }
    return 0;
}

// Export functions
window.ZUBID_Push = {
    init: initPushNotifications,
    getToken: () => deviceToken,
    isEnabled: () => pushNotificationsEnabled
};

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initPushNotifications);
} else {
    initPushNotifications();
}

