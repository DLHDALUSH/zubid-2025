# ZUBID Backend Enhancements Documentation

## Overview
This document describes the new backend features added to support the enhanced navigation structure, user profiles, and preferences system.

---

## 🆕 New Features

### 1. **Dynamic Navigation Menu System**
A flexible, database-driven navigation menu that can be configured dynamically.

#### Database Model: `NavigationMenu`
```python
- id: Integer (Primary Key)
- name: String(100) - Unique identifier
- label: String(100) - Display text
- url: String(500) - Link URL (optional for dropdowns)
- icon: String(100) - Icon name or SVG path
- parent_id: Integer - For nested menus (self-referential)
- order: Integer - Display order
- is_active: Boolean - Enable/disable menu items
- requires_auth: Boolean - Show only when logged in
- requires_role: String(20) - Required user role (admin, user)
- target: String(20) - Link target (_self, _blank)
- css_class: String(100) - Custom CSS classes
- created_at: DateTime
- updated_at: DateTime
```

#### API Endpoints

**GET `/api/navigation/menu`**
- **Description**: Get navigation menu structure
- **Authentication**: Optional (filters based on user role)
- **Query Parameters**:
  - `include_inactive` (boolean): Include inactive menu items (default: false)
- **Response**:
```json
{
  "menu": [
    {
      "id": 1,
      "name": "home",
      "label": "Home",
      "url": "index.html",
      "icon": "home",
      "target": "_self",
      "css_class": null,
      "requires_auth": false,
      "children": []
    },
    {
      "id": 2,
      "name": "my_account",
      "label": "My Account",
      "url": null,
      "icon": "user",
      "requires_auth": true,
      "children": [
        {
          "id": 3,
          "name": "profile",
          "label": "Profile",
          "url": "profile.html",
          "children": []
        }
      ]
    }
  ],
  "user_authenticated": true,
  "user_role": "user"
}
```

**POST `/api/navigation/menu`** (Admin Only)
- **Description**: Create new navigation menu item
- **Authentication**: Required (Admin role)
- **Request Body**:
```json
{
  "name": "new_menu",
  "label": "New Menu",
  "url": "new-page.html",
  "icon": "star",
  "parent_id": null,
  "order": 5,
  "is_active": true,
  "requires_auth": false,
  "requires_role": null,
  "target": "_self",
  "css_class": "custom-class"
}
```

**PUT `/api/navigation/menu/<menu_id>`** (Admin Only)
- **Description**: Update navigation menu item
- **Authentication**: Required (Admin role)
- **Request Body**: Same as POST (all fields optional)

---

### 2. **Enhanced User Profiles**
Extended user profile with additional fields for better user management.

#### New User Model Fields
```python
- first_name: String(50)
- last_name: String(50)
- bio: Text - User biography
- company: String(100)
- website: String(255)
- city: String(100)
- country: String(100)
- postal_code: String(20)
- phone_verified: Boolean
- email_verified: Boolean
- is_active: Boolean - Account status
- last_login: DateTime
- login_count: Integer
```

#### Updated API Endpoints

**GET `/api/user/profile`**
- **Response** (now includes):
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "bio": "Auction enthusiast",
  "company": "ACME Corp",
  "website": "https://example.com",
  "city": "Erbil",
  "country": "Iraq",
  "postal_code": "44001",
  "phone_verified": true,
  "email_verified": true,
  "is_active": true,
  "last_login": "2025-11-23T10:30:00Z",
  "login_count": 42,
  "preferences": { ... }
}
```

**PUT `/api/user/profile`**
- **Description**: Update user profile (now supports new fields)
- **Request Body** (all fields optional):
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "bio": "Updated bio",
  "company": "New Company",
  "website": "https://newsite.com",
  "city": "Erbil",
  "country": "Iraq",
  "postal_code": "44001"
}
```

**POST `/api/user/profile/photo`**
- **Description**: Upload profile photo separately
- **Authentication**: Required
- **Content-Type**: multipart/form-data
- **Form Data**:
  - `photo`: Image file (PNG, JPG, JPEG, GIF, WEBP)
- **Max Size**: 5MB
- **Response**:
```json
{
  "message": "Profile photo uploaded successfully",
  "profile_photo": "/uploads/profile_20251123_103000_1_photo.jpg"
}
```

---

### 3. **User Preferences System**
Personalized settings for each user.

#### Database Model: `UserPreference`
```python
- id: Integer (Primary Key)
- user_id: Integer (Foreign Key, Unique)
- theme: String(20) - light, dark, auto
- language: String(10) - en, ku, ar
- notifications_enabled: Boolean
- email_notifications: Boolean
- bid_alerts: Boolean
- auction_reminders: Boolean
- newsletter_subscribed: Boolean
- currency: String(10) - USD, IQD, EUR
- timezone: String(50)
- items_per_page: Integer (5-100)
- default_view: String(20) - grid, list
- created_at: DateTime
- updated_at: DateTime
```

#### API Endpoints

**GET `/api/user/preferences`**
- **Description**: Get user preferences (creates defaults if not exist)
- **Authentication**: Required
- **Response**:
```json
{
  "theme": "light",
  "language": "en",
  "notifications_enabled": true,
  "email_notifications": true,
  "bid_alerts": true,
  "auction_reminders": true,
  "newsletter_subscribed": false,
  "currency": "USD",
  "timezone": "UTC",
  "items_per_page": 20,
  "default_view": "grid"
}
```

