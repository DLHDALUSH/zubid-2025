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
            if (window.utils) {
                if (type === 'error') window.utils.debugError(message);
                else if (type === 'warn') window.utils.debugWarn(message);
                else window.utils.debugLog(message);
            }
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
            if (window.utils) window.utils.debugLog('User not authenticated, redirecting...');
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
        if (window.utils) window.utils.debugError('Error loading profile data:', error);
        const loadingIndicator = document.getElementById('loadingIndicator');
        if (loadingIndicator) {
            const errorMsg = error.message || 'Failed to load profile';
            loadingIndicator.textContent = `Error: ${errorMsg}. Please refresh the page.`;
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
            if (window.utils) window.utils.debugError('Required DOM elements not found');
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
        
        // Display profile photo
        displayProfilePhoto(profile.profile_photo);
        
    } catch (error) {
        if (window.utils) window.utils.debugError('Error loading profile:', error);
        const loadingIndicator = document.getElementById('loadingIndicator');
        const profileInfo = document.getElementById('profileInfo');
        
        if (loadingIndicator) {
            const errorMsg = error.message || 'Unknown error';
            loadingIndicator.textContent = `Error loading profile: ${errorMsg}`;
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
    const profilePhotoActions = document.getElementById('profilePhotoActions');
    
    const isReadonly = emailInput.readOnly;
    
    emailInput.readOnly = !isReadonly;
    addressInput.readOnly = !isReadonly;
    phoneInput.readOnly = !isReadonly;
    
    if (isReadonly) {
        saveBtn.style.display = 'block';
        editBtn.textContent = 'Cancel';
        if (profilePhotoActions) profilePhotoActions.style.display = 'block';
    } else {
        saveBtn.style.display = 'none';
        editBtn.textContent = 'Edit Profile';
        if (profilePhotoActions) profilePhotoActions.style.display = 'none';
        // Cancel any pending photo upload
        cancelProfilePhotoUpload();
        // Reload profile to reset changes
        loadProfile();
    }
}

// Display profile photo
function displayProfilePhoto(photoUrl) {
    const photoDisplay = document.getElementById('profilePhotoDisplay');
    const photoPlaceholder = document.getElementById('profilePhotoPlaceholder');
    const removePhotoBtn = document.getElementById('removePhotoBtn');

    if (photoUrl) {
        if (photoDisplay) {
            // Use unified image URL converter for consistent handling
            let fullUrl = photoUrl;

            // Handle relative URLs (e.g., /uploads/profile_xxx.jpg)
            if (photoUrl.startsWith('/uploads/') || (!photoUrl.startsWith('http://') && !photoUrl.startsWith('https://') && !photoUrl.startsWith('data:'))) {
                const apiBaseUrl = (typeof API_BASE_URL !== 'undefined') ? API_BASE_URL : 'http://localhost:5000/api';
                const baseUrl = apiBaseUrl.replace('/api', '');
                fullUrl = baseUrl + (photoUrl.startsWith('/') ? photoUrl : '/' + photoUrl);
            }

            photoDisplay.src = fullUrl;
            photoDisplay.style.display = 'block';
            photoDisplay.onerror = function() {
                console.error('Failed to load profile photo:', fullUrl);
                this.style.display = 'none';
                if (photoPlaceholder) photoPlaceholder.style.display = 'flex';
            };
            photoDisplay.onload = function() {
                console.log('✅ Profile photo loaded successfully:', fullUrl.substring(0, 100));
            };
        }
        if (photoPlaceholder) photoPlaceholder.style.display = 'none';
        if (removePhotoBtn) removePhotoBtn.style.display = 'inline-block';
    } else {
        if (photoDisplay) photoDisplay.style.display = 'none';
        if (photoPlaceholder) photoPlaceholder.style.display = 'flex';
        if (removePhotoBtn) removePhotoBtn.style.display = 'none';
    }
}

// Handle profile photo selection
let selectedProfilePhoto = null;
function handleProfilePhotoSelect(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
        showToast('Please select an image file', 'error');
        return;
    }
    
    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
        showToast('Image size must be less than 5MB', 'error');
        return;
    }
    
    selectedProfilePhoto = file;
    
    // Show preview
    const reader = new FileReader();
    reader.onload = function(e) {
        const preview = document.getElementById('profilePhotoPreview');
        const previewImg = document.getElementById('profilePhotoPreviewImg');
        if (preview && previewImg) {
            previewImg.src = e.target.result;
            preview.style.display = 'block';
        }
    };
    reader.readAsDataURL(file);
}

