# Authentication Setup Guide

This guide will help you configure email and Google authentication for the ZUBID app.

## 🔧 Current Status

### ✅ What's Working
- **Forgot Password Backend**: Fully implemented with email/SMS support
- **Google Sign-In Frontend**: Implemented and ready to use
- **Google Auth Backend**: API endpoint created and ready

### ⚠️ What Needs Configuration
- **Email SMTP Settings**: Need real email credentials
- **Google OAuth Credentials**: Need Google Console setup
- **SMS/WhatsApp**: Need Twilio credentials (optional)

## 📧 Email Configuration (Required for Forgot Password)

### Option 1: Gmail (Recommended)
1. **Enable 2-Factor Authentication** on your Gmail account
2. **Create App Password**:
   - Go to [Google Account Settings](https://myaccount.google.com/apppasswords)
   - Generate an App Password for "Mail"
3. **Update `.env` file**:
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASSWORD=your-16-character-app-password
   SMTP_FROM=your-email@gmail.com
   ```

### Option 2: Other Email Providers
```env
# Outlook/Hotmail
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587

# Yahoo
SMTP_HOST=smtp.mail.yahoo.com
SMTP_PORT=587

# Custom SMTP
SMTP_HOST=your-smtp-server.com
SMTP_PORT=587
```

## 🔐 Google Authentication Setup

### 1. Google Cloud Console Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. **Enable Google+ API**:
   - Go to "APIs & Services" > "Library"
   - Search for "Google+ API" and enable it
4. **Create OAuth 2.0 Credentials**:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client IDs"
   - Application type: "Web application"
   - Add authorized redirect URIs:
     - `http://localhost:5000/auth/google/callback`
     - `https://your-domain.com/auth/google/callback`

### 2. Update Backend Configuration
```env
GOOGLE_CLIENT_ID=your-google-client-id.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
```

### 3. Update Flutter Configuration
Update `mobile/flutter_zubid/lib/features/auth/data/repositories/social_auth_repository.dart`:
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: 'your-google-client-id.googleusercontent.com',
);
```

## 📱 SMS/WhatsApp Configuration (Optional)

### Twilio Setup
1. Create account at [Twilio](https://www.twilio.com/)
2. Get your credentials from the Console
3. **Update `.env` file**:
   ```env
   TWILIO_ACCOUNT_SID=your-account-sid
   TWILIO_AUTH_TOKEN=your-auth-token
   TWILIO_PHONE_NUMBER=+1234567890
   ```

## 🚀 Installation Steps

### 1. Install Required Python Packages
```bash
cd backend
pip install google-auth google-auth-oauthlib google-auth-httplib2
pip install twilio  # Optional, for SMS
```

### 2. Run Database Migration
```bash
cd backend
python migrate_google_auth.py
```

### 3. Update Environment Variables
Edit `backend/.env` with your actual credentials (see examples above)

### 4. Restart Backend Server
```bash
cd backend
python app.py
```

## 🧪 Testing

### Test Forgot Password
1. Open the app
2. Go to "Forgot Password"
3. Enter your email
4. Check your email for the reset code

### Test Google Sign-In
1. Open the app
2. Click "Sign in with Google"
3. Complete Google authentication
4. Should create account and log you in

## 🔍 Troubleshooting

### Email Not Sending
- Check SMTP credentials are correct
- Verify App Password (not regular password) for Gmail
- Check firewall/network restrictions

### Google Sign-In Not Working
- Verify Google Client ID is correct
- Check Google+ API is enabled
- Ensure redirect URIs are configured
- Check app is not in restricted mode

### Development Mode
If email/SMS is not configured, the app will work in development mode:
- Forgot password will show the reset code in the API response
- Google sign-in will work with mock authentication

## 📞 Support
If you need help with configuration, the reset codes will be logged in the backend console during development.
