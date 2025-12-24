# ZUBID - New Features Guide
**Date:** December 25, 2024

---

## 🆕 New Features

### 1. User Balance System
### 2. Push Notification Integration (FCM)

---

## 💰 User Balance System

### Overview
Users now have a balance field that tracks their account balance. This can be used for:
- Wallet functionality
- Deposit/withdrawal tracking
- Payment processing
- Bid deposits

### Database Field
```python
balance = db.Column(db.Float, default=0.0, nullable=False)
```

### API Response
The balance is now included in user data:

**Login Response:**
```json
{
  "message": "Login successful",
  "user": {
    "id": "1",
    "username": "admin",
    "email": "admin@zubid.com",
    "balance": 0.0,
    ...
  }
}
```

**Profile Response:**
```json
{
  "id": "1",
  "username": "admin",
  "balance": 0.0,
  ...
}
```

### Future Implementation Ideas

**Add Deposit Endpoint:**
```python
@app.route('/api/user/balance/deposit', methods=['POST'])
@login_required
def deposit_balance():
    data = request.get_json()
    amount = float(data.get('amount', 0))
    
    user = User.query.get(session['user_id'])
    user.balance += amount
    db.session.commit()
    
    return jsonify({'balance': user.balance}), 200
```

**Add Withdrawal Endpoint:**
```python
@app.route('/api/user/balance/withdraw', methods=['POST'])
@login_required
def withdraw_balance():
    data = request.get_json()
    amount = float(data.get('amount', 0))
    
    user = User.query.get(session['user_id'])
    if user.balance >= amount:
        user.balance -= amount
        db.session.commit()
        return jsonify({'balance': user.balance}), 200
    return jsonify({'error': 'Insufficient balance'}), 400
```

---

## 🔔 Push Notification Integration

### Overview
Backend now supports Firebase Cloud Messaging (FCM) token management for push notifications.

### Database Field
```python
fcm_token = db.Column(db.String(255), nullable=True)
```

### API Endpoints

#### 1. Update FCM Token
**Endpoint:** `POST /api/user/fcm-token`  
**Authentication:** Required  
**Rate Limit:** 20 requests per minute

**Request:**
```json
{
  "fcm_token": "your-firebase-cloud-messaging-token-here"
}
```

**Response:**
```json
{
  "message": "FCM token updated successfully",
  "success": true
}
```

**Error Response:**
```json
{
  "error": "FCM token is required"
}
```

#### 2. Delete FCM Token
**Endpoint:** `DELETE /api/user/fcm-token`  
**Authentication:** Required  
**Rate Limit:** 20 requests per minute

**Response:**
```json
{
  "message": "FCM token deleted successfully",
  "success": true
}
```

### Frontend Integration (JavaScript)

```javascript
// After user logs in, send FCM token
async function updateFCMToken(token) {
    try {
        const response = await fetch('/api/user/fcm-token', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': csrfToken
            },
            credentials: 'include',
            body: JSON.stringify({ fcm_token: token })
        });
        
        if (response.ok) {
            console.log('FCM token updated successfully');
        }
    } catch (error) {
        console.error('Failed to update FCM token:', error);
    }
}

// On logout, delete FCM token
async function deleteFCMToken() {
    try {
        await fetch('/api/user/fcm-token', {
            method: 'DELETE',
            headers: {
                'X-CSRFToken': csrfToken
            },
            credentials: 'include'
        });
    } catch (error) {
        console.error('Failed to delete FCM token:', error);
    }
}
```

### Android Integration (Kotlin)

The Android service has been updated with implementation guidance. To complete the integration:

1. **Add API interface method:**
```kotlin
@POST("/api/user/fcm-token")
suspend fun updateFcmToken(@Body token: Map<String, String>): Response<JsonObject>
```

2. **Call after login:**
```kotlin
val token = getSharedPreferences("zubid_prefs", Context.MODE_PRIVATE)
    .getString("pending_fcm_token", null)

if (token != null) {
    CoroutineScope(Dispatchers.IO).launch {
        try {
            val response = ApiClient.apiService.updateFcmToken(
                mapOf("fcm_token" to token)
            )
            if (response.isSuccessful) {
                // Clear pending token
                getSharedPreferences("zubid_prefs", Context.MODE_PRIVATE)
                    .edit()
                    .remove("pending_fcm_token")
                    .apply()
            }
        } catch (e: Exception) {
            Log.e("FCM", "Error sending token", e)
        }
    }
}
```

### Sending Notifications (Backend)

Example function to send notifications to users:

```python
import requests

def send_push_notification(user_id, title, body, data=None):
    """Send push notification to a user"""
    user = User.query.get(user_id)
    if not user or not user.fcm_token:
        return False
    
    # Your Firebase Server Key
    server_key = os.getenv('FIREBASE_SERVER_KEY')
    
    headers = {
        'Authorization': f'Bearer {server_key}',
        'Content-Type': 'application/json'
    }
    
    payload = {
        'to': user.fcm_token,
        'notification': {
            'title': title,
            'body': body,
            'sound': 'default'
        },
        'data': data or {}
    }
    
    response = requests.post(
        'https://fcm.googleapis.com/fcm/send',
        headers=headers,
        json=payload
    )
    
    return response.status_code == 200
```

---

## 🚀 Quick Start

### 1. Run Database Migration
```bash
cd backend
python migrate_user_fields.py
```

### 2. Start Backend
```bash
python app.py
```

### 3. Test New Features
```bash
# Test balance field
curl -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Test FCM token endpoint
curl -X POST http://localhost:5000/api/user/fcm-token \
  -H "Content-Type: application/json" \
  -H "Cookie: session=your-session-cookie" \
  -d '{"fcm_token":"test-token-123"}'
```

---

## 📚 Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flask-Limiter Documentation](https://flask-limiter.readthedocs.io/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)

---

**Happy Coding!** 🎉

