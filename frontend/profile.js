// Profile page functionality - completely independent
document.addEventListener('DOMContentLoaded', async () => {
    // Prevent multiple executions
    if (window.profilePageLoaded) {
        return;
    }
    window.profilePageLoaded = true;
    
    // Simple toast function if not available
    if (typeof showToast === 'undefined') {
        window.showToast = function(message, type) {
            console.log(`[${type}] ${message}`);
            const toast = document.getElementById('toast');
            if (toast) {
                toast.textContent = message;
                toast.className = `toast ${type}`;
                toast.style.display = 'block';
                setTimeout(() => {
                    toast.style.display = 'none';
                }, 3000);
            }
        };
    }
    
    try {
        // Try to get profile - if fails, user is not logged in
        let profile;
        try {
            profile = await UserAPI.getProfile();
            
            // Set global currentUser if it exists
            if (typeof window !== 'undefined') {
                window.currentUser = profile;
            }
            
            // Update nav if function exists
            if (typeof updateNavAuth === 'function') {
                updateNavAuth(true);
            }
            if (document.getElementById('userName')) {
                document.getElementById('userName').textContent = profile.username;
            }
            if (document.getElementById('navAuth')) {
                document.getElementById('navAuth').style.display = 'none';
            }
            if (document.getElementById('navUser')) {
                document.getElementById('navUser').style.display = 'flex';
            }
        } catch (authError) {
            // Not authenticated - show message and redirect ONCE
            console.log('User not authenticated, redirecting...');
            const loadingIndicator = document.getElementById('loadingIndicator');
            if (loadingIndicator) {
                loadingIndicator.innerHTML = 'Please login to view your profile. Redirecting...';
            }
            
            // Use a flag to prevent multiple redirects
            if (!window.redirecting) {
                window.redirecting = true;
                setTimeout(() => {
                    window.location.href = 'index.html';
                }, 2000);
            }
            return;
        }
        
        // If we got here, user is authenticated - load profile data
        await loadProfile();
        
    } catch (error) {
        console.error('Error loading profile data:', error);
        const loadingIndicator = document.getElementById('loadingIndicator');
        if (loadingIndicator) {
            loadingIndicator.innerHTML = `Error: ${error.message || 'Failed to load profile'}. Please refresh the page.`;
            loadingIndicator.style.display = 'block';
        }
        const profileInfo = document.getElementById('profileInfo');
        if (profileInfo) {
            profileInfo.style.display = 'none';
        }
    }
});

// Load profile information
async function loadProfile() {
    try {
        const loadingIndicator = document.getElementById('loadingIndicator');
        const profileInfo = document.getElementById('profileInfo');
        
        if (!loadingIndicator || !profileInfo) {
            console.error('Required DOM elements not found');
            return;
        }
        
        const profile = await UserAPI.getProfile();
        
        // Hide loading, show profile
        loadingIndicator.style.display = 'none';
        profileInfo.style.display = 'block';
        
        // Populate form - check each element exists
        const usernameInput = document.getElementById('profileUsername');
        const emailInput = document.getElementById('profileEmail');
        const addressInput = document.getElementById('profileAddress');
        const phoneInput = document.getElementById('profilePhone');
        
        if (usernameInput) usernameInput.value = profile.username || '';
        if (emailInput) emailInput.value = profile.email || '';
        if (addressInput) addressInput.value = profile.address || '';
        if (phoneInput) phoneInput.value = profile.phone || '';
        
    } catch (error) {
        console.error('Error loading profile:', error);
        const loadingIndicator = document.getElementById('loadingIndicator');
        const profileInfo = document.getElementById('profileInfo');
        
        if (loadingIndicator) {
            loadingIndicator.innerHTML = `Error loading profile: ${error.message || 'Unknown error'}`;
            loadingIndicator.style.display = 'block';
        }
        if (profileInfo) {
            profileInfo.style.display = 'none';
        }
        
        if (typeof showToast !== 'undefined') {
            showToast('Error loading profile', 'error');
        }
    }
}

// Toggle edit mode
function toggleEditMode() {
    const emailInput = document.getElementById('profileEmail');
    const addressInput = document.getElementById('profileAddress');
    const phoneInput = document.getElementById('profilePhone');
    const saveBtn = document.getElementById('saveBtn');
    const editBtn = document.getElementById('editBtn');
    
    const isReadonly = emailInput.readOnly;
    
    emailInput.readOnly = !isReadonly;
    addressInput.readOnly = !isReadonly;
    phoneInput.readOnly = !isReadonly;
    
    if (isReadonly) {
        saveBtn.style.display = 'block';
        editBtn.textContent = 'Cancel';
    } else {
        saveBtn.style.display = 'none';
        editBtn.textContent = 'Edit Profile';
        // Reload profile to reset changes
        loadProfile();
    }
}

// Handle update profile
async function handleUpdateProfile(event) {
    event.preventDefault();
    
    const formError = document.getElementById('profileError');
    formError.textContent = '';
    
    const profileData = {
        email: document.getElementById('profileEmail').value,
        address: document.getElementById('profileAddress').value,
        phone: document.getElementById('profilePhone').value,
    };
    
    try {
        await UserAPI.updateProfile(profileData);
        showToast('Profile updated successfully!', 'success');
        toggleEditMode();
        await loadProfile();
    } catch (error) {
        formError.textContent = error.message || 'Failed to update profile';
        showToast(error.message || 'Failed to update profile', 'error');
    }
}


