const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const method = req.method;
    
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', 'http://localhost:8000');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    if (method === 'GET' && parsedUrl.pathname === '/api/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', message: 'Backend is running' }));
        
    } else if (method === 'GET' && parsedUrl.pathname === '/api/csrf-token') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ csrf_token: 'test-token-123' }));
        
    } else if (method === 'POST' && parsedUrl.pathname === '/api/login') {
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                console.log('Login attempt:', data);
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    success: true,
                    message: 'Login successful!',
                    user: {
                        id: 1,
                        username: data.username || 'testuser',
                        email: data.email || 'test@example.com'
                    }
                }));
            } catch (e) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: false, message: 'Invalid JSON' }));
            }
        });
        
    } else if (method === 'POST' && parsedUrl.pathname === '/api/register') {
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                console.log('Registration attempt:', data);
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    success: true,
                    message: 'Registration successful!',
                    user: {
                        id: 1,
                        username: data.username || 'testuser',
                        email: data.email || 'test@example.com'
                    }
                }));
            } catch (e) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: false, message: 'Invalid JSON' }));
            }
        });
        
    } else if (method === 'POST' && parsedUrl.pathname === '/api/logout') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, message: 'Logged out successfully' }));
        
    } else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Not found' }));
    }
});

const PORT = 5003;
server.listen(PORT, 'localhost', () => {
    console.log(`ZUBID backend server running on http://localhost:${PORT}`);
    console.log('CORS enabled for: http://localhost:8000');
});
