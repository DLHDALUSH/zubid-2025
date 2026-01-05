// ZUBID Frontend Configuration
// Flexible environment-based configuration system
// Include this file BEFORE api.js in your HTML files

(function() {
    'use strict';

    // ============================================================
    // 🔧 ENVIRONMENT CONFIGURATION
    // ============================================================
    
    // Environment can be set via:
    // 1. URL parameter: ?env=development
    // 2. localStorage: localStorage.setItem('ZUBID_ENV', 'development')
    // 3. window.ZUBID_ENV before loading this script
    // 4. Auto-detection based on hostname
    
    const urlParams = new URLSearchParams(window.location.search);
    const envFromUrl = urlParams.get('env');
    const envFromStorage = localStorage.getItem('ZUBID_ENV');
    const envFromWindow = window.ZUBID_ENV;
    
    // Determine environment
    let environment = envFromUrl || envFromStorage || envFromWindow;
    
    // Auto-detect if not explicitly set
    if (!environment) {
        const hostname = window.location.hostname;
        if (hostname === 'localhost' || hostname === '127.0.0.1' || hostname === '10.0.2.2') {
            environment = 'development';
        } else if (hostname === 'zubid-2025.onrender.com') {
            environment = 'production';
        } else if (hostname === 'zubidauction.duckdns.org') {
            environment = 'production-alt';
        } else if (hostname.includes('staging') || hostname.includes('test')) {
            environment = 'staging';
        } else {
            environment = 'production'; // Default to production for safety
        }
    }
    
    // Save environment to localStorage for persistence
    if (envFromUrl) {
        localStorage.setItem('ZUBID_ENV', envFromUrl);
    }
    
    // ============================================================
    // 📝 ENVIRONMENT CONFIGURATIONS
    // ============================================================
    
    const environments = {
        development: {
            name: 'Development',
            apiUrl: 'http://localhost:5000/api',
            baseUrl: 'http://localhost:5000',
            wsUrl: 'ws://localhost:5000',
            debug: true,
            enableLogs: true,
            enablePerformanceMetrics: true,
            apiTimeout: 60000, // 60 seconds for debugging
        },

        staging: {
            name: 'Staging',
            apiUrl: 'https://staging.zubidauction.com/api',
            baseUrl: 'https://staging.zubidauction.com',
            wsUrl: 'wss://staging.zubidauction.com',
            debug: true,
            enableLogs: true,
            enablePerformanceMetrics: true,
            apiTimeout: 30000,
        },

        production: {
            name: 'Production (Render)',
            apiUrl: 'https://zubid-2025.onrender.com/api',
            baseUrl: 'https://zubid-2025.onrender.com',
            wsUrl: 'wss://zubid-2025.onrender.com',
            debug: false,
            enableLogs: false,
            enablePerformanceMetrics: false,
            apiTimeout: 30000,
        },

        'production-alt': {
            name: 'Production (DuckDNS)',
            apiUrl: 'https://zubidauction.duckdns.org/api',
            baseUrl: 'https://zubidauction.duckdns.org',
            wsUrl: 'wss://zubidauction.duckdns.org',
            debug: false,
            enableLogs: false,
            enablePerformanceMetrics: false,
            apiTimeout: 30000,
        }
    };
    
    // Get configuration for current environment
    const config = environments[environment] || environments.production;
    
    // Allow URL parameter overrides for API URL (useful for testing)
    const apiUrlOverride = urlParams.get('api_url');
    if (apiUrlOverride) {
        config.apiUrl = apiUrlOverride + '/api';
        config.baseUrl = apiUrlOverride;
        config.debug = true;
        console.warn('API URL overridden via URL parameter:', apiUrlOverride);
    }
    
    // ============================================================
    // 🌐 GLOBAL CONFIGURATION
    // ============================================================
    
    // Detect platform
    const isCapacitor = typeof window.Capacitor !== 'undefined';
    const isMobileApp = isCapacitor || window.location.protocol === 'capacitor:';
    const isLocalhost = environment === 'development';
    
    // Set global variables for backward compatibility
    window.API_BASE_URL = config.apiUrl;
    window.API_BASE = config.baseUrl;
    window.DEBUG_MODE = config.debug;
    
    // Comprehensive configuration object
    window.ZUBID_CONFIG = {
        // Environment
        environment: environment,
        environmentName: config.name,
        
        // API Configuration
        apiUrl: config.apiUrl,
        baseUrl: config.baseUrl,
        wsUrl: config.wsUrl,
        
        // Platform Detection
        isLocalhost: isLocalhost,
        isMobileApp: isMobileApp,
        isCapacitor: isCapacitor,
        isProduction: environment.includes('production'),
        isStaging: environment === 'staging',
        isDevelopment: environment === 'development',
        
        // Feature Flags
        debug: config.debug,
        enableDebugLogs: config.enableLogs,
        enablePerformanceMetrics: config.enablePerformanceMetrics,
        
        // Timeouts (in milliseconds)
        apiTimeout: config.apiTimeout,
        refreshInterval: 30000,
        
        // Image settings
        maxImageSize: 5 * 1024 * 1024, // 5MB
        maxVideoSize: 50 * 1024 * 1024, // 50MB
        allowedImageTypes: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        
        // Pagination
        defaultPageSize: 12,
        maxPageSize: 50,
        
        // App info
        appVersion: '1.0.0',
        appName: 'ZUBID',
        
        // Helper Methods
        switchEnvironment: function(newEnv) {
            if (environments[newEnv]) {
                localStorage.setItem('ZUBID_ENV', newEnv);
                window.location.reload();
            } else {
                console.error('Invalid environment:', newEnv);
                console.log('Available environments:', Object.keys(environments));
            }
        }
    };
    
    // Log configuration in debug mode
    if (config.debug) {
        console.log('%c🔧 ZUBID Configuration Loaded', 'color: #4CAF50; font-weight: bold; font-size: 14px;');
        console.table({
            'Environment': config.name,
            'API URL': config.apiUrl,
            'Base URL': config.baseUrl,
            'WebSocket URL': config.wsUrl,
            'Debug Mode': config.debug,
            'Platform': isMobileApp ? 'Mobile App' : 'Web Browser'
        });
        console.log('%cTo switch environment, use: ZUBID_CONFIG.switchEnvironment("development")', 'color: #2196F3; font-style: italic;');
        console.log('%cOr add URL parameter: ?env=development', 'color: #2196F3; font-style: italic;');
    }
    
})();

