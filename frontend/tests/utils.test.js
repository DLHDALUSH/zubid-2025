/**
 * Utility Functions Tests for ZUBID Frontend
 * Tests utility and helper functions
 * Run with: npx jest tests/utils.test.js
 */

describe('Image URL Utilities', () => {
    const API_BASE = 'http://localhost:5000';
    
    function getFullImageUrl(imageUrl) {
        if (!imageUrl) return null;
        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://') || imageUrl.startsWith('data:')) {
            return imageUrl;
        }
        return API_BASE + (imageUrl.startsWith('/') ? imageUrl : '/' + imageUrl);
    }

    test('returns null for empty input', () => {
        expect(getFullImageUrl(null)).toBeNull();
        expect(getFullImageUrl(undefined)).toBeNull();
        expect(getFullImageUrl('')).toBeNull();
    });

    test('returns unchanged for absolute URLs', () => {
        const httpUrl = 'http://example.com/image.jpg';
        const httpsUrl = 'https://example.com/image.jpg';
        
        expect(getFullImageUrl(httpUrl)).toBe(httpUrl);
        expect(getFullImageUrl(httpsUrl)).toBe(httpsUrl);
    });

    test('returns unchanged for data URLs', () => {
        const dataUrl = 'data:image/png;base64,iVBORw0KGgo...';
        expect(getFullImageUrl(dataUrl)).toBe(dataUrl);
    });

    test('prepends API_BASE for relative URLs', () => {
        expect(getFullImageUrl('/uploads/image.jpg')).toBe('http://localhost:5000/uploads/image.jpg');
        expect(getFullImageUrl('uploads/image.jpg')).toBe('http://localhost:5000/uploads/image.jpg');
    });
});

describe('Price Formatting', () => {
    function formatPrice(price, currency = 'IQD') {
        if (typeof price !== 'number') {
            price = parseFloat(price) || 0;
        }
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: currency,
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(price);
    }

    test('formats number correctly', () => {
        const result = formatPrice(1000);
        expect(result).toContain('1,000');
    });

    test('handles string input', () => {
        const result = formatPrice('500');
        expect(result).toContain('500');
    });

    test('handles invalid input', () => {
        const result = formatPrice('invalid');
        expect(result).toContain('0');
    });
});

describe('Date Formatting', () => {
    function formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }

    function formatDateTime(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        return date.toLocaleString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    test('formats date correctly', () => {
        const result = formatDate('2025-01-05T12:00:00Z');
        expect(result).toContain('2025');
        expect(result).toContain('Jan');
    });

    test('formats datetime correctly', () => {
        const result = formatDateTime('2025-01-05T12:00:00Z');
        expect(result).toContain('2025');
    });

    test('handles empty input', () => {
        expect(formatDate('')).toBe('');
        expect(formatDate(null)).toBe('');
    });
});

describe('Time Remaining Calculation', () => {
    function getTimeRemaining(endTime) {
        const end = new Date(endTime).getTime();
        const now = Date.now();
        const diff = end - now;

        if (diff <= 0) {
            return { days: 0, hours: 0, minutes: 0, seconds: 0, expired: true };
        }

        const days = Math.floor(diff / (1000 * 60 * 60 * 24));
        const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diff % (1000 * 60)) / 1000);

        return { days, hours, minutes, seconds, expired: false };
    }

    test('returns correct time for future date', () => {
        const futureDate = new Date(Date.now() + 86400000); // +1 day
        const result = getTimeRemaining(futureDate.toISOString());
        
        expect(result.expired).toBe(false);
        expect(result.days).toBeGreaterThanOrEqual(0);
    });

    test('returns expired for past date', () => {
        const pastDate = new Date(Date.now() - 86400000); // -1 day
        const result = getTimeRemaining(pastDate.toISOString());
        
        expect(result.expired).toBe(true);
    });
});

describe('Validation Utilities', () => {
    function isValidEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }

    function isValidPhone(phone) {
        const re = /^[\d\s\-\+\(\)]{7,20}$/;
        return re.test(phone);
    }

    function isValidPassword(password) {
        return password && password.length >= 8;
    }

    test('validates email correctly', () => {
        expect(isValidEmail('test@example.com')).toBe(true);
        expect(isValidEmail('invalid')).toBe(false);
        expect(isValidEmail('missing@domain')).toBe(false);
    });

    test('validates phone correctly', () => {
        expect(isValidPhone('1234567890')).toBe(true);
        expect(isValidPhone('+1 (234) 567-8900')).toBe(true);
        expect(isValidPhone('123')).toBe(false);
    });

    test('validates password correctly', () => {
        expect(isValidPassword('Password123!')).toBe(true);
        expect(isValidPassword('short')).toBe(false);
        expect(isValidPassword('')).toBe(false);
    });
});

describe('String Utilities', () => {
    function truncate(str, maxLength) {
        if (!str) return '';
        if (str.length <= maxLength) return str;
        return str.substring(0, maxLength - 3) + '...';
    }

    function capitalize(str) {
        if (!str) return '';
        return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
    }

    test('truncates long strings', () => {
        expect(truncate('Hello World', 8)).toBe('Hello...');
        expect(truncate('Short', 10)).toBe('Short');
    });

    test('capitalizes strings', () => {
        expect(capitalize('hello')).toBe('Hello');
        expect(capitalize('WORLD')).toBe('World');
    });
});

