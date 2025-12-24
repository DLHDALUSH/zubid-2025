# Frontend Integration Guide for New Backend Features

## Quick Start

This guide shows you how to integrate the new backend features into the ZUBID frontend.

---

## 1. Dynamic Navigation Menu

### Fetch Navigation Menu

```javascript
// Fetch navigation menu on page load
async function loadNavigationMenu() {
    try {
        const response = await fetch('/api/navigation/menu');
        const data = await response.json();
        
        if (response.ok) {
            renderNavigationMenu(data.menu, data.user_authenticated);
        }
    } catch (error) {
        console.error('Failed to load navigation menu:', error);
    }
}

// Render navigation menu
function renderNavigationMenu(menuItems, isAuthenticated) {
    const navLinksContainer = document.querySelector('.nav-links');
    navLinksContainer.innerHTML = '';
    
    menuItems.forEach(item => {
        // Skip items that require auth if user is not authenticated
        if (item.requires_auth && !isAuthenticated) {
            return;
        }
        
        if (item.children && item.children.length > 0) {
            // Create dropdown menu
            const dropdown = createDropdownMenu(item);
            navLinksContainer.appendChild(dropdown);
        } else {
            // Create regular link
            const link = createNavLink(item);
            navLinksContainer.appendChild(link);
        }
    });
}

function createDropdownMenu(item) {
    const dropdown = document.createElement('div');
    dropdown.className = 'nav-dropdown';
    
    const toggle = document.createElement('button');
    toggle.className = 'nav-link dropdown-toggle';
    toggle.innerHTML = `
        <span>${item.label}</span>
        <svg class="dropdown-arrow" width="12" height="12" viewBox="0 0 12 12">
            <path d="M2 4l4 4 4-4" stroke="currentColor" fill="none"/>
        </svg>
    `;
    
    const menu = document.createElement('div');
    menu.className = 'dropdown-menu';
    
    item.children.forEach(child => {
        const childLink = document.createElement('a');
        childLink.href = child.url;
        childLink.className = 'dropdown-item';
        childLink.textContent = child.label;
        menu.appendChild(childLink);
    });
    
    dropdown.appendChild(toggle);
    dropdown.appendChild(menu);
    
    return dropdown;
}

function createNavLink(item) {
    const link = document.createElement('a');
    link.href = item.url;
    link.className = 'nav-link';
    link.target = item.target || '_self';
    if (item.css_class) {
        link.className += ' ' + item.css_class;
    }
    link.textContent = item.label;
    return link;
}

// Call on page load
document.addEventListener('DOMContentLoaded', loadNavigationMenu);
```

---

## 2. User Preferences

### Fetch User Preferences

```javascript
async function loadUserPreferences() {
    try {
        const response = await fetch('/api/user/preferences');
        const preferences = await response.json();
        
        if (response.ok) {
            applyUserPreferences(preferences);
        }
    } catch (error) {
        console.error('Failed to load preferences:', error);
    }
}

function applyUserPreferences(preferences) {
    // Apply theme
    document.documentElement.setAttribute('data-theme', preferences.theme);
    
    // Apply language
    document.documentElement.setAttribute('lang', preferences.language);
    
    // Store preferences for later use
    window.userPreferences = preferences;
}
```

### Update User Preferences

```javascript
async function updatePreferences(newPreferences) {
    try {
        const response = await fetch('/api/user/preferences', {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(newPreferences)
        });
        
        if (response.ok) {
            console.log('Preferences updated successfully');
            // Reload preferences
            await loadUserPreferences();
        } else {
            const error = await response.json();
            console.error('Failed to update preferences:', error.error);
        }
    } catch (error) {
        console.error('Failed to update preferences:', error);
    }
}

// Example: Update theme
document.getElementById('themeSelector').addEventListener('change', (e) => {
    updatePreferences({ theme: e.target.value });
});
```

---

## 3. Enhanced User Profile

### Fetch Enhanced Profile

