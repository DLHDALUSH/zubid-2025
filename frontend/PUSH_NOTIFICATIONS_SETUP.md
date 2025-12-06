# ZUBID Push Notifications Setup Guide

## 📱 Overview

Push notifications allow you to send real-time alerts to users about:
- New bids on their auctions
- Outbid notifications
- Auction ending soon
- Auction won/lost
- Payment confirmations

---

## 🔥 Firebase Setup (Android)

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Name it "ZUBID" and follow the setup wizard

### Step 2: Add Android App
1. In Firebase Console, click "Add App" → Android
2. Enter package name: `com.zubid.app`
3. Download `google-services.json`
4. Place it in: `frontend/android/app/google-services.json`

### Step 3: Update Android Build Files

Add to `frontend/android/build.gradle` (project level):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Add to `frontend/android/app/build.gradle` (app level):
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

---

## 🍎 APNs Setup (iOS)

### Step 1: Apple Developer Account
1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Navigate to Certificates, Identifiers & Profiles

### Step 2: Create APNs Key
1. Go to Keys → Create a new key
2. Enable "Apple Push Notifications service (APNs)"
3. Download the `.p8` key file
4. Note the Key ID

### Step 3: Configure in Firebase (Recommended)
1. In Firebase Console → Project Settings → Cloud Messaging
2. Upload your APNs key (.p8 file)
3. Enter Key ID and Team ID

### Step 4: Enable Push in Xcode
1. Open `frontend/ios/App/App.xcworkspace` in Xcode
2. Select your target → Signing & Capabilities
3. Add "Push Notifications" capability
4. Add "Background Modes" → Check "Remote notifications"

---

## 🔧 Backend Integration

### Register Device Endpoint
Add this endpoint to your Flask backend:

```python
@app.route('/api/register-device', methods=['POST'])
@jwt_required()
def register_device():
    data = request.get_json()
    user_id = get_jwt_identity()
    
    # Save device token to database
    device = DeviceToken(
        user_id=user_id,
        token=data['token'],
        platform=data['platform']
    )
    db.session.add(device)
    db.session.commit()
    
    return jsonify({'message': 'Device registered'})
```

### Send Push Notification
```python
import firebase_admin
from firebase_admin import messaging

def send_push_notification(token, title, body, data=None):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        token=token,
    )
    response = messaging.send(message)
    return response
```

---

## 📋 Notification Types

| Type | Trigger | Data |
|------|---------|------|
| `auction_bid` | New bid placed | `{auctionId, bidAmount}` |
| `outbid` | User outbid | `{auctionId, newBid}` |
| `auction_ending` | 1 hour before end | `{auctionId}` |
| `auction_won` | User wins auction | `{auctionId}` |
| `payment` | Payment update | `{paymentId, status}` |

---

## ✅ Testing

### Test on Android
1. Build and install app on device
2. Open app and grant notification permission
3. Check Logcat for device token
4. Use Firebase Console → Cloud Messaging to send test

### Test on iOS
1. Build app in Xcode
2. Run on physical device (not simulator)
3. Accept notification permission
4. Send test from Firebase Console

---

## 🔗 Resources

- [Capacitor Push Notifications](https://capacitorjs.com/docs/apis/push-notifications)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [APNs Documentation](https://developer.apple.com/documentation/usernotifications)

