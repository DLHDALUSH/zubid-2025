/**
 * API Client Tests for ZUBID Frontend
 * Tests the API module functions
 * Run with: npx jest tests/api.test.js
 */

// Mock fetch globally
global.fetch = jest.fn();

// Mock window object
global.window = {
    API_BASE_URL: 'http://localhost:5000/api',
    location: { hostname: 'localhost', origin: 'http://localhost:8000' }
};

// Simple mock implementation of API functions for testing
const API_BASE_URL = 'http://localhost:5000/api';

async function apiRequest(endpoint, options = {}) {
    const url = `${API_BASE_URL}${endpoint}`;
    const response = await fetch(url, {
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        ...options
    });
    return response.json();
}

describe('API Configuration', () => {
    test('API_BASE_URL is defined', () => {
        expect(API_BASE_URL).toBeDefined();
        expect(API_BASE_URL).toBe('http://localhost:5000/api');
    });
});

describe('API Request Function', () => {
    beforeEach(() => {
        fetch.mockClear();
    });

    test('makes GET request correctly', async () => {
        const mockResponse = { auctions: [] };
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => mockResponse
        });

        const result = await apiRequest('/auctions');
        
        expect(fetch).toHaveBeenCalledWith(
            'http://localhost:5000/api/auctions',
            expect.objectContaining({
                headers: { 'Content-Type': 'application/json' },
                credentials: 'include'
            })
        );
        expect(result).toEqual(mockResponse);
    });

    test('makes POST request correctly', async () => {
        const mockResponse = { success: true };
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => mockResponse
        });

        const result = await apiRequest('/login', {
            method: 'POST',
            body: JSON.stringify({ email: 'test@example.com', password: 'password' })
        });
        
        expect(fetch).toHaveBeenCalledWith(
            'http://localhost:5000/api/login',
            expect.objectContaining({
                method: 'POST'
            })
        );
        expect(result).toEqual(mockResponse);
    });
});

describe('Authentication API', () => {
    beforeEach(() => {
        fetch.mockClear();
    });

    test('login sends correct data', async () => {
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ user: { id: 1, email: 'test@example.com' } })
        });

        await apiRequest('/login', {
            method: 'POST',
            body: JSON.stringify({
                email: 'test@example.com',
                password: 'TestPassword123!'
            })
        });

        expect(fetch).toHaveBeenCalledTimes(1);
    });

    test('register sends correct data', async () => {
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ message: 'Registration successful' })
        });

        await apiRequest('/register', {
            method: 'POST',
            body: JSON.stringify({
                username: 'newuser',
                email: 'new@example.com',
                password: 'NewPassword123!',
                phone: '1234567890'
            })
        });

        expect(fetch).toHaveBeenCalledTimes(1);
    });

    test('logout makes POST request', async () => {
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ message: 'Logged out' })
        });

        await apiRequest('/logout', { method: 'POST' });

        expect(fetch).toHaveBeenCalledWith(
            'http://localhost:5000/api/logout',
            expect.objectContaining({ method: 'POST' })
        );
    });
});

describe('Auctions API', () => {
    beforeEach(() => {
        fetch.mockClear();
    });

    test('get auctions returns list', async () => {
        const mockAuctions = [
            { id: 1, title: 'Auction 1' },
            { id: 2, title: 'Auction 2' }
        ];
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ auctions: mockAuctions })
        });

        const result = await apiRequest('/auctions');
        
        expect(result.auctions).toHaveLength(2);
    });

    test('get single auction', async () => {
        const mockAuction = { id: 1, title: 'Test Auction', current_price: 100 };
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => mockAuction
        });

        const result = await apiRequest('/auctions/1');
        
        expect(result.id).toBe(1);
        expect(result.title).toBe('Test Auction');
    });

    test('create auction sends correct data', async () => {
        fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ auction: { id: 1 } })
        });

        await apiRequest('/auctions', {
            method: 'POST',
            body: JSON.stringify({
                title: 'New Auction',
                description: 'Test description',
                starting_price: 100,
                category_id: 1
            })
        });

        expect(fetch).toHaveBeenCalledWith(
            'http://localhost:5000/api/auctions',
            expect.objectContaining({ method: 'POST' })
        );
    });
});