// Save profile photo
async function saveProfilePhoto() {
    if (!selectedProfilePhoto) {
        showToast('Please select a photo first', 'error');
        return;
    }
    
    try {
        // Get CSRF token if available
        let csrfToken = null;
        if (typeof fetchCSRFToken !== 'undefined') {
            csrfToken = await fetchCSRFToken();
        } else if (typeof window !== 'undefined' && window.csrfToken) {
            csrfToken = window.csrfToken;
        }
        
        const formData = new FormData();
        formData.append('profile_photo', selectedProfilePhoto);
        
        // Also include other profile fields to avoid overwriting
        const email = document.getElementById('profileEmail').value;
        const address = document.getElementById('profileAddress').value;
        const phone = document.getElementById('profilePhone').value;
        
        formData.append('email', email);
        formData.append('address', address);
        formData.append('phone', phone);
        
        // Get API base URL from api.js or use default
        const apiBaseUrl = (typeof API_BASE_URL !== 'undefined') ? API_BASE_URL : 'http://localhost:5000/api';
        const baseUrl = apiBaseUrl.replace('/api', '');
        
        // Get CSRF token if available (try multiple methods)
        let finalCsrfToken = csrfToken;
        if (!finalCsrfToken && typeof fetchCSRFToken !== 'undefined') {
            finalCsrfToken = await fetchCSRFToken();
        } else if (!finalCsrfToken && typeof window !== 'undefined' && window.csrfToken) {
            finalCsrfToken = window.csrfToken;
        } else if (!finalCsrfToken) {
            // Try to fetch CSRF token directly
            try {
                const csrfResponse = await fetch(`${baseUrl}/api/csrf-token`, {
                    credentials: 'include'
                });
                if (csrfResponse.ok) {
                    const csrfData = await csrfResponse.json();
                    finalCsrfToken = csrfData.csrf_token;
                }
            } catch (e) {
                console.warn('Could not fetch CSRF token:', e);
            }
        }
        
        // Prepare headers
        const headers = {};
        if (finalCsrfToken) {
            headers['X-CSRFToken'] = finalCsrfToken;
        }
        
        const response = await fetch(`${baseUrl}/api/user/profile`, {
            method: 'PUT',
            credentials: 'include',
            headers: headers,
            body: formData
        });
        
        if (!response.ok) {
            let errorMessage = 'Failed to upload photo';
            try {
                const error = await response.json();
                errorMessage = error.error || errorMessage;
            } catch (e) {
                errorMessage = `Server error: ${response.status} ${response.statusText}`;
            }
            throw new Error(errorMessage);
        }
        
        let result;
        try {
            result = await response.json();
        } catch (e) {
            console.error('Failed to parse response:', e);
            throw new Error('Invalid response from server');
        }
        
        showToast('Profile photo updated successfully!', 'success');
        
        // Update display
        if (result.profile_photo) {
            displayProfilePhoto(result.profile_photo);
        }
        
        // Clear preview
        cancelProfilePhotoUpload();
        
        // Reload profile to get updated data
        await loadProfile();
        
    } catch (error) {
        console.error('Error uploading profile photo:', error);
        showToast(error.message || 'Failed to upload profile photo', 'error');
    }
}

// Cancel profile photo upload
function cancelProfilePhotoUpload() {
    selectedProfilePhoto = null;
    const preview = document.getElementById('profilePhotoPreview');
    const photoInput = document.getElementById('profilePhotoInput');
    if (preview) preview.style.display = 'none';
    if (photoInput) photoInput.value = '';
}