```javascript
async function loadUserProfile() {
    try {
        const response = await fetch('/api/user/profile');
        const profile = await response.json();
        
        if (response.ok) {
            displayUserProfile(profile);
        }
    } catch (error) {
        console.error('Failed to load profile:', error);
    }
}

function displayUserProfile(profile) {
    // Display basic info
    document.getElementById('username').textContent = profile.username;
    document.getElementById('email').textContent = profile.email;
    
    // Display new fields
    if (profile.first_name && profile.last_name) {
        document.getElementById('fullName').textContent = 
            `${profile.first_name} ${profile.last_name}`;
    }
    
    if (profile.bio) {
        document.getElementById('bio').textContent = profile.bio;
    }
    
    if (profile.profile_photo) {
        document.getElementById('profilePhoto').src = profile.profile_photo;
    }
    
    // Display location
    if (profile.city && profile.country) {
        document.getElementById('location').textContent = 
            `${profile.city}, ${profile.country}`;
    }
    
    // Display verification badges
    if (profile.email_verified) {
        document.getElementById('emailVerified').style.display = 'inline';
    }
    if (profile.phone_verified) {
        document.getElementById('phoneVerified').style.display = 'inline';
    }
    
    // Display login stats
    if (profile.last_login) {
        document.getElementById('lastLogin').textContent = 
            new Date(profile.last_login).toLocaleString();
    }
    document.getElementById('loginCount').textContent = profile.login_count || 0;
}
```

### Update Profile

```javascript
async function updateProfile(profileData) {
    try {
        const response = await fetch('/api/user/profile', {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(profileData)
        });
        
        if (response.ok) {
            console.log('Profile updated successfully');
            await loadUserProfile();
        } else {
            const error = await response.json();
            alert('Failed to update profile: ' + error.error);
        }
    } catch (error) {
        console.error('Failed to update profile:', error);
    }
}

// Example: Update profile form
document.getElementById('profileForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const profileData = {
        first_name: document.getElementById('firstName').value,
        last_name: document.getElementById('lastName').value,
        bio: document.getElementById('bio').value,
        city: document.getElementById('city').value,
        country: document.getElementById('country').value,
        website: document.getElementById('website').value
    };
    
    await updateProfile(profileData);
});
```

### Upload Profile Photo

```javascript
async function uploadProfilePhoto(file) {
    const formData = new FormData();
    formData.append('photo', file);
    
    try {
        const response = await fetch('/api/user/profile/photo', {
            method: 'POST',
            body: formData
        });
        
        if (response.ok) {
            const data = await response.json();
            console.log('Photo uploaded successfully');
            // Update photo display
            document.getElementById('profilePhoto').src = data.profile_photo;
        } else {
            const error = await response.json();
            alert('Failed to upload photo: ' + error.error);
        }
    } catch (error) {
        console.error('Failed to upload photo:', error);
    }
}

// Example: Photo upload input
document.getElementById('photoInput').addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (file) {
        // Validate file size (5MB max)
        if (file.size > 5 * 1024 * 1024) {
            alert('File too large. Maximum size is 5MB.');
            return;
        }
        
        // Validate file type
        const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];
        if (!allowedTypes.includes(file.type)) {
            alert('Invalid file type. Allowed: PNG, JPG, JPEG, GIF, WEBP');
            return;
        }
        
        uploadProfilePhoto(file);
    }
});
```

---

## 4. Complete Integration Example

```javascript
// Initialize all features on page load
document.addEventListener('DOMContentLoaded', async () => {
    // Check if user is logged in
    const isLoggedIn = await checkLoginStatus();
    
    if (isLoggedIn) {
        // Load user-specific data
        await Promise.all([
            loadNavigationMenu(),
            loadUserPreferences(),
            loadUserProfile()
        ]);
    } else {
        // Load public navigation only
        await loadNavigationMenu();
    }
});

async function checkLoginStatus() {
    try {
        const response = await fetch('/api/user/profile');
        return response.ok;
    } catch {
        return false;
    }
}
```

---

## 📝 Notes

- All authenticated endpoints require a valid session cookie
- Navigation menu is automatically filtered based on user authentication
- Preferences are created automatically on first login
- Profile photo uploads are limited to 5MB
- Website URLs must start with http:// or https://

---

## 🔗 Related Documentation

- **Full API Documentation**: `BACKEND_ENHANCEMENTS.md`
- **Backend Summary**: `BACKEND_UPDATE_SUMMARY.md`
- **Current Frontend**: `frontend/app.js`

---

**Ready to integrate!** 🚀

