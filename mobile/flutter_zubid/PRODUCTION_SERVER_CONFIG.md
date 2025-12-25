# Flutter App - Production Server Configuration

## ✅ Configuration Updated

The Flutter app is now configured to connect to the **production server** by default.

---

## 🌐 Current Configuration

### API Endpoint:
```
https://zubidauction.duckdns.org/api
```

### WebSocket Endpoint:
```
wss://zubidauction.duckdns.org
```

---

## 📱 How to Use

### 1. Run the App

```bash
cd mobile/flutter_zubid
flutter pub get
flutter run
```

The app will automatically connect to the production server.

### 2. Test Login

Use your production credentials:
- Username: Your registered username
- Password: Your password

---

## 🔧 Switch to Local Development (Optional)

If you need to test with a local backend server:

### Step 1: Edit Configuration File

Open: `lib/core/config/app_config.dart`

### Step 2: Comment Production, Uncomment Local

**For Android Emulator:**
```dart
static String get baseUrl {
  // return 'https://zubidauction.duckdns.org/api';  // Comment this
  return 'http://10.0.2.2:5000/api';  // Uncomment this
}

static String get websocketUrl {
  // return 'wss://zubidauction.duckdns.org';  // Comment this
  return 'ws://10.0.2.2:5000';  // Uncomment this
}
```

**For iOS Simulator:**
```dart
static String get baseUrl {
  // return 'https://zubidauction.duckdns.org/api';  // Comment this
  return 'http://localhost:5000/api';  // Uncomment this
}

static String get websocketUrl {
  // return 'wss://zubidauction.duckdns.org';  // Comment this
  return 'ws://localhost:5000';  // Uncomment this
}
```

**For Physical Device:**
```dart
static String get baseUrl {
  // return 'https://zubidauction.duckdns.org/api';  // Comment this
  return 'http://YOUR_IP:5000/api';  // Uncomment and replace YOUR_IP
}

static String get websocketUrl {
  // return 'wss://zubidauction.duckdns.org';  // Comment this
  return 'ws://YOUR_IP:5000';  // Uncomment and replace YOUR_IP
}
```

### Step 3: Hot Reload

Press `r` in the Flutter terminal to hot reload the app.

---

## 📋 Files Modified

1. **`lib/core/config/app_config.dart`**
   - Changed to use production server by default
   - Added comments for local development

2. **`lib/core/config/environment.dart`**
   - Updated all environments to use production server
   - Added comments for local development

3. **`lib/features/auth/data/repositories/auth_repository.dart`**
   - Updated error handling for production server
   - Improved connection error messages

---

## 🔍 Verify Connection

### Check API Endpoint:
The app will connect to:
```
https://zubidauction.duckdns.org/api
```

### Check WebSocket:
The app will connect to:
```
wss://zubidauction.duckdns.org
```

### Test Connection:
```bash
# Test API endpoint
curl https://zubidauction.duckdns.org/api/csrf-token

# Should return:
# {"csrf_token": "..."}
```

---

## 🐛 Troubleshooting

### "Cannot reach server" Error:

1. **Check Internet Connection:**
   - Make sure your device has internet access
   - Try opening a browser and visiting a website

2. **Check Server Status:**
   - Verify the production server is running
   - Test with: `curl https://zubidauction.duckdns.org/api/csrf-token`

3. **Check DNS:**
   - Make sure `zubidauction.duckdns.org` resolves correctly
   - Try: `ping zubidauction.duckdns.org`

### "Connection timeout" Error:

1. **Check Firewall:**
   - Make sure your firewall isn't blocking HTTPS connections
   - Check if port 443 is accessible

2. **Check Network:**
   - Try switching between WiFi and mobile data
   - Some networks may block certain domains

### "SSL/TLS Error":

1. **Check Certificate:**
   - Make sure the server has a valid SSL certificate
   - Try accessing in a browser: `https://zubidauction.duckdns.org`

2. **Update Flutter:**
   - Make sure you're using the latest Flutter version
   - Run: `flutter upgrade`

---

## ✅ Summary

- ✅ App configured to use production server
- ✅ API endpoint: `https://zubidauction.duckdns.org/api`
- ✅ WebSocket endpoint: `wss://zubidauction.duckdns.org`
- ✅ Error handling updated for production
- ✅ Local development instructions included

**The app is ready to connect to the production server!** 🚀

---

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Review the error messages in the Flutter console
3. Verify the production server is running and accessible
4. Check the backend logs for any errors

---

**Last Updated:** December 25, 2024