// Remove profile photo
async function removeProfilePhoto() {
    if (!confirm('Are you sure you want to remove your profile photo?')) {
        return;
    }
    
    try {
        // Update profile with empty profile_photo
        await UserAPI.updateProfile({ profile_photo: '' });
        showToast('Profile photo removed successfully!', 'success');
        displayProfilePhoto(null);
        await loadProfile();
    } catch (error) {
        showToast(error.message || 'Failed to remove profile photo', 'error');
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

// Avatar Selection Functions
const PRESET_AVATARS = [
    '👤', '👨', '👩', '🧑', '👨‍💼', '👩‍💼', '👨‍🔬', '👩‍🔬',
    '👨‍⚕️', '👩‍⚕️', '👨‍🏫', '👩‍🏫', '👨‍🎓', '👩‍🎓', '👨‍🎤', '👩‍🎤',
    '👨‍🎨', '👩‍🎨', '👨‍🚀', '👩‍🚀', '👨‍✈️', '👩‍✈️', '👨‍🚒', '👩‍🚒',
    '🧑‍💻', '🧑‍🏭', '🧑‍🔧', '🧑‍🔬', '🧑‍⚕️', '🧑‍🏫', '🧑‍🎓', '🧑‍🎤',
    '🧑‍🎨', '🧑‍🚀', '🧑‍✈️', '🧑‍🚒', '🦸', '🦸‍♂️', '🦸‍♀️', '🧙',
    '🧙‍♂️', '🧙‍♀️', '🧚', '🧚‍♂️', '🧚‍♀️', '🧛', '🧛‍♂️', '🧛‍♀️',
    '🧜', '🧜‍♂️', '🧜‍♀️', '🧝', '🧝‍♂️', '🧝‍♀️', '🧞', '🧞‍♂️',
    '🧞‍♀️', '🧟', '🧟‍♂️', '🧟‍♀️', '🤴', '👸', '🤵', '👰',
    '🤰', '🤱', '👼', '🎅', '🤶', '🦸', '🦹', '🧑‍🎄'
];

let selectedAvatar = null;
let selectedCustomAvatar = null;

// Open avatar selector modal
function openAvatarSelector() {
    const modal = document.getElementById('avatarSelectorModal');
    if (modal) {
        modal.style.display = 'block';
        document.body.style.overflow = 'hidden';
        populateAvatars();
        // Reset to preset tab
        switchAvatarTab('preset');
    }
}

// Close avatar selector modal
function closeAvatarSelector() {
    const modal = document.getElementById('avatarSelectorModal');
    if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = '';
    }
    // Reset selections
    selectedAvatar = null;
    cancelCustomAvatar();
}

// Switch between preset and custom tabs
function switchAvatarTab(tab) {
    const presetTab = document.getElementById('presetTab');
    const customTab = document.getElementById('customTab');
    const presetSection = document.getElementById('presetAvatarsSection');
    const customSection = document.getElementById('customUploadSection');
    
    if (tab === 'preset') {
        if (presetTab) presetTab.classList.add('active');
        if (customTab) customTab.classList.remove('active');
        if (presetSection) presetSection.style.display = 'block';
        if (customSection) customSection.style.display = 'none';
    } else {
        if (presetTab) presetTab.classList.remove('active');
        if (customTab) customTab.classList.add('active');
        if (presetSection) presetSection.style.display = 'none';
        if (customSection) customSection.style.display = 'block';
    }
}

// Populate avatars grid
function populateAvatars() {
    const grid = document.getElementById('avatarsGrid');
    if (!grid) return;
    
    grid.innerHTML = PRESET_AVATARS.map((avatar, index) => `
        <div class="avatar-option" onclick="selectPresetAvatar('${avatar}', ${index})" data-avatar="${avatar}">
            <div class="avatar-emoji">${avatar}</div>
        </div>
    `).join('');
}

// Select preset avatar
async function selectPresetAvatar(avatar, index) {
    selectedAvatar = avatar;
    
    // Update UI - highlight selected
    document.querySelectorAll('.avatar-option').forEach(el => {
        el.classList.remove('selected');
    });
    const selectedEl = document.querySelector(`[data-avatar="${avatar}"]`);
    if (selectedEl) {
        selectedEl.classList.add('selected');
    }
    
    // Create a data URL from emoji for immediate display
    // For backend storage, we'll use a service that generates avatar images from emojis
    // Using DiceBear Avatars API which supports emoji
    const avatarUrl = `https://api.dicebear.com/7.x/avataaars/svg?seed=${encodeURIComponent(avatar)}&backgroundColor=ff6600`;
    
    // Alternative: Use emoji directly as data URL (simpler but less professional)
    // For now, let's use a combination - store emoji and generate image URL
    try {
        // First, try to upload the emoji as a simple image
        // Create a canvas with the emoji and convert to data URL
        const canvas = document.createElement('canvas');
        canvas.width = 200;
        canvas.height = 200;
        const ctx = canvas.getContext('2d');
        
        // Draw background
        ctx.fillStyle = '#ff6600';
        ctx.fillRect(0, 0, 200, 200);
        
        // Draw emoji
        ctx.font = '120px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(avatar, 100, 100);
        
        // Convert to blob and upload
        canvas.toBlob(async (blob) => {
            try {
                // Upload the generated image
                const uploadResult = await ImageAPI.upload(blob);
                
                if (!uploadResult || !uploadResult.url) {
                    throw new Error('Failed to upload avatar image');
                }
                
                // Update profile with uploaded image URL
                await UserAPI.updateProfile({ profile_photo: uploadResult.url });
                showToast('Avatar updated successfully!', 'success');
                
                // Update display
                displayProfilePhoto(uploadResult.url);
                
                // Close modal
                closeAvatarSelector();
                
                // Reload profile
                await loadProfile();
            } catch (error) {
                // Fallback: use DiceBear API URL
                try {
                    await UserAPI.updateProfile({ profile_photo: avatarUrl });
                    showToast('Avatar updated successfully!', 'success');
                    displayProfilePhoto(avatarUrl);
                    closeAvatarSelector();
                    await loadProfile();
                } catch (fallbackError) {
                    showToast(fallbackError.message || 'Failed to update avatar', 'error');
                }
            }
        }, 'image/png');
    } catch (error) {
        showToast(error.message || 'Failed to update avatar', 'error');
    }
}

// Handle custom avatar selection
function handleCustomAvatarSelect(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
        showToast('Please select an image file', 'error');
        return;
    }
    
    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
        showToast('Image size must be less than 5MB', 'error');
        return;
    }
    
    selectedCustomAvatar = file;
    
    // Show preview
    const reader = new FileReader();
    reader.onload = function(e) {
        const preview = document.getElementById('customAvatarPreview');
        const previewImg = document.getElementById('customAvatarPreviewImg');
        if (preview && previewImg) {
            previewImg.src = e.target.result;
            preview.style.display = 'block';
        }
    };
    reader.readAsDataURL(file);
}