**PUT `/api/user/preferences`**
- **Description**: Update user preferences
- **Authentication**: Required
- **Request Body** (all fields optional):
```json
{
  "theme": "dark",
  "language": "ku",
  "notifications_enabled": true,
  "email_notifications": false,
  "bid_alerts": true,
  "auction_reminders": true,
  "newsletter_subscribed": true,
  "currency": "IQD",
  "timezone": "Asia/Baghdad",
  "items_per_page": 50,
  "default_view": "list"
}
```

---

## 🔄 Updated Features

### Login Endpoint Enhancement
**POST `/api/login`**
- Now tracks login activity:
  - Updates `last_login` timestamp
  - Increments `login_count`
  - Creates default preferences if they don't exist
  - Checks if account is active
- Returns additional user info:
  - `profile_photo`
  - `first_name`
  - `last_name`

---

## 📊 Database Migration

### Running the Migration
```bash
python backend/migrate_enhanced_features.py
```

This script will:
1. Add 13 new columns to the User table
2. Create NavigationMenu table
3. Create UserPreference table
4. Verify all changes

### Default Navigation Menu
The system automatically creates a default navigation structure on first run:
- **Home** (public)
- **My Account** (requires auth)
  - Profile
  - My Bids
  - Payments
  - Return Requests
- **Info** (public)
  - How to Bid
  - Contact Us

---

## 🔒 Security Features

### Authentication & Authorization
- All user-specific endpoints require authentication
- Admin-only endpoints check user role
- Navigation menu filters items based on:
  - User authentication status
  - User role
  - Menu item permissions

### Input Validation
- All string inputs are sanitized
- Website URLs must start with http:// or https://
- Phone numbers are validated
- Profile photos are validated for:
  - File type (PNG, JPG, JPEG, GIF, WEBP)
  - File size (max 5MB)
  - Secure filename generation
  - Path traversal prevention

### Rate Limiting
- Login: 10 attempts per minute
- Profile photo upload: 10 per minute

---

## 🧪 Testing the New Features

### 1. Test Navigation Menu API
```bash
# Get navigation menu (public)
curl http://localhost:5000/api/navigation/menu

# Get navigation menu (authenticated)
curl -X GET http://localhost:5000/api/navigation/menu \
  -H "Cookie: session=YOUR_SESSION_COOKIE"

# Create menu item (admin only)
curl -X POST http://localhost:5000/api/navigation/menu \
  -H "Content-Type: application/json" \
  -H "Cookie: session=ADMIN_SESSION_COOKIE" \
  -d '{
    "name": "test_menu",
    "label": "Test Menu",
    "url": "test.html",
    "order": 10
  }'
```

### 2. Test Enhanced Profile
```bash
# Get profile with new fields
curl -X GET http://localhost:5000/api/user/profile \
  -H "Cookie: session=YOUR_SESSION_COOKIE"

# Update profile
curl -X PUT http://localhost:5000/api/user/profile \
  -H "Content-Type: application/json" \
  -H "Cookie: session=YOUR_SESSION_COOKIE" \
  -d '{
    "first_name": "John",
    "last_name": "Doe",
    "bio": "Auction enthusiast",
    "city": "Erbil",
    "country": "Iraq"
  }'

# Upload profile photo
curl -X POST http://localhost:5000/api/user/profile/photo \
  -H "Cookie: session=YOUR_SESSION_COOKIE" \
  -F "photo=@/path/to/photo.jpg"
```

### 3. Test User Preferences
```bash
# Get preferences
curl -X GET http://localhost:5000/api/user/preferences \
  -H "Cookie: session=YOUR_SESSION_COOKIE"

# Update preferences
curl -X PUT http://localhost:5000/api/user/preferences \
  -H "Content-Type: application/json" \
  -H "Cookie: session=YOUR_SESSION_COOKIE" \
  -d '{
    "theme": "dark",
    "language": "ku",
    "items_per_page": 50
  }'
```

---

## 📝 Frontend Integration

### Fetching Navigation Menu
```javascript
// Fetch navigation menu
async function loadNavigationMenu() {
  const response = await fetch('/api/navigation/menu');
  const data = await response.json();

  // data.menu contains the menu structure
  // data.user_authenticated indicates if user is logged in
  // data.user_role contains the user's role

  renderNavigationMenu(data.menu);
}
```

### Updating User Preferences
```javascript
// Update user preferences
async function updatePreferences(preferences) {
  const response = await fetch('/api/user/preferences', {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(preferences)
  });

  if (response.ok) {
    console.log('Preferences updated successfully');
  }
}
```

---

## 🎯 Benefits

### For Users
- ✅ Personalized experience with preferences
- ✅ Enhanced profile with more information
- ✅ Better navigation with organized menus
- ✅ Profile photo support

### For Administrators
- ✅ Dynamic menu configuration without code changes
- ✅ Role-based menu visibility
- ✅ User activity tracking (login count, last login)
- ✅ Account management (activate/deactivate users)

### For Developers
- ✅ Clean API structure
- ✅ Extensible navigation system
- ✅ Comprehensive user preferences
- ✅ Easy to add new menu items or preferences

---

## 🚀 Next Steps

1. **Restart Backend Server**
   ```bash
   python backend/app.py
   ```

2. **Update Frontend**
   - Integrate navigation menu API
   - Add profile photo upload UI
   - Create preferences settings page
   - Update profile page with new fields

3. **Test All Features**
   - Login and verify tracking
   - Upload profile photo
   - Update preferences
   - Test navigation menu

4. **Optional Enhancements**
   - Add email verification system
   - Add phone verification system
   - Create admin panel for menu management
   - Add more preference options

---

## 📞 Support

For issues or questions about these new features:
1. Check the API documentation above
2. Review the migration script output
3. Check backend logs for errors
4. Verify database schema with migration script

---

**Last Updated**: 2025-11-23
**Version**: 2.0.0
**Status**: ✅ Production Ready

