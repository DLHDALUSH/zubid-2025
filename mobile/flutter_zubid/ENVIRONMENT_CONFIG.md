# 🔧 Flutter Environment Configuration Guide

This guide explains how to configure the Flutter app for different environments (development, staging, production).

## 📋 Quick Start

### Development (Local Backend)

#### Android Emulator
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:5000 --dart-define=WS_URL=ws://10.0.2.2:5000
```

#### iOS Simulator
```bash
flutter run --dart-define=API_URL=http://localhost:5000 --dart-define=WS_URL=ws://localhost:5000
```

#### Physical Device (Replace with your computer's IP)
```bash
flutter run --dart-define=API_URL=http://192.168.1.100:5000 --dart-define=WS_URL=ws://192.168.1.100:5000
```

### Production (Render.com)
```bash
flutter run --release --dart-define=API_URL=https://zubid-2025.onrender.com --dart-define=WS_URL=wss://zubid-2025.onrender.com
```

### Staging (If you have a staging server)
```bash
flutter run --dart-define=API_URL=https://staging.zubidauction.com --dart-define=WS_URL=wss://staging.zubidauction.com
```

---

## 🎯 Auto-Detection (No Configuration Needed)

If you don't specify `--dart-define`, the app will automatically detect the environment:

- **Debug Mode** (flutter run): Uses `http://10.0.2.2:5000` (Android emulator default)
- **Release Mode** (flutter run --release): Uses `https://zubid-2025.onrender.com` (production)

---

## 🔨 Building for Production

### Android APK
```bash
flutter build apk --release \
  --dart-define=API_URL=https://zubid-2025.onrender.com \
  --dart-define=WS_URL=wss://zubid-2025.onrender.com
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release \
  --dart-define=API_URL=https://zubid-2025.onrender.com \
  --dart-define=WS_URL=wss://zubid-2025.onrender.com
```

### iOS (requires macOS)
```bash
flutter build ios --release \
  --dart-define=API_URL=https://zubid-2025.onrender.com \
  --dart-define=WS_URL=wss://zubid-2025.onrender.com
```

---

## 💡 Tips for Local Development

### Finding Your Computer's IP Address

**Windows:**
```bash
ipconfig
# Look for "IPv4 Address" under your active network adapter
```

**macOS/Linux:**
```bash
ifconfig
# Look for "inet" under your active network adapter (usually en0 or wlan0)
```

### Testing on Physical Device

1. Make sure your phone and computer are on the **same Wi-Fi network**
2. Find your computer's IP address (e.g., `192.168.1.100`)
3. Make sure your backend is running and accessible
4. Run the app with your IP:
```bash
flutter run --dart-define=API_URL=http://192.168.1.100:5000
```

### Backend Must Allow External Connections

Make sure your Flask backend is running with `host='0.0.0.0'`:
```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

---

## 🚀 VS Code Launch Configurations

Create `.vscode/launch.json` in the Flutter project root:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Development - Android Emulator)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=API_URL=http://10.0.2.2:5000",
        "--dart-define=WS_URL=ws://10.0.2.2:5000"
      ]
    },
    {
      "name": "Flutter (Development - iOS Simulator)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=API_URL=http://localhost:5000",
        "--dart-define=WS_URL=ws://localhost:5000"
      ]
    },
    {
      "name": "Flutter (Production)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "flutterMode": "release",
      "args": [
        "--dart-define=API_URL=https://zubid-2025.onrender.com",
        "--dart-define=WS_URL=wss://zubid-2025.onrender.com"
      ]
    },
    {
      "name": "Flutter (Physical Device - Update IP)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=API_URL=http://192.168.1.100:5000",
        "--dart-define=WS_URL=ws://192.168.1.100:5000"
      ]
    }
  ]
}
```

Now you can select the configuration from VS Code's Run menu!

---

## 📝 Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `API_URL` | Backend API base URL | `http://10.0.2.2:5000` |
| `WS_URL` | WebSocket server URL | `ws://10.0.2.2:5000` |

---

## ✅ Verification

After running the app, check the logs to verify the configuration:

```
[INFO] API base URL: http://10.0.2.2:5000
[INFO] WebSocket URL: ws://10.0.2.2:5000
```

---

## 🐛 Troubleshooting

### "Failed host lookup" or "Connection refused"

1. **Android Emulator**: Use `10.0.2.2` instead of `localhost`
2. **iOS Simulator**: Use `localhost` or `127.0.0.1`
3. **Physical Device**: Use your computer's IP address (e.g., `192.168.1.100`)
4. Make sure backend is running with `host='0.0.0.0'`
5. Check firewall settings on your computer

### "CORS Error"

Make sure your Flask backend has CORS configured:
```python
from flask_cors import CORS
CORS(app, supports_credentials=True)
```

### Changes Not Reflecting

1. Stop the app completely
2. Run `flutter clean`
3. Run `flutter pub get`
4. Restart with the correct `--dart-define` flags

---

## 📚 Additional Resources

- [Flutter Environment Variables](https://dart.dev/guides/environment-declarations)
- [Android Emulator Networking](https://developer.android.com/studio/run/emulator-networking)
- [iOS Simulator Networking](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)

---

**Last Updated:** January 3, 2026