// Save custom avatar
async function saveCustomAvatar() {
    if (!selectedCustomAvatar) {
        showToast('Please select a photo first', 'error');
        return;
    }
    
    try {
        // Upload image first
        const uploadResult = await ImageAPI.upload(selectedCustomAvatar);
        
        if (!uploadResult || !uploadResult.url) {
            throw new Error('Failed to upload image');
        }
        
        // Update profile with uploaded image URL
        await UserAPI.updateProfile({ profile_photo: uploadResult.url });
        showToast('Profile photo updated successfully!', 'success');
        
        // Update display
        displayProfilePhoto(uploadResult.url);
        
        // Close modal
        closeAvatarSelector();
        
        // Reload profile
        await loadProfile();
    } catch (error) {
        showToast(error.message || 'Failed to upload profile photo', 'error');
    }
}

// Cancel custom avatar
function cancelCustomAvatar() {
    selectedCustomAvatar = null;
    const preview = document.getElementById('customAvatarPreview');
    const avatarInput = document.getElementById('customAvatarInput');
    if (preview) preview.style.display = 'none';
    if (avatarInput) avatarInput.value = '';
}

// Close modal when clicking outside
window.onclick = function(event) {
    const avatarModal = document.getElementById('avatarSelectorModal');
    if (event.target === avatarModal) {
        closeAvatarSelector();
    }
}


