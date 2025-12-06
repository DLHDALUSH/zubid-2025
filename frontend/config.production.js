// ZUBID Frontend Configuration
// Include this file BEFORE api.js in your HTML files
// Update the PRODUCTION_API_URL below when deploying to production

// ============================================================
// 🔧 PRODUCTION CONFIGURATION - UPDATE THESE VALUES
// ============================================================
const PRODUCTION_API_URL = 'https://your-backend-domain.com/api';
const PRODUCTION_BASE_URL = 'https://your-backend-domain.com';
// ============================================================

// Auto-detect environment
const isLocalhost = window.location.hostname === 'localhost' ||
                    window.location.hostname === '127.0.0.1' ||
                    window.location.hostname === '10.0.2.2';

// Detect if running in Capacitor (mobile app)
const isCapacitor = typeof window.Capacitor !== 'undefined';
const isMobileApp = isCapacitor ||
                    window.location.protocol === 'capacitor:' ||
                    window.location.hostname === 'localhost' && window.location.port === '';

// Set API URL based on environment
if (isMobileApp && !isLocalhost) {
    // Mobile app in production mode
    window.API_BASE_URL = PRODUCTION_API_URL;
    window.API_BASE = PRODUCTION_BASE_URL;
} else if (isLocalhost) {
    // Development mode (local or emulator)
    window.API_BASE_URL = 'http://localhost:5000/api';
    window.API_BASE = 'http://localhost:5000';
} else {
    // Web browser production
    window.API_BASE_URL = PRODUCTION_API_URL;
    window.API_BASE = PRODUCTION_BASE_URL;
}

// Debug mode - disable in production
window.DEBUG_MODE = isLocalhost;

// Configuration settings
window.ZUBID_CONFIG = {
    // API Configuration
    apiUrl: window.API_BASE_URL,
    baseUrl: window.API_BASE,

    // Environment info
    isLocalhost: isLocalhost,
    isMobileApp: isMobileApp,
    isCapacitor: isCapacitor,

    // Feature flags
    enableDebugLogs: isLocalhost,
    enablePerformanceMetrics: false,

    // Timeouts (in milliseconds)
    apiTimeout: 30000,
    refreshInterval: 30000,

    // Image settings
    maxImageSize: 5 * 1024 * 1024, // 5MB
    maxVideoSize: 50 * 1024 * 1024, // 50MB

    // Pagination
    defaultPageSize: 12,
    maxPageSize: 50,

    // App info
    appVersion: '1.0.0',
    appName: 'ZUBID'
};

if (window.DEBUG_MODE) {
    console.log('ZUBID Config Loaded:', {
        apiUrl: window.API_BASE_URL,
        baseUrl: window.API_BASE,
        isLocalhost: isLocalhost,
        isMobileApp: isMobileApp,
        isCapacitor: isCapacitor
    });
}

