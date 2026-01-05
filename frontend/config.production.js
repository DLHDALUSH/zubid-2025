// ZUBID Frontend Configuration
// Include this file BEFORE api.js in your HTML files
// Update the PRODUCTION_API_URL below when deploying to production

// ============================================================
// 🔧 PRODUCTION CONFIGURATION
// ============================================================
// Backend uses /api routes (not versioned)
const DUCKDNS_API_URL = 'https://zubidauction.duckdns.org/api';
const DUCKDNS_BASE_URL = 'https://zubidauction.duckdns.org';
const RENDER_API_URL = 'https://zubid-2025.onrender.com/api';
const RENDER_BASE_URL = 'https://zubid-2025.onrender.com';
// ============================================================

// Auto-detect environment
const isLocalhost = window.location.hostname === 'localhost' ||
                    window.location.hostname === '127.0.0.1' ||
                    window.location.hostname === '10.0.2.2';

const isRenderServer = window.location.hostname === 'zubid-2025.onrender.com';
const isDuckDNSServer = window.location.hostname === 'zubidauction.duckdns.org';

// Detect if running in Capacitor (mobile app)
const isCapacitor = typeof window.Capacitor !== 'undefined';
const isMobileApp = isCapacitor ||
                    window.location.protocol === 'capacitor:' ||
                    window.location.hostname === 'localhost' && window.location.port === '';

// Set API URL based on environment
if (isMobileApp && !isLocalhost) {
    // Mobile app in production mode - use DuckDNS as primary
    window.API_BASE_URL = DUCKDNS_API_URL;
    window.API_BASE = DUCKDNS_BASE_URL;
} else if (isLocalhost) {
    // Local development mode
    window.API_BASE_URL = 'http://localhost:5000/api';
    window.API_BASE = 'http://localhost:5000';
} else if (isRenderServer) {
    // Render.com Server
    window.API_BASE_URL = RENDER_API_URL;
    window.API_BASE = RENDER_BASE_URL;
} else if (isDuckDNSServer) {
    // DuckDNS Server
    window.API_BASE_URL = DUCKDNS_API_URL;
    window.API_BASE = DUCKDNS_BASE_URL;
} else {
    // Default to DuckDNS
    window.API_BASE_URL = DUCKDNS_API_URL;
    window.API_BASE = DUCKDNS_BASE_URL;
}

// Debug mode - enable for localhost only
window.DEBUG_MODE = isLocalhost;

// Configuration settings
window.ZUBID_CONFIG = {
    // API Configuration
    apiUrl: window.API_BASE_URL,
    baseUrl: window.API_BASE,

    // Environment info
    isLocalhost: isLocalhost,
    isRenderServer: isRenderServer,
    isDuckDNSServer: isDuckDNSServer,
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
        environment: isRenderServer ? 'PRODUCTION (Render.com)' :
                    isDuckDNSServer ? 'ALTERNATIVE (DuckDNS)' :
                    isLocalhost ? 'LOCAL' : 'UNKNOWN',
        apiUrl: window.API_BASE_URL,
        baseUrl: window.API_BASE,
        isLocalhost: isLocalhost,
        isRenderServer: isRenderServer,
        isDuckDNSServer: isDuckDNSServer,
        isMobileApp: isMobileApp,
        isCapacitor: isCapacitor
    });
}

