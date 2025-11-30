// Utility functions for security and common operations

// HTML sanitization to prevent XSS attacks
// Escapes HTML special characters
function escapeHtml(text) {
    if (text == null) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Sanitize HTML string (basic version - for production, use DOMPurify library)
function sanitizeHtml(html) {
    if (!html) return '';
    // Create a temporary element to parse and sanitize
    const temp = document.createElement('div');
    temp.textContent = html; // This automatically escapes HTML
    return temp.innerHTML;
}

// Safe innerHTML setter that escapes user input
// WARNING: This function name is misleading - it does NOT escape HTML
// Use setSafeText() instead for user input, or escapeHtml() before calling this
function setSafeHtml(element, html) {
    if (!element) return;
    // Only use this for trusted HTML content
    // For user input, use setSafeText() or escapeHtml() first
    element.innerHTML = html;
}

// Safe innerHTML setter that escapes user input before setting
function setSafeText(element, text) {
    if (!element) return;
    element.textContent = text; // textContent automatically escapes
}

// Create safe HTML from template with escaped values
function createSafeHtml(template, values) {
    let html = template;
    for (const [key, value] of Object.entries(values)) {
        const placeholder = `{{${key}}}`;
        html = html.replace(new RegExp(placeholder, 'g'), escapeHtml(String(value)));
    }
    return html;
}

// Debug logging - only log in development
// Check if DEBUG is already declared to avoid duplicate declaration errors
if (typeof window.DEBUG === 'undefined') {
    window.DEBUG = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
}
const DEBUG = window.DEBUG;

function debugLog(...args) {
    if (DEBUG) {
        console.log(...args);
    }
}

function debugError(...args) {
    if (DEBUG) {
        console.error(...args);
    }
}

function debugWarn(...args) {
    if (DEBUG) {
        console.warn(...args);
    }
}

// Export for use in other files
if (typeof window !== 'undefined') {
    window.utils = {
        escapeHtml,
        sanitizeHtml,
        setSafeHtml,
        setSafeText,
        createSafeHtml,
        debugLog,
        debugError,
        debugWarn
    };
}

