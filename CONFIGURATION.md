# Configuration Guide

This document explains how to configure the ZUBID application for different environments (development and production).

## Backend Configuration

### Environment Variables

The backend now uses environment variables for configuration. Create a `.env` file in the `backend/` directory (you can copy from `backend/env.example`):

```bash
cp backend/env.example backend/.env
```

### Available Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FLASK_ENV` | `development` | Environment mode: `development` or `production` |
| `FLASK_DEBUG` | `False` | Enable debug mode (should be `False` in production) |
| `SECRET_KEY` | `your-secret-key-change-in-production` | **REQUIRED** - Flask secret key for sessions. Generate a strong key for production! |
| `DATABASE_URI` | `sqlite:///auction.db` | Database connection string |
| `CORS_ORIGINS` | `*` | Comma-separated list of allowed origins. Use `*` for development, specific domains for production |
| `HOST` | `127.0.0.1` | Server host address |
| `PORT` | `5000` | Server port |

### Production Configuration Example

```env
FLASK_ENV=production
FLASK_DEBUG=False
SECRET_KEY=your-strong-random-secret-key-here
DATABASE_URI=postgresql://user:password@localhost/zubid_db
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
HOST=0.0.0.0
PORT=5000
```

### Generating a Strong Secret Key

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

Or use an online generator, but make sure it's truly random and secure.

## Frontend Configuration

### API URL Configuration

The frontend API URL can be configured in two ways:

#### Method 1: Global Variable (Recommended)

Add this script tag **before** loading `api.js` in your HTML:

```html
<script>
    window.API_BASE_URL = 'http://your-api-url/api';
</script>
<script src="api.js"></script>
```

#### Method 2: Default

If not configured, it defaults to `http://localhost:5000/api` for local development.

### Production Example

```html
<script>
    window.API_BASE_URL = 'https://api.yourdomain.com/api';
</script>
<script src="api.js"></script>
```

## Security Checklist

Before deploying to production:

- [ ] Change `SECRET_KEY` to a strong random value
- [ ] Set `FLASK_DEBUG=False`
- [ ] Set `FLASK_ENV=production`
- [ ] Configure `CORS_ORIGINS` to specific domains (not `*`)
- [ ] Use a production database (PostgreSQL/MySQL, not SQLite)
- [ ] Configure proper HTTPS/SSL
- [ ] Update frontend API URL to production backend
- [ ] Remove or secure default admin credentials
- [ ] Review and restrict file uploads if any
- [ ] Set up proper logging and monitoring

## Installation

### Backend Dependencies

```bash
cd backend
pip install -r requirements.txt
```

The `python-dotenv` package is now included and will automatically load `.env` files.

### Running the Application

#### Development Mode

```bash
# Backend (defaults to development mode)
cd backend
python app.py

# Or use the batch file
start-backend.bat
```

#### Production Mode

1. Create `.env` file with production settings
2. Set `FLASK_ENV=production` and `FLASK_DEBUG=False`
3. Use a production WSGI server (e.g., gunicorn, uWSGI)

```bash
# Example with gunicorn
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## Troubleshooting

### Backend won't load environment variables

- Make sure `.env` file exists in `backend/` directory
- Check that `python-dotenv` is installed: `pip install python-dotenv`
- Verify file format (no spaces around `=` signs)

### CORS errors in production

- Check `CORS_ORIGINS` includes your frontend domain
- Ensure domains match exactly (including protocol: `http://` vs `https://`)
- Check browser console for specific CORS error messages

### API connection errors

- Verify frontend `API_BASE_URL` matches backend URL
- Check backend is running and accessible
- Verify CORS configuration allows frontend origin

