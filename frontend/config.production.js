// ZUBID Frontend Configuration
// Include this file BEFORE api.js in your HTML files
// Update the URLs below when deploying to production

// Auto-detect environment
const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

// Set API URL based on environment
// For production: Change this to your actual API URL (e.g., 'https://api.yourdomain.com/api')
window.API_BASE_URL = isLocalhost
    ? 'http://localhost:5000/api'
    : 'https://api.yourdomain.com/api';

window.API_BASE = window.API_BASE_URL.replace('/api', '');

// Debug mode - disable in production
window.DEBUG_MODE = isLocalhost;

// Configuration settings
window.ZUBID_CONFIG = {
    // API Configuration
    apiUrl: window.API_BASE_URL,
    baseUrl: window.API_BASE,

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
    maxPageSize: 50
};

if (window.DEBUG_MODE) {
    console.log('ZUBID Config Loaded:', {
        apiUrl: window.API_BASE_URL,
        baseUrl: window.API_BASE,
        isLocalhost: isLocalhost
    });
}

