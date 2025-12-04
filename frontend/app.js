// Global state
let currentUser = null;
let currentView = 'grid';
let authChecked = false;

// Check authentication status on page load
document.addEventListener('DOMContentLoaded', async () => {
    // Skip if on profile page to prevent conflicts
    if (window.skipAppJs || window.location.pathname.includes('profile.html')) {
        // Still setup biometric modal reset even on profile page
        setupBiometricModalReset();
        initializeDatePicker();
        return;
    }
    
    // Check auth in background - don't block page loading
    checkAuth().then(() => {
        authChecked = true;
    }).catch(() => {
        authChecked = true; // Mark as checked even if auth fails
    });
    
    // Load content immediately without waiting for auth
    if (document.getElementById('featuredCarousel')) {
        loadFeaturedCarousel();
        loadFeaturedAuctions();
        loadCategories();
    }
    
    // Initialize date picker
    initializeDatePicker();
    // Initialize password strength checker
    initializePasswordStrength();
    
    // Listen for language changes to update dynamic content
    document.addEventListener('languageChanged', function(event) {
        const newLang = event.detail.language;
        // Update dynamic content when language changes
        if (currentUser && document.getElementById('userName')) {
            // Username doesn't need translation, but re-apply if needed
        }
        
        // Re-translate any dynamically generated content
        if (document.getElementById('featuredCarousel')) {
            // Re-load to get translated content
            setTimeout(() => {
                loadFeaturedCarousel();
                loadFeaturedAuctions();
            }, 300);
        }
    });
});

// Initialize modern date picker display
function initializeDatePicker() {
    const birthDateInput = document.getElementById('registerBirthDate');
    const datePickerText = document.getElementById('registerBirthDateText');
    
    if (!birthDateInput || !datePickerText) return;
    
    // Function to format and update date display
    function updateDateDisplay() {
        updateDatePickerDisplay(birthDateInput);
    }
    
    // Update display on input change
    birthDateInput.addEventListener('change', updateDateDisplay);
    birthDateInput.addEventListener('input', updateDateDisplay);
    
    // Initial update
    updateDateDisplay();
}

// Password visibility toggle
function togglePasswordVisibility(inputId, button) {
    const passwordInput = document.getElementById(inputId);
    if (!passwordInput) return;
    
    const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
    passwordInput.setAttribute('type', type);
    
    const eyeIcon = button.querySelector('.eye-icon');
    if (eyeIcon) {
        eyeIcon.textContent = type === 'password' ? '👁️' : '🙈';
    }
}

// Standard password validation
function validatePassword(password) {
    const errors = [];
    
    if (!password || password.length < 8) {
        errors.push('Password must be at least 8 characters long');
    }
    if (!/[a-z]/.test(password)) {
        errors.push('Password must contain at least one lowercase letter');
    }
    if (!/[A-Z]/.test(password)) {
        errors.push('Password must contain at least one uppercase letter');
    }
    if (!/[0-9]/.test(password)) {
        errors.push('Password must contain at least one number');
    }
    if (!/[^a-zA-Z0-9]/.test(password)) {
        errors.push('Password must contain at least one special character (!@#$%^&*()_+-=[]{}|;:,.<>?)');
    }
    
    return {
        isValid: errors.length === 0,
        errors: errors
    };
}

// Password strength checker with requirement indicators
function checkPasswordStrength(password) {
    const strengthIndicator = document.getElementById('passwordStrength');
    const requirementsList = document.getElementById('passwordRequirements');
    
    if (!password || password.length === 0) {
        if (strengthIndicator) strengthIndicator.className = 'password-strength';
        if (requirementsList) requirementsList.style.display = 'none';
        return;
    }
    
    // Show requirements list
    if (requirementsList) {
        requirementsList.style.display = 'block';
    }
    
    // Check each requirement
    const checks = {
        length: password.length >= 8,
        lowercase: /[a-z]/.test(password),
        uppercase: /[A-Z]/.test(password),
        number: /[0-9]/.test(password),
        special: /[^a-zA-Z0-9]/.test(password)
    };
    
    // Update requirement indicators
    updateRequirementIndicator('req-length', checks.length);
    updateRequirementIndicator('req-lowercase', checks.lowercase);
    updateRequirementIndicator('req-uppercase', checks.uppercase);
    updateRequirementIndicator('req-number', checks.number);
    updateRequirementIndicator('req-special', checks.special);
    
    // Calculate strength for visual indicator
    const metCount = Object.values(checks).filter(v => v).length;
    if (strengthIndicator) {
        if (metCount === 5) {
            strengthIndicator.className = 'password-strength strong';
        } else if (metCount >= 3) {
            strengthIndicator.className = 'password-strength medium';
        } else {
            strengthIndicator.className = 'password-strength weak';
        }
    }
}

// Update individual requirement indicator
function updateRequirementIndicator(id, met) {
    const indicator = document.getElementById(id);
    if (indicator) {
        if (met) {
            indicator.className = 'requirement-item met';
            indicator.querySelector('.requirement-icon').textContent = '✓';
        } else {
            indicator.className = 'requirement-item';
            indicator.querySelector('.requirement-icon').textContent = '○';
        }
    }
}

// Initialize password strength checker
function initializePasswordStrength() {
    const passwordInput = document.getElementById('registerPassword');
    if (!passwordInput) return;
    
    passwordInput.addEventListener('input', function() {
        checkPasswordStrength(this.value);
    });
    
    passwordInput.addEventListener('blur', function() {
        if (!this.value || this.value.length === 0) {
            const strengthIndicator = document.getElementById('passwordStrength');
            if (strengthIndicator) {
                strengthIndicator.className = 'password-strength';
            }
        }
    });
}

// Helper function to update date picker display text
function updateDatePickerDisplay(dateInput) {
    const datePickerText = document.getElementById('registerBirthDateText');
    if (!datePickerText) return;
    
    const dateValue = dateInput.value;
    if (dateValue) {
        const date = new Date(dateValue + 'T00:00:00');
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        const formattedDate = date.toLocaleDateString('en-US', options);
        datePickerText.textContent = formattedDate;
    } else {
        datePickerText.textContent = (window.i18n && window.i18n.t) ? window.i18n.t('register.clickToChooseDate', 'Click to choose date') : 'Click to choose date';
    }
}

// Authentication functions
async function checkAuth() {
    try {
        console.log('[AUTH] Checking authentication...');
        const response = await UserAPI.getProfile();
        console.log('[AUTH] Auth check successful, user:', response.username, 'role:', response.role);
        currentUser = response;
        updateNavAuth(true);
        if (document.getElementById('userName')) {
            document.getElementById('userName').textContent = response.username;
        }
        // Show admin link if user is admin
        if (response.role === 'admin') {
            console.log('[AUTH] User is admin, showing admin link');
            const navMenu = document.getElementById('navMenu');
            if (navMenu) {
                let adminLink = document.getElementById('adminLink');
                if (!adminLink) {
                    adminLink = document.createElement('a');
                    adminLink.href = 'admin.html';
                    adminLink.className = 'nav-link';
                    adminLink.id = 'adminLink';
                    adminLink.textContent = (window.i18n && window.i18n.t) ? window.i18n.t('messages.admin', 'Admin') : 'Admin';
                    // Safely insert admin link - append to navMenu instead of using insertBefore
                    // to avoid errors when navUser is not a direct child of navMenu
                    navMenu.appendChild(adminLink);
                }
                adminLink.style.display = 'block';
            }
        } else {
            const adminLink = document.getElementById('adminLink');
            if (adminLink) {
                adminLink.style.display = 'none';
            }
        }

        // Load user-specific sections after authentication
        if (document.getElementById('myAuctionsSection')) {
            loadMyAuctions();
            loadMyBids();
        }
    } catch (error) {
        console.error('[AUTH] Auth check failed:', error);
        // Silently handle authentication errors (401) - user is just not logged in
        if (error.status === 401 || error.message.includes('Authentication required')) {
            console.log('[AUTH] User not authenticated (401)');
            updateNavAuth(false);
            currentUser = null;
        } else {
            // Only log non-auth errors
            if (window.DEBUG_MODE) {
                console.error('Auth check error:', error);
            }
            updateNavAuth(false);
        }
    }
}

function updateNavAuth(isAuthenticated) {
    const navAuth = document.getElementById('navAuth');
    const navUser = document.getElementById('navUser');
    const myAccountDropdown = document.getElementById('myAccountDropdown');
    const myBidsNavLink = document.getElementById('myBidsNavLink');
    const paymentsNavLink = document.getElementById('paymentsNavLink');
    const userName = document.getElementById('userName');
    const userAvatar = document.getElementById('userAvatar');

    if (navAuth && navUser) {
        if (isAuthenticated) {
            navAuth.style.display = 'none';
            navUser.style.display = 'block';

            // Show My Account dropdown
            if (myAccountDropdown) {
                myAccountDropdown.style.display = 'block';
            }

            // Show My Bids link in main nav
            if (myBidsNavLink) {
                myBidsNavLink.style.display = 'flex';
            }

            // Show Payments link in main nav
            if (paymentsNavLink) {
                paymentsNavLink.style.display = 'flex';
            }

            // Update user info
            if (currentUser) {
                if (userName) {
                    userName.textContent = currentUser.username || 'User';
                }
                if (userAvatar) {
                    if (currentUser.profile_photo) {
                        userAvatar.src = currentUser.profile_photo;
                        userAvatar.style.display = 'block';
                    } else {
                        // Use default avatar
                        userAvatar.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="%23ff6600" stroke-width="2"%3E%3Cpath d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"%3E%3C/path%3E%3Ccircle cx="12" cy="7" r="4"%3E%3C/circle%3E%3C/svg%3E';
                        userAvatar.style.display = 'block';
                    }
                }
            }
        } else {
            navAuth.style.display = 'flex';
            navUser.style.display = 'none';

            // Hide My Account dropdown
            if (myAccountDropdown) {
                myAccountDropdown.style.display = 'none';
            }

            // Hide My Bids link
            if (myBidsNavLink) {
                myBidsNavLink.style.display = 'none';
            }

            // Hide Payments link
            if (paymentsNavLink) {
                paymentsNavLink.style.display = 'none';
            }
        }
    }
}

async function handleLogin(event) {
    event.preventDefault();

	    // Check if backend is reachable first
	    try {
	        // Use the same base URL as the global API configuration, defaulting to localhost:5000
	        const API_BASE = (typeof API_BASE_URL !== 'undefined' && API_BASE_URL
	            ? API_BASE_URL
	            : 'http://localhost:5000/api').replace('/api', '');
        const testResponse = await fetch(`${API_BASE}/api/health`);
        if (!testResponse.ok) {
            throw new Error('Backend server is not responding correctly');
        }
    } catch (error) {
        showToast('Cannot connect to server! Make sure the backend is running. Check the server logs.', 'error');
        debugError('Backend connection error:', error);
        return;
    }
	    
	    const username = document.getElementById('loginUsername').value;
	    const password = document.getElementById('loginPassword').value;
	    
	    const submitBtn = event.target.querySelector('button[type="submit"]');
	    const originalText = submitBtn.textContent;
	    submitBtn.disabled = true;
	    submitBtn.textContent = (window.i18n && window.i18n.t) ? window.i18n.t('auth.loggingIn', 'Logging in...') : 'Logging in...';
	    
	    try {
	        console.log('[LOGIN] Attempting login for user:', username);
	        const response = await UserAPI.login(username, password);
	        console.log('[LOGIN] Login successful, response:', response);
	        currentUser = response.user;
	        updateNavAuth(true);
	        if (document.getElementById('userName')) {
	            document.getElementById('userName').textContent = response.user.username;
	        }
	        closeModal('loginModal');
	        const successMsg = (window.i18n && window.i18n.t) ? window.i18n.t('auth.loginSuccess', 'Login successful!') : 'Login successful!';
	        showToast(successMsg, 'success');

	        // Load user-specific sections immediately after login (home page)
	        if (document.getElementById('myAuctionsSection')) {
	            loadMyAuctions();
	            loadMyBids();
	        }

	        // Re-run auth check to sync navbar and account menus without full reload
	        try {
	            console.log('[LOGIN] Running post-login auth check...');
	            await checkAuth();
	            console.log('[LOGIN] Post-login auth check successful');
	        } catch (e) {
	            console.error('[LOGIN] Post-login auth check failed:', e);
	            debugError('Post-login auth check failed:', e);
	        }
	    } catch (error) {
	        console.error('[LOGIN] Login error:', error);
	        debugError('Login error:', error);
	        const errorMsg = (window.i18n && window.i18n.t) ? (error.message || window.i18n.t('auth.loginFailed', 'Login failed. Please check your credentials.')) : (error.message || 'Login failed. Please check your credentials.');
	        showToast(errorMsg, 'error');
	    } finally {
	        submitBtn.disabled = false;
	        submitBtn.textContent = originalText;
	    }
}

async function handleRegister(event) {
    event.preventDefault();

	    // Check if backend is reachable first
	    try {
	        // Use the same base URL as the global API configuration, defaulting to localhost:5000
	        const API_BASE = (typeof API_BASE_URL !== 'undefined' && API_BASE_URL
	            ? API_BASE_URL
	            : 'http://localhost:5000/api').replace('/api', '');
        const testResponse = await fetch(`${API_BASE}/api/health`);
        if (!testResponse.ok) {
            throw new Error('Backend server is not responding correctly');
        }
    } catch (error) {
        showToast('Cannot connect to server! Make sure the backend is running. Check the server logs.', 'error');
        debugError('Backend connection error:', error);
        return;
    }
    
    // Validate password before submission
    const password = document.getElementById('registerPassword').value;
    const passwordValidation = validatePassword(password);
    if (!passwordValidation.isValid) {
        const errorMsg = 'Password does not meet requirements:\n' + passwordValidation.errors.join('\n');
        showToast(errorMsg, 'error');
        
        // Focus on password field
        document.getElementById('registerPassword').focus();
        return;
    }
    
    // Get form data
    const formData = new FormData();
    formData.append('username', document.getElementById('registerUsername').value);
    formData.append('email', document.getElementById('registerEmail').value);
    formData.append('password', password);
    formData.append('id_number', document.getElementById('registerIdNumber').value);
    formData.append('birth_date', document.getElementById('registerBirthDate').value);
    formData.append('address', document.getElementById('registerAddress').value);
    formData.append('phone', document.getElementById('registerPhone').value);
    
	    // Add profile photo if selected (if the field exists in the layout)
	    const photoInput = document.getElementById('profilePhoto');
	    if (photoInput && photoInput.files && photoInput.files.length > 0) {
	        formData.append('profile_photo', photoInput.files[0]);
	    }
    
    // Show loading
    const submitBtn = event.target.querySelector('button[type="submit"]');
    const originalHTML = submitBtn.innerHTML;
    submitBtn.disabled = true;
    const registeringText = (window.i18n && window.i18n.t) ? window.i18n.t('auth.registering', 'Registering...') : 'Registering...';
    submitBtn.innerHTML = '<span class="btn-content"><span class="btn-text">' + registeringText + '</span><span class="btn-icon">⏳</span></span>';
    
    try {
        // Use FormData for multipart/form-data upload
        const baseUrl = API_BASE_URL.replace('/api', '');
        const response = await fetch(`${baseUrl}/api/register`, {
            method: 'POST',
            body: formData,
            credentials: 'include'
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Registration failed');
        }
        
        // Clear all form fields
        resetRegistrationForm();
        
        // Close modal
        closeModal('registerModal');
        
        // Show welcome message if available
        if (data.welcome_message) {
            showWelcomeMessage(data.welcome_message, data.username);
        } else {
            // Fallback to simple success message
            showToast('Registration successful! Please login.', 'success');
        }
        
        // Open login modal after a short delay
        setTimeout(() => {
            showLogin();
        }, data.welcome_message ? 3000 : 500);
    } catch (error) {
        debugError('Registration error:', error);
        const errorMsg = error.message || 'Registration failed. Please try again.';
        showToast(errorMsg, 'error');
        
        // Show error in form if there's an error element
        const errorElement = document.getElementById('registerForm').querySelector('.error-message');
        if (errorElement) {
            errorElement.textContent = errorMsg;
            errorElement.style.display = 'block';
        }
    } finally {
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalHTML;
    }
}

// Handle photo selection
function handlePhotoSelect(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    // Validate file type
    if (!file.type.startsWith('image/')) {
        showToast('Please select an image file', 'error');
        event.target.value = '';
        return;
    }
    
    // Validate file size (5MB)
    if (file.size > 5 * 1024 * 1024) {
        showToast('Image size must be less than 5MB', 'error');
        event.target.value = '';
        return;
    }
    
    // Preview image
    const reader = new FileReader();
    reader.onload = function(e) {
        const previewImg = document.getElementById('photoPreviewImg');
        const placeholder = document.querySelector('.photo-placeholder');
        const removeBtn = document.getElementById('photoRemoveBtn');
        
        previewImg.src = e.target.result;
        previewImg.style.display = 'block';
        if (placeholder) placeholder.style.display = 'none';
        if (removeBtn) removeBtn.style.display = 'block';
    };
    reader.readAsDataURL(file);
}

// Remove photo
function removePhoto() {
	    // Make this function safe even when the photo fields are not present
	    const photoInput = document.getElementById('profilePhoto');
	    const previewImg = document.getElementById('photoPreviewImg');
	    const placeholder = document.querySelector('.photo-placeholder');
	    const removeBtn = document.getElementById('photoRemoveBtn');
	    
	    if (photoInput) {
	        photoInput.value = '';
	    }
	    if (previewImg) {
	        previewImg.src = '';
	        previewImg.style.display = 'none';
	    }
	    if (placeholder) placeholder.style.display = 'flex';
	    if (removeBtn) removeBtn.style.display = 'none';
	}

async function logout() {
    try {
        await UserAPI.logout();
        currentUser = null;
        updateNavAuth(false);
        showToast('Logged out successfully', 'success');
        window.location.href = 'index.html';
    } catch (error) {
        showToast('Logout failed', 'error');
    }
}

// Modal functions
function showLogin() {
    document.getElementById('loginModal').style.display = 'block';
}

function showRegister() {
    // Reset form before showing
    resetRegistrationFormFields();
    
    // Show modal
    document.getElementById('registerModal').style.display = 'block';
}

// Reset only form fields
function resetRegistrationFormFields() {
    const form = document.getElementById('registerForm');
    if (!form) return;
    
    // Use native form reset method
    try {
        form.reset();
    } catch (e) {
        debugWarn('Form reset() method failed');
    }
    
    // Reset photo preview
    removePhoto();
    
    // Manually clear specific fields
    const usernameField = document.getElementById('registerUsername');
    const emailField = document.getElementById('registerEmail');
    const passwordField = document.getElementById('registerPassword');
    const idNumberField = document.getElementById('registerIdNumber');
    const birthDateField = document.getElementById('registerBirthDate');
    const addressField = document.getElementById('registerAddress');
    const phoneField = document.getElementById('registerPhone');
    
    if (usernameField) usernameField.value = '';
    if (emailField) emailField.value = '';
    if (passwordField) passwordField.value = '';
    if (idNumberField) idNumberField.value = '';
    if (birthDateField) {
        birthDateField.value = '';
        // Reset date picker display
        const datePickerText = document.getElementById('registerBirthDateText');
        if (datePickerText) datePickerText.textContent = (window.i18n && window.i18n.t) ? window.i18n.t('register.selectDateOfBirth', 'Select your date of birth') : 'Select your date of birth';
    }
    if (addressField) addressField.value = '';
    if (phoneField) phoneField.value = '';
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Reset registration form fields
function resetRegistrationForm() {
    const form = document.getElementById('registerForm');
    if (!form) {
        debugWarn('Register form not found');
        return;
    }
    
    // Use native form reset method (resets all fields to default values)
    try {
        form.reset();
    } catch (e) {
        debugWarn('Form reset() method failed, using manual reset');
    }
    
    // Reset photo preview
    removePhoto();
    
    // Manually reset all form fields as backup
    const allInputs = form.querySelectorAll('input, textarea, select');
    allInputs.forEach(input => {
        if (input.type === 'checkbox' || input.type === 'radio') {
            input.checked = false;
        } else if (input.type !== 'file') {
            input.value = '';
            input.classList.remove('is-invalid', 'is-valid');
        }
    });
    
    // Reset date picker display
    const datePickerText = document.getElementById('registerBirthDateText');
    if (datePickerText) {
        datePickerText.textContent = 'Select your date of birth';
    }
    
    // Reset password strength indicator
    const passwordStrength = document.getElementById('passwordStrength');
    if (passwordStrength) {
        passwordStrength.className = 'password-strength';
    }
    
    // Hide password requirements list
    const passwordRequirements = document.getElementById('passwordRequirements');
    if (passwordRequirements) {
        passwordRequirements.style.display = 'none';
    }
    
    // Reset all requirement indicators
    ['req-length', 'req-lowercase', 'req-uppercase', 'req-number', 'req-special'].forEach(id => {
        const indicator = document.getElementById(id);
        if (indicator) {
            indicator.className = 'requirement-item';
            const icon = indicator.querySelector('.requirement-icon');
            if (icon) icon.textContent = '○';
        }
    });
}

async function logout() {
    try {
        await UserAPI.logout();
        currentUser = null;
        updateNavAuth(false);
        showToast('Logged out successfully', 'success');
        window.location.href = 'index.html';
    } catch (error) {
        debugError('Logout error:', error);
        showToast('Logout failed', 'error');
    }
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Close modal and reset form for registration modal
function closeModalAndReset(modalId) {
    if (modalId === 'registerModal') {
        resetRegistrationForm();
    }
    closeModal(modalId);
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            if (modal.id === 'registerModal') {
                resetRegistrationForm();
                closeModal('registerModal');
            } else {
                modal.style.display = 'none';
            }
        }
    });
};

	// Toast notification
	function showToast(message, type = 'info') {
	    const toast = document.getElementById('toast');
	    if (!toast) {
	        // Fallback if toast element is missing
	        if (typeof alert !== 'undefined') {
	            alert(message);
	        } else {
	            console.log(`[${type}]`, message);
	        }
	        return;
	    }
	    toast.textContent = message;
	    toast.className = `toast ${type}`;
	    toast.style.display = 'block';
	    
	    setTimeout(() => {
	        toast.style.display = 'none';
	    }, 3000);
	}

	// Generic notification helper used by the multi-step registration form
	// This was previously undefined, which broke the Sign Up flow.
	function showNotification(message, type = 'error') {
	    try {
	        // Prefer the enhanced ToastManager if available
	        if (typeof window !== 'undefined' && window.ToastManager && typeof window.ToastManager.show === 'function') {
	            window.ToastManager.show(message, type);
	            return;
	        }
	    } catch (e) {
	        // Ignore and fall back
	    }
	    
	    // Fallback to basic toast implementation
	    if (typeof showToast === 'function') {
	        showToast(message, type);
	    } else if (typeof alert !== 'undefined') {
	        alert(message);
	    } else {
	        console.log(`[${type}]`, message);
	    }
	}

function showWelcomeMessage(welcomeMessage, username) {
    // Create or get welcome modal
    let welcomeModal = document.getElementById('welcomeModal');
    
    if (!welcomeModal) {
        // Create welcome modal if it doesn't exist
        welcomeModal = document.createElement('div');
        welcomeModal.id = 'welcomeModal';
        welcomeModal.className = 'modal';
        welcomeModal.innerHTML = `
            <div class="modal-content modal-large">
                <div class="modal-header">
                    <h2>🎉 Welcome to ZUBID!</h2>
                    <span class="close" onclick="closeModal('welcomeModal')">&times;</span>
                </div>
                <div class="modal-body">
                    <div class="welcome-message" id="welcomeMessageContent"></div>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-primary" onclick="closeModal('welcomeModal'); showLogin();">
                        Get Started
                    </button>
                </div>
            </div>
        `;
        document.body.appendChild(welcomeModal);
    }
    
    // Format the welcome message (preserve line breaks)
    const messageContent = document.getElementById('welcomeMessageContent');
    if (messageContent) {
        // Convert newlines to <br> tags and preserve formatting
        const formattedMessage = welcomeMessage
            .replace(/\n\n/g, '</p><p>')
            .replace(/\n/g, '<br>');
        messageContent.innerHTML = `<p>${formattedMessage}</p>`;
    }
    
    // Show the modal
    welcomeModal.style.display = 'block';
    
    // Also show a toast notification
    showToast(`Welcome ${username}! 🎉`, 'success');
}

// Mobile menu toggle
function toggleMobileMenu() {
    const navMenu = document.getElementById('navMenu');
    const toggle = document.querySelector('.mobile-menu-toggle');
    navMenu.classList.toggle('active');
    toggle.classList.toggle('active');
}

// Initialize dropdown menus
document.addEventListener('DOMContentLoaded', () => {
    // Handle dropdown toggles on mobile
    const dropdownToggles = document.querySelectorAll('.dropdown-toggle');
    dropdownToggles.forEach(toggle => {
        toggle.addEventListener('click', (e) => {
            if (window.innerWidth <= 768) {
                e.preventDefault();
                const dropdown = toggle.closest('.nav-dropdown');
                dropdown.classList.toggle('active');
            }
        });
    });

    // Handle user menu toggle on mobile
    const userMenuToggle = document.querySelector('.user-menu-toggle');
    if (userMenuToggle) {
        userMenuToggle.addEventListener('click', (e) => {
            if (window.innerWidth <= 768) {
                e.preventDefault();
                const navUser = document.getElementById('navUser');
                navUser.classList.toggle('active');
            }
        });
    }

    // Close mobile menu when clicking outside
    document.addEventListener('click', (e) => {
        const navMenu = document.getElementById('navMenu');
        const toggle = document.querySelector('.mobile-menu-toggle');

        if (navMenu && toggle && navMenu.classList.contains('active')) {
            if (!navMenu.contains(e.target) && !toggle.contains(e.target)) {
                navMenu.classList.remove('active');
                toggle.classList.remove('active');
            }
        }
    });
});

// Carousel functions
let currentSlide = 0;
let carouselInterval;
let isLoadingCarousel = false;
let isLoadingFeaturedAuctions = false;

async function loadFeaturedCarousel() {
    if (isLoadingCarousel) {
        console.log('[CAROUSEL] Already loading, skipping...');
        return;
    }
    isLoadingCarousel = true;
    try {
        const featured = await AuctionAPI.getFeatured();
        const carousel = document.getElementById('featuredCarousel');
        const indicators = document.getElementById('carouselIndicators');
        
        if (!featured || featured.length === 0) {
            if (carousel) {
                const noAuctionsMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.noFeaturedAuctions', 'No featured auctions available') : 'No featured auctions available';
                carousel.innerHTML = '<div class="carousel-item"><div class="carousel-placeholder">' + noAuctionsMsg + '</div></div>';
            }
            return;
        }
        
        if (!carousel || !indicators) return;
        
        carousel.innerHTML = '';
        indicators.innerHTML = '';
        
        featured.forEach((auction, index) => {
            const item = document.createElement('div');
            item.className = 'carousel-item';
            
            // Get normalized image URL - prefer featured_image_url for featured auctions
            let imageUrl = getImageUrl(auction.featured_image_url || auction.image_url);
            
            // Replace placeholder dimensions for carousel
            if (imageUrl && imageUrl.includes('placeholder.com')) {
                imageUrl = imageUrl.replace('300x200', '1200x400');
            }
            
            // Final safety check - ensure we NEVER have an empty src
            if (!imageUrl || imageUrl === null || imageUrl === undefined || String(imageUrl).trim() === '' || String(imageUrl) === 'undefined' || String(imageUrl) === 'null') {
                imageUrl = SVG_PLACEHOLDER_CAROUSEL;
            }
            
            // If it's a placeholder, use carousel-sized version
            if (imageUrl === SVG_PLACEHOLDER_SVG) {
                imageUrl = SVG_PLACEHOLDER_CAROUSEL;
            }
            
            if (window.DEBUG_MODE) {
                console.log('Carousel - Auction ID:', auction.id, 'featured_image_url:', auction.featured_image_url, 'image_url:', auction.image_url, 'Final imageUrl:', imageUrl.substring(0, 100));
            }
            
            // Create image element with proper error handling and enhanced quality
            const img = document.createElement('img');
            img.alt = escapeHtml(auction.item_name || 'Auction');
            img.loading = 'eager';
            img.style.width = '100%';
            img.style.height = '100%';
            img.style.objectFit = 'cover';
            img.style.display = 'block';
            // Enhanced image quality settings
            img.style.imageRendering = 'crisp-edges';
            img.style.imageRendering = '-webkit-optimize-contrast';
            img.style.imageRendering = 'optimize-quality';
            img.style.webkitBackfaceVisibility = 'hidden';
            img.style.backfaceVisibility = 'hidden';
            img.style.webkitTransform = 'translateZ(0)';
            img.style.transform = 'translateZ(0)';
            
            // Convert data URI to blob URL if needed (more reliable)
            let finalImageUrl = imageUrl;
            if (imageUrl && imageUrl.startsWith('data:image/')) {
                try {
                    // Try to convert data URI to blob URL
                    const commaIndex = imageUrl.indexOf(',');
                    if (commaIndex !== -1 && commaIndex < imageUrl.length - 1) {
                        const base64Data = imageUrl.substring(commaIndex + 1);
                        if (base64Data && base64Data.length > 100) {
                            const byteCharacters = atob(base64Data);
                            const byteNumbers = new Array(byteCharacters.length);
                            for (let i = 0; i < byteCharacters.length; i++) {
                                byteNumbers[i] = byteCharacters.charCodeAt(i);
                            }
                            const byteArray = new Uint8Array(byteNumbers);
                            const mimeMatch = imageUrl.match(/data:image\/([^;]+)/);
                            const mimeType = mimeMatch ? `image/${mimeMatch[1]}` : 'image/jpeg';
                            const blob = new Blob([byteArray], { type: mimeType });
                            finalImageUrl = URL.createObjectURL(blob);
                            console.log('Converted data URI to blob URL for carousel');
                        }
                    }
                } catch (error) {
                    console.warn('Could not convert data URI to blob, using original:', error);
                    finalImageUrl = imageUrl;
                }
            }
            
            // CRITICAL: Ensure src is NEVER empty - use data URI as absolute fallback
            img.src = String(finalImageUrl).trim() || SVG_PLACEHOLDER_CAROUSEL;
            
            // Error handler - always fallback to SVG data URI
            img.onerror = function() {
                console.error('Image failed to load:', this.src.substring(0, 100));
                // Always use SVG data URI as final fallback (no external dependency)
                if (!this.src.includes('data:image/svg+xml')) {
                    this.src = SVG_PLACEHOLDER_CAROUSEL;
                }
            };
            
            img.onload = function() {
                console.log('✅ Carousel image loaded successfully!');
            };
            
            // Create overlay
            const overlay = document.createElement('div');
            overlay.className = 'carousel-overlay';
            overlay.innerHTML = `
                <h2>${escapeHtml(auction.item_name || 'Auction')}</h2>
                <p>Current Bid: $${(auction.current_bid || 0).toFixed(2)}</p>
                <button class="btn btn-primary" onclick="window.location.href='auction-detail.html?id=${auction.id}'">View Auction</button>
            `;
            
            item.appendChild(img);
            item.appendChild(overlay);
            carousel.appendChild(item);
            
            const indicator = document.createElement('span');
            indicator.className = 'indicator';
            if (index === 0) indicator.classList.add('active');
            indicator.onclick = () => goToSlide(index);
            indicators.appendChild(indicator);
        });
        
        startCarousel();
    } catch (error) {
        debugError('Error loading carousel:', error);
    } finally {
        isLoadingCarousel = false;
    }
}

function changeSlide(direction) {
    const items = document.querySelectorAll('.carousel-item');
    if (items.length === 0) return;
    
    currentSlide += direction;
    if (currentSlide < 0) currentSlide = items.length - 1;
    if (currentSlide >= items.length) currentSlide = 0;
    
    goToSlide(currentSlide);
}

function goToSlide(index) {
    const items = document.querySelectorAll('.carousel-item');
    const indicators = document.querySelectorAll('.carousel-indicators .indicator');
    
    if (items.length === 0) return;
    
    currentSlide = index;
    items.forEach((item, i) => {
        item.style.transform = `translateX(-${index * 100}%)`;
    });
    
    indicators.forEach((indicator, i) => {
        indicator.classList.toggle('active', i === index);
    });
}

function startCarousel() {
    clearInterval(carouselInterval);
    carouselInterval = setInterval(() => {
        changeSlide(1);
    }, 5000);
}

// Load featured auctions for homepage
async function loadFeaturedAuctions() {
    if (isLoadingFeaturedAuctions) {
        console.log('[FEATURED] Already loading, skipping...');
        return;
    }
    isLoadingFeaturedAuctions = true;
    try {
        const response = await AuctionAPI.getAll({ featured: 'true', status: 'active', per_page: 6 });
        const container = document.getElementById('featuredAuctions');

        if (!container) return;

        if (response.auctions && response.auctions.length > 0) {
            // Debug logging
            if (window.DEBUG_MODE) {
                console.log('Featured auctions loaded:', response.auctions.length);
                response.auctions.forEach(auction => {
                    console.log('Auction:', auction.id, auction.item_name, 'image_url:', auction.image_url, 'featured_image_url:', auction.featured_image_url);
                });
            }

            container.innerHTML = response.auctions.map(auction => createAuctionCard(auction)).join('');

            // Initialize previous auctions state for change detection
            if (!window.previousFeaturedAuctionsState) {
                window.previousFeaturedAuctionsState = {};
            }
            response.auctions.forEach(auction => {
                window.previousFeaturedAuctionsState[auction.id] = {
                    status: auction.status,
                    current_bid: auction.current_bid,
                    bid_count: auction.bid_count
                };
            });

            // Start auto-refresh for featured auctions (only once!)
            if (!window.featuredRefreshInterval) {
                startFeaturedAuctionsRefresh();
            }
        } else {
            const noAuctionsMsg = (window.i18n && window.i18n.t) ? window.i18n.t('messages.noFeaturedAuctions', 'No featured auctions available') : 'No featured auctions available';
            container.innerHTML = '<p>' + noAuctionsMsg + '</p>';
        }
    } catch (error) {
        debugError('Error loading featured auctions:', error);
        console.error('Full error:', error);
    } finally {
        isLoadingFeaturedAuctions = false;
    }
}

// Auto-refresh featured auctions - DISABLED to prevent flickering
// Prices will update on page refresh instead
function startFeaturedAuctionsRefresh() {
    // Disabled - was causing flickering and unnecessary server load
    // Users can manually refresh or navigate to see updated prices
    return;
}

// Load categories
async function loadCategories() {
    try {
        const categories = await CategoryAPI.getAll();
        const container = document.getElementById('categoriesGrid');
        
        if (!container) return;
        
        container.innerHTML = categories.map(cat => `
            <div class="category-card" onclick="filterByCategory(${cat.id})">
                <h3>${cat.name}</h3>
                <p>${cat.description || ''}</p>
            </div>
        `).join('');
    } catch (error) {
        debugError('Error loading categories:', error);
    }
}

// Load user's auctions
async function loadMyAuctions() {
    try {
        const section = document.getElementById('myAuctionsSection');
        const container = document.getElementById('myAuctions');
        
        if (!section || !container) {
            debugLog('My Auctions section elements not found');
            return;
        }
        
        if (!currentUser) {
            debugLog('No current user, hiding My Auctions section');
            section.style.display = 'none';
            return;
        }
        
        debugLog('Loading user auctions...');
        const auctions = await AuctionAPI.getUserAuctions();
        debugLog('User auctions loaded:', auctions);
        
        if (auctions && auctions.length > 0) {
            debugLog(`Showing ${auctions.length} user auctions`);
            section.style.display = 'block';
            container.innerHTML = auctions.map(auction => `
                <div class="auction-card" onclick="window.location.href='auction-detail.html?id=${auction.id}'">
                    <div class="auction-card-content">
                        <h3>${auction.item_name}</h3>
                        <div class="auction-stats">
                            <div class="stat">
                                <label>Current Bid</label>
                                <span class="price">$${(auction.current_bid || 0).toFixed(2)}</span>
                            </div>
                            <div class="stat">
                                <label>Status</label>
                                <span class="status-badge ${auction.status || 'active'}">${auction.status || 'active'}</span>
                            </div>
                            <div class="stat">
                                <label>Bids</label>
                                <span>${auction.bid_count || 0}</span>
                            </div>
                        </div>
                        <button class="btn btn-primary btn-block">View Auction</button>
                    </div>
                </div>
            `).join('');
        } else {
            debugLog('No user auctions found');
            // Show section even if empty with a message
            section.style.display = 'none';
        }
    } catch (error) {
        debugError('Error loading my auctions:', error);
        const section = document.getElementById('myAuctionsSection');
        if (section) {
            section.style.display = 'none';
        }
    }
}

// Load user's bids
async function loadMyBids() {
    try {
        const section = document.getElementById('myBidsSection');
        const container = document.getElementById('myBidsContainer');
        
        if (!section || !container) {
            debugLog('My Bids section elements not found');
            return;
        }
        
        if (!currentUser) {
            debugLog('No current user, hiding My Bids section');
            section.style.display = 'none';
            return;
        }
        
        debugLog('Loading user bids...');
        const bids = await BidAPI.getUserBids();
        debugLog('User bids loaded:', bids);
        
        if (bids && bids.length > 0) {
            debugLog(`Showing ${bids.length} user bids`);
            section.style.display = 'block';
            
            // Group bids by auction_id and keep only the highest bid per auction
            const bidsByAuction = {};
            bids.forEach(bid => {
                const auctionId = bid.auction_id;
                if (!bidsByAuction[auctionId] || bid.amount > bidsByAuction[auctionId].amount) {
                    bidsByAuction[auctionId] = bid;
                } else if (bid.amount === bidsByAuction[auctionId].amount) {
                    // If same amount, keep the most recent one
                    const existingDate = new Date(bidsByAuction[auctionId].timestamp);
                    const newDate = new Date(bid.timestamp);
                    if (newDate > existingDate) {
                        bidsByAuction[auctionId] = bid;
                    }
                }
            });
            
            // Convert back to array and sort by timestamp (newest first)
            const uniqueBids = Object.values(bidsByAuction).sort((a, b) => {
                return new Date(b.timestamp) - new Date(a.timestamp);
            });
            
            debugLog(`Showing ${uniqueBids.length} unique bids (from ${bids.length} total bids)`);
            
            container.innerHTML = uniqueBids.map(bid => {
                // Check if user won (for ended auctions) or is winning (for active auctions)
                let statusBadge = '';
                let bidClass = 'losing-bid';
                
                if (bid.auction_status === 'ended') {
                    // For ended auctions, check if user won
                    if (bid.is_winner || (bid.winner_id && bid.amount === bid.current_bid)) {
                        statusBadge = '<span class="winner-badge">🏆 WON</span>';
                        bidClass = 'winner-bid';
                    } else {
                        statusBadge = '<span class="losing-badge">❌ OUTBID</span>';
                        bidClass = 'losing-bid';
                    }
                } else if (bid.auction_status === 'active') {
                    // For active auctions, check if user is currently winning
                    // Use is_winning from backend, or fallback to checking if bid matches current_bid
                    const isWinning = bid.is_winning || (Math.abs(bid.amount - bid.current_bid) <= 0.01);
                    if (isWinning) {
                        statusBadge = '<span class="winner-badge">🏆 WINNING</span>';
                        bidClass = 'winner-bid';
                    } else {
                        statusBadge = '<span class="losing-badge">❌ OUTBID</span>';
                        bidClass = 'losing-bid';
                    }
                } else {
                    // For cancelled or other statuses
                    statusBadge = '<span class="losing-badge">❌ OUTBID</span>';
                    bidClass = 'losing-bid';
                }
                
                return `
                <div class="bid-history-item ${bidClass}" onclick="window.location.href='auction-detail.html?id=${bid.auction_id}'">
                    <div class="bid-info">
                        <div>
                            <div class="bid-header">
                                <strong>${bid.auction_name || 'Unknown Auction'}</strong>
                                ${statusBadge}
                            </div>
                            <div class="bid-details">
                                <span class="bid-amount">$${(bid.amount || 0).toFixed(2)}</span>
                                ${bid.auction_status === 'active' ? `<span class="current-bid-info">Current: $${(bid.current_bid || 0).toFixed(2)}</span>` : ''}
                                ${bid.auction_status === 'ended' ? `<span class="auction-status-badge">Auction Ended</span>` : ''}
                                ${bid.is_auto_bid ? '<span class="auto-bid-badge">Auto-Bid</span>' : ''}
                            </div>
                        </div>
                    </div>
                    <div class="bid-time">${bid.timestamp ? new Date(bid.timestamp).toLocaleString() : 'Unknown time'}</div>
                </div>
            `;
            }).join('');
        } else {
            debugLog('No user bids found');
            section.style.display = 'none';
        }
    } catch (error) {
        debugError('Error loading my bids:', error);
        const section = document.getElementById('myBidsSection');
        if (section) {
            section.style.display = 'none';
        }
    }
}

// Escape HTML helper
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Helper function to truncate text
function truncateText(text, maxLength) {
    if (!text) return '';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
}

// SVG Placeholder Data URI (always works, no external dependency)
const SVG_PLACEHOLDER_SVG = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZmY2NjAwIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIyNCIgZmlsbD0iI2ZmZmZmZiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPk5vIEltYWdlPC90ZXh0Pjwvc3ZnPg==';
const SVG_PLACEHOLDER_CAROUSEL = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIwMCIgaGVpZ2h0PSI0MDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsbD0iI2ZmNjYwMCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMjQiIGZpbGw9IiNmZmZmZmYiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj5ObyBJbWFnZTwvdGV4dD48L3N2Zz4=';

// Get and normalize image URL
function getImageUrl(imageUrl) {
    // Check for null, undefined, or empty string (handle both null and string "null")
    if (imageUrl === null || imageUrl === undefined || imageUrl === 'null' || imageUrl === 'undefined') {
        return SVG_PLACEHOLDER_SVG;
    }
    
    // Convert to string and check if empty
    const urlString = String(imageUrl).trim();
    if (urlString === '' || urlString === 'null' || urlString === 'undefined') {
        return SVG_PLACEHOLDER_SVG;
    }
    
    // Validate data:image URLs - check if they're complete
    if (urlString.startsWith('data:image/')) {
        // Check if data URI is complete (has base64 data after comma)
        const parts = urlString.split(',');
        if (parts.length < 2 || parts[1].length < 10) {
            // Incomplete or invalid data URI
            console.warn('Invalid or incomplete data URI detected:', urlString.substring(0, 50));
            return SVG_PLACEHOLDER_SVG;
        }
        return urlString;
    }
    
    // If already absolute URL (http/https), validate it
    if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
        // Basic URL validation
        try {
            new URL(urlString);
            return urlString;
        } catch (e) {
            console.warn('Invalid URL:', urlString);
            return SVG_PLACEHOLDER_SVG;
        }
    }
    
    // Handle relative URLs - get base URL from API_BASE_URL or default
    let baseUrl = 'http://localhost:5000';
    try {
        if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
            baseUrl = String(API_BASE_URL).replace('/api', '').replace(/\/$/, '');
        } else if (typeof window !== 'undefined' && window.API_BASE_URL) {
            baseUrl = String(window.API_BASE_URL).replace('/api', '').replace(/\/$/, '');
        }
    } catch (e) {
        console.warn('Could not determine base URL, using default:', e);
    }
    
    // Ensure relative URL starts with /
    const relativeUrl = urlString.startsWith('/') ? urlString : '/' + urlString;
    
    return baseUrl + relativeUrl;
}

// Unified image URL converter for all image types (profile, auction, featured)
function convertImageUrlUnified(imageUrl) {
    if (!imageUrl) return SVG_PLACEHOLDER_SVG;

    const urlString = String(imageUrl).trim();
    if (urlString === '' || urlString === 'null' || urlString === 'undefined') {
        return SVG_PLACEHOLDER_SVG;
    }

    // Data URIs - return as-is
    if (urlString.startsWith('data:image/')) {
        return urlString;
    }

    // Absolute URLs - return as-is
    if (urlString.startsWith('http://') || urlString.startsWith('https://')) {
        return urlString;
    }

    // Relative URLs - construct full URL
    let baseUrl = 'http://localhost:5000';
    try {
        if (typeof API_BASE_URL !== 'undefined' && API_BASE_URL) {
            baseUrl = String(API_BASE_URL).replace('/api', '').replace(/\/$/, '');
        } else if (typeof window !== 'undefined' && window.API_BASE_URL) {
            baseUrl = String(window.API_BASE_URL).replace('/api', '').replace(/\/$/, '');
        }
    } catch (e) {
        console.warn('Error parsing API_BASE_URL:', e);
    }

    const relativeUrl = urlString.startsWith('/') ? urlString : '/' + urlString;
    return baseUrl + relativeUrl;
}

// Create auction card HTML
function createAuctionCard(auction) {
    const timeLeft = formatTimeLeft(auction.time_left);
    const statusClass = auction.status === 'active' ? 'active' : 'ended';
    // Use featured_image_url if available and auction is featured, otherwise use regular image_url
    const imageToUse = (auction.featured && auction.featured_image_url) ? auction.featured_image_url : auction.image_url;
    let imageUrl = getImageUrl(imageToUse);
    
    // Final safety check - ensure we NEVER have an empty src
    if (!imageUrl || imageUrl === null || imageUrl === undefined || String(imageUrl).trim() === '' || String(imageUrl) === 'undefined' || String(imageUrl) === 'null') {
        imageUrl = SVG_PLACEHOLDER_SVG;
    }
    
    return `
        <div class="auction-card" onclick="window.location.href='auction-detail.html?id=${auction.id}'">
            <div class="auction-image">
                <img src="${imageUrl || SVG_PLACEHOLDER_SVG}" 
                     alt="${escapeHtml(auction.item_name || 'Auction')}"
                     loading="lazy"
                     style="display: block; width: 100%; height: 100%; object-fit: cover;"
                     onerror="console.error('Image error:', this.src.substring(0, 100)); if (!this.src.includes('data:image/svg+xml')) { this.src='${SVG_PLACEHOLDER_SVG}'; }">
                <span class="status-badge ${statusClass}">${auction.status}</span>
                ${(auction.video_url && typeof auction.video_url === 'string' && auction.video_url.trim() !== '') ? '<button class="video-button" onclick="event.stopPropagation(); window.location.href=\'auction-detail.html?id=' + auction.id + '#video\'" title="Watch Video"><span class="video-icon">🎥</span> Video</button>' : ''}
            </div>
            <div class="auction-card-content">
                <h3>${escapeHtml(auction.item_name || 'Auction')}</h3>
                <p class="auction-description">${escapeHtml(truncateText(auction.description || '', 80))}</p>
                <div class="auction-stats">
                    <div class="stat">
                        <label>Current Bid</label>
                        <span class="price">$${(auction.current_bid || 0).toFixed(2)}</span>
                    </div>
                    <div class="stat">
                        <label>Time Left</label>
                        <span class="time-left">${timeLeft}</span>
                    </div>
                    <div class="stat">
                        <label>Bids</label>
                        <span>${auction.bid_count || 0}</span>
                    </div>
                </div>
                <button class="btn btn-primary btn-block">View Auction</button>
            </div>
        </div>
    `;
}

// Format time left
function formatTimeLeft(seconds) {
    if (seconds <= 0) return 'Ended';
    
    const days = Math.floor(seconds / 86400);
    const hours = Math.floor((seconds % 86400) / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);
    
    if (days > 0) return `${days}d ${hours}h`;
    if (hours > 0) return `${hours}h ${minutes}m`;
    if (minutes > 0) return `${minutes}m ${secs}s`;
    return `${secs}s`;
}

// Search function
function performSearch() {
    const searchTerm = document.getElementById('searchInput')?.value;
    if (searchTerm) {
        window.location.href = `auctions.html?search=${encodeURIComponent(searchTerm)}`;
    }
}

function filterByCategory(categoryId) {
    window.location.href = `auctions.html?category_id=${categoryId}`;
}

// Camera capture state
let currentStream = null;
let currentFacingMode = 'environment'; // 'environment' (back) or 'user' (front)
let currentCaptureMode = 'id_front'; // 'id_front', 'id_back', or 'selfie'
let capturedIdCardFront = null;
let capturedIdCardBack = null;
let capturedSelfie = null;

// Biometric capture functionality - Opens camera modal
function openCameraModal() {
    const modal = document.getElementById('cameraModal');
    if (!modal) {
        showToast('Camera modal not found', 'error');
        return;
    }
    
    modal.style.display = 'block';
    resetCameraUI();
    updateStepUI();
}

function closeCameraModal() {
    const modal = document.getElementById('cameraModal');
    if (modal) {
        modal.style.display = 'none';
    }
    stopCamera();
}

function resetCameraUI() {
    // Helper for translations (safe if i18n not loaded yet)
    const t = (window.i18n && window.i18n.t)
        ? window.i18n.t
        : (key, def) => def || key;

    // Reset captured image state variables FIRST to prevent stale data
    // This ensures that when the modal is reopened, we start with a clean slate
    // This is critical for finishBiometricCapture() to correctly determine mode
    capturedIdCardFront = null;
    capturedIdCardBack = null;
    capturedSelfie = null;
    
    // Detect which mode to use based on page structure
    // index.html has stepIdFront/stepIdBack (two-step mode)
    // Other pages have stepId (single ID mode)
    const hasStepIdFront = document.getElementById('stepIdFront') !== null;
    const hasStepId = document.getElementById('stepId') !== null;
    
    // Set initial capture mode and title based on page structure
    let initialMode = 'id_front';
    let initialTitle = t('register.scanIdCard', 'Scan ID Card');
    
    if (!hasStepIdFront && hasStepId) {
        // Other pages (auctions.html, create-auction.html, etc.) use single ID mode
        initialMode = 'id';
    }
    
    // Reset UI state
    document.getElementById('cameraPlaceholder').style.display = 'block';
    document.getElementById('videoStream').style.display = 'none';
    document.getElementById('captureControls').style.display = 'none';
    document.getElementById('startCameraBtn').style.display = 'inline-block';
    document.getElementById('cameraModalTitle').textContent = initialTitle;
    
    // Reset capture mode to initial mode for this page
    currentCaptureMode = initialMode;
    currentFacingMode = 'environment'; // Back camera for ID scan
    
    // Reset step status indicators in the modal
    updateStepStatus('id_front', false);
    updateStepStatus('id_back', false);
    updateStepStatus('id', false);
    updateStepStatus('selfie', false);
}

function startCamera(mode = 'id_front') {
    currentCaptureMode = mode;
    
    // For ID card (both front and back), use back camera (environment)
    // For selfie, use front camera (user)
    const facingMode = mode === 'selfie' ? 'user' : 'environment';
    currentFacingMode = facingMode;
    
    const video = document.getElementById('videoStream');
    const placeholder = document.getElementById('cameraPlaceholder');
    const controls = document.getElementById('captureControls');
    
    // Check if browser supports getUserMedia
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        showToast('Camera access is not supported in your browser', 'error');
        return;
    }
    
    // Request camera access
    navigator.mediaDevices.getUserMedia({
        video: {
            facingMode: facingMode,
            width: { ideal: 1280 },
            height: { ideal: 720 }
        },
        audio: false
    })
    .then(stream => {
        currentStream = stream;
        video.srcObject = stream;
        video.style.display = 'block';
        placeholder.style.display = 'none';
        controls.style.display = 'block';
        
        // Update modal title
        let title = 'Scan ID Card';
        if (mode === 'id_front') {
            title = 'Scan ID Card Front';
        } else if (mode === 'id_back') {
            title = 'Scan ID Card Back';
        } else if (mode === 'selfie') {
            title = 'Take Selfie';
        }
        document.getElementById('cameraModalTitle').textContent = title;
        
        // Update step UI
        updateStepUI();
        
        showToast('Camera started successfully', 'success');
    })
    .catch(error => {
        debugError('Camera access error:', error);
        if (error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError') {
            showToast('Camera permission denied. Please allow camera access and try again.', 'error');
        } else if (error.name === 'NotFoundError') {
            showToast('No camera found on your device', 'error');
        } else {
            showToast('Failed to access camera: ' + error.message, 'error');
        }
    });
}

function stopCamera() {
    if (currentStream) {
        currentStream.getTracks().forEach(track => track.stop());
        currentStream = null;
    }
    
    const video = document.getElementById('videoStream');
    if (video) {
        video.srcObject = null;
    }
}

function switchCamera() {
    if (!currentStream) return;
    
    // Toggle between front and back camera
    currentFacingMode = currentFacingMode === 'environment' ? 'user' : 'environment';
    
    // Stop current stream
    stopCamera();
    
    // Start with new facing mode
    setTimeout(() => {
        startCamera(currentCaptureMode);
    }, 100);
}

async function capturePhoto() {
    const video = document.getElementById('videoStream');
    const canvas = document.getElementById('captureCanvas');
    const captureBtn = document.getElementById('captureBtn');
    const retakeBtn = document.getElementById('retakeBtn');
    
    if (!video || !canvas || !video.srcObject) {
        showToast('Video stream not available', 'error');
        return;
    }
    
    // Set canvas size to match video
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    
    // Draw video frame to canvas
    const ctx = canvas.getContext('2d');
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    
    // Convert to data URL (JPEG, 80% quality to reduce size)
    const imageData = canvas.toDataURL('image/jpeg', 0.8);
    
    // Disable capture button and show processing message
    if (captureBtn) {
    captureBtn.disabled = true;
        const processingText = (window.i18n && window.i18n.t) ? window.i18n.t('messages.processing', 'Processing...') : 'Processing...';
        captureBtn.innerHTML = '<span id="captureIcon">⏳</span> ' + processingText;
    }
    
    // Store the captured image based on mode
    if (currentCaptureMode === 'id_front') {
        // Validate image data before saving
        if (!imageData || !imageData.startsWith('data:image/')) {
            showToast('Failed to capture ID Card front. Please try again.', 'error');
            captureBtn.disabled = false;
            captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            return;
        }
        
        // Save the captured image
        capturedIdCardFront = imageData;
        debugLog('ID Card front captured, data length:', imageData.length);
        
        // Update preview - this will validate and display the image
        updateIdCardFrontPreview(imageData);
        
        // Wait a moment to ensure image loads before processing
        setTimeout(async () => {
            // Process ID card front with OCR
            try {
                showToast('Scanning ID card front...', 'info');
                const extractedData = await processIDCardWithOCR(imageData, 'front');
                
                // Auto-fill form fields with extracted data
                if (extractedData) {
                    autoFillRegistrationForm(extractedData);
                }
            } catch (error) {
                debugError('OCR processing error:', error);
                showToast('OCR processing failed. Please enter information manually.', 'error');
            }
        }, 100);
        
        // Wait for image to load in preview before marking complete
        const frontPreviewImg = document.getElementById('idCardFrontPreview');
        if (frontPreviewImg) {
            // Set up image load verification
            let imageVerified = false;
            
            const verifyImage = () => {
                if (frontPreviewImg.complete && frontPreviewImg.naturalWidth > 0) {
                    imageVerified = true;
                    debugLog('ID Card front image verified as loaded');
                    updateStepStatus('id_front', true);
                    
                    // Move to ID card back capture
    setTimeout(() => {
                        if (!capturedIdCardBack) {
                            showToast('ID Card front captured! Now scan the back', 'success');
                            startCamera('id_back');
                        }
                    }, 500);
                } else {
                    debugWarn('ID Card front image not loading properly');
                }
                captureBtn.disabled = false;
                captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            };
            
            // Check if already loaded
            if (frontPreviewImg.complete) {
                verifyImage();
            } else {
                // Wait for load event
                frontPreviewImg.onload = verifyImage;
                frontPreviewImg.onerror = () => {
                    debugError('ID Card front image failed to load');
                    showToast('ID Card front image failed to load. Please recapture.', 'error');
                    updateStepStatus('id_front', false);
                    capturedIdCardFront = null;
                    updateIdCardFrontPreview(null);
                    captureBtn.disabled = false;
                    captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
                };
                
                // Timeout after 3 seconds
                setTimeout(() => {
                    if (!imageVerified) {
                        verifyImage(); // Final check
                    }
                }, 3000);
            }
        } else {
            // If preview element doesn't exist, just validate data
            if (imageData && imageData.length > 100) {
                updateStepStatus('id_front', true);
                setTimeout(() => {
                    if (!capturedIdCardBack) {
                        showToast('ID Card front captured! Now scan the back', 'success');
                        startCamera('id_back');
                    }
                }, 500);
            }
            captureBtn.disabled = false;
            captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
        }
        
    } else if (currentCaptureMode === 'id_back') {
        // Validate image data before saving
        if (!imageData || !imageData.startsWith('data:image/')) {
            showToast('Failed to capture ID Card back. Please try again.', 'error');
            captureBtn.disabled = false;
            captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            return;
        }
        
        // Save the captured image
        capturedIdCardBack = imageData;
        debugLog('ID Card back captured, data length:', imageData.length);
        
        // Update preview - this will validate and display the image
        updateIdCardBackPreview(imageData);
        
        // Wait a moment to ensure image loads before processing
        setTimeout(async () => {
            // Process ID card back with OCR
            try {
                showToast('Scanning ID card back...', 'info');
                const extractedData = await processIDCardWithOCR(imageData, 'back');
                
                // Auto-fill form fields with extracted data (may have additional info on back)
                if (extractedData) {
                    autoFillRegistrationForm(extractedData, true); // true = merge with existing
                }
            } catch (error) {
                debugError('OCR processing error:', error);
                showToast('OCR processing failed. Please enter information manually.', 'error');
            }
        }, 100);
        
        // Wait for image to load in preview before marking complete
        const backPreviewImg = document.getElementById('idCardBackPreview');
        if (backPreviewImg) {
            // Set up image load verification
            let imageVerified = false;
            
            const verifyImage = () => {
                if (backPreviewImg.complete && backPreviewImg.naturalWidth > 0) {
                    imageVerified = true;
                    debugLog('ID Card back image verified as loaded');
                    updateStepStatus('id_back', true);
                    
                    // Move to selfie capture
                    setTimeout(() => {
                        if (!capturedSelfie) {
                            showToast('ID Card back captured! Now take your selfie', 'success');
                            startCamera('selfie');
                        }
                    }, 500);
                } else {
                    debugWarn('ID Card back image not loading properly');
                }
                captureBtn.disabled = false;
                captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            };
            
            // Check if already loaded
            if (backPreviewImg.complete) {
                verifyImage();
            } else {
                // Wait for load event
                backPreviewImg.onload = verifyImage;
                backPreviewImg.onerror = () => {
                    debugError('ID Card back image failed to load');
                    showToast('ID Card back image failed to load. Please recapture.', 'error');
                    updateStepStatus('id_back', false);
                    capturedIdCardBack = null;
                    updateIdCardBackPreview(null);
                    captureBtn.disabled = false;
                    captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
                };
                
                // Timeout after 3 seconds
                setTimeout(() => {
                    if (!imageVerified) {
                        verifyImage(); // Final check
                    }
                }, 3000);
            }
        } else {
            // If preview element doesn't exist, just validate data
            if (imageData && imageData.length > 100) {
                updateStepStatus('id_back', true);
                setTimeout(() => {
                    if (!capturedSelfie) {
                        showToast('ID Card back captured! Now take your selfie', 'success');
                        startCamera('selfie');
                    }
                }, 500);
            }
            captureBtn.disabled = false;
            captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
        }
        
    } else if (currentCaptureMode === 'id') {
        // Handle single ID card capture mode (used in auctions.html, create-auction.html, etc.)
        // Validate image data before saving
        if (!imageData || !imageData.startsWith('data:image/')) {
            showToast('Failed to capture ID Card. Please try again.', 'error');
            captureBtn.disabled = false;
            captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            return;
        }
        
        // Save the captured image (use capturedIdCardFront for single ID card mode)
        capturedIdCardFront = imageData;
        debugLog('ID Card captured (single mode), data length:', imageData.length);
        
        // Update preview - try both preview element IDs for compatibility
        const idCardPreview = document.getElementById('idCardPreview');
        if (idCardPreview) {
            // For pages with single ID preview (auctions.html, create-auction.html, etc.)
            idCardPreview.src = imageData;
            if (idCardPreview.parentElement) {
                idCardPreview.parentElement.style.display = 'block';
            }
            const container = document.getElementById('capturedImages');
            if (container) {
                container.style.display = 'block';
            }
        } else {
            // Fallback to ID front preview if idCardPreview doesn't exist
            updateIdCardFrontPreview(imageData);
        }
        
        // Process ID card with OCR
        setTimeout(async () => {
            try {
                showToast('Scanning ID card...', 'info');
                const extractedData = await processIDCardWithOCR(imageData, 'front');
                
                // Auto-fill form fields with extracted data
                if (extractedData) {
                    autoFillRegistrationForm(extractedData);
                }
            } catch (error) {
                debugError('OCR processing error:', error);
                showToast('OCR processing failed. Please enter information manually.', 'error');
            }
        }, 100);
        
        // Wait for image to load in preview before marking complete
        const previewImg = idCardPreview || document.getElementById('idCardFrontPreview');
        if (previewImg) {
            let imageVerified = false;
            
            const verifyImage = () => {
                if (previewImg.complete && previewImg.naturalWidth > 0) {
                    imageVerified = true;
                    debugLog('ID Card image verified as loaded (single mode)');
                    updateStepStatus('id', true);
                    
                    // Move to selfie capture
                    setTimeout(() => {
                        if (!capturedSelfie) {
                            showToast('ID Card captured! Now take your selfie', 'success');
                            startCamera('selfie');
                        }
                    }, 500);
                } else {
                    debugWarn('ID Card image not loading properly');
                }
                captureBtn.disabled = false;
                captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            };
            
            // Check if already loaded
            if (previewImg.complete) {
                verifyImage();
            } else {
                // Wait for load event
                previewImg.onload = verifyImage;
                previewImg.onerror = () => {
                    debugError('ID Card image failed to load');
                    showToast('ID Card image failed to load. Please recapture.', 'error');
                    updateStepStatus('id', false);
                    capturedIdCardFront = null;
                    updateIdCardFrontPreview(null);
                    captureBtn.disabled = false;
                    captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
                };
                
                // Timeout after 3 seconds
                setTimeout(() => {
                    if (!imageVerified) {
                        verifyImage(); // Final check
                    }
                }, 3000);
            }
        } else {
            // If preview element doesn't exist, just validate data
            if (imageData && imageData.length > 100) {
                updateStepStatus('id', true);
                setTimeout(() => {
                    if (!capturedSelfie) {
                        showToast('ID Card captured! Now take your selfie', 'success');
                        startCamera('selfie');
                    }
                }, 500);
            }
            captureBtn.disabled = false;
            captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
        }
        
    } else if (currentCaptureMode === 'id') {
        // Handle single ID card capture mode (used in auctions.html, create-auction.html, etc.)
        // Validate image data before saving
        if (!imageData || !imageData.startsWith('data:image/')) {
            showToast('Failed to capture ID Card. Please try again.', 'error');
            captureBtn.disabled = false;
            captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            return;
        }
        
        // Save the captured image (use capturedIdCardFront for single ID card mode)
        capturedIdCardFront = imageData;
        debugLog('ID Card captured (single mode), data length:', imageData.length);
        
        // Update preview - try both preview element IDs for compatibility
        const idCardPreview = document.getElementById('idCardPreview');
        if (idCardPreview) {
            // For pages with single ID preview (auctions.html, create-auction.html, etc.)
            idCardPreview.src = imageData;
            if (idCardPreview.parentElement) {
                idCardPreview.parentElement.style.display = 'block';
            }
            const container = document.getElementById('capturedImages');
            if (container) {
                container.style.display = 'block';
            }
        } else {
            // Fallback to ID front preview if idCardPreview doesn't exist
            updateIdCardFrontPreview(imageData);
        }
        
        // Process ID card with OCR
        setTimeout(async () => {
            try {
                showToast('Scanning ID card...', 'info');
                const extractedData = await processIDCardWithOCR(imageData, 'front');
                
                // Auto-fill form fields with extracted data
                if (extractedData) {
                    autoFillRegistrationForm(extractedData);
                }
            } catch (error) {
                debugError('OCR processing error:', error);
                showToast('OCR processing failed. Please enter information manually.', 'error');
            }
        }, 100);
        
        // Wait for image to load in preview before marking complete
        const previewImg = idCardPreview || document.getElementById('idCardFrontPreview');
        if (previewImg) {
            let imageVerified = false;
            
            const verifyImage = () => {
                if (previewImg.complete && previewImg.naturalWidth > 0) {
                    imageVerified = true;
                    debugLog('ID Card image verified as loaded (single mode)');
                    updateStepStatus('id', true);
                    
                    // Move to selfie capture
                    setTimeout(() => {
                        if (!capturedSelfie) {
                            showToast('ID Card captured! Now take your selfie', 'success');
                            startCamera('selfie');
                        }
                    }, 500);
                } else {
                    debugWarn('ID Card image not loading properly');
                }
                captureBtn.disabled = false;
                captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            };
            
            // Check if already loaded
            if (previewImg.complete) {
                verifyImage();
            } else {
                // Wait for load event
                previewImg.onload = verifyImage;
                previewImg.onerror = () => {
                    debugError('ID Card image failed to load');
                    showToast('ID Card image failed to load. Please recapture.', 'error');
                    updateStepStatus('id', false);
                    capturedIdCardFront = null;
                    updateIdCardFrontPreview(null);
                    captureBtn.disabled = false;
                    captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
                };
                
                // Timeout after 3 seconds
                setTimeout(() => {
                    if (!imageVerified) {
                        verifyImage(); // Final check
                    }
                }, 3000);
            }
        } else {
            // If preview element doesn't exist, just validate data
            if (imageData && imageData.length > 100) {
                updateStepStatus('id', true);
                setTimeout(() => {
                    if (!capturedSelfie) {
                        showToast('ID Card captured! Now take your selfie', 'success');
                        startCamera('selfie');
                    }
                }, 500);
            }
            captureBtn.disabled = false;
            captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
        }
        
    } else if (currentCaptureMode === 'selfie') {
        // Validate image data before saving
        if (!imageData || !imageData.startsWith('data:image/')) {
            showToast('Failed to capture selfie. Please try again.', 'error');
            if (captureBtn) {
                captureBtn.disabled = false;
                captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            }
            return;
        }

        // Save the captured image
        capturedSelfie = imageData;
        debugLog('Selfie captured, data length:', imageData.length);

        // Update preview - this will validate and display the image
        updateSelfiePreview(imageData);

        // Wait a moment to ensure image loads before processing
        setTimeout(async () => {
            // Process selfie image
            try {
                showToast('Processing selfie...', 'info');
                const processedData = await processSelfieImage(imageData);

                // Auto-fill form fields with extracted data
                if (processedData) {
                    autoFillRegistrationForm(processedData);
                }
            } catch (error) {
                debugError('Selfie processing error:', error);
                showToast('Selfie processing failed. Please enter information manually.', 'error');
            }
        }, 100);

        // Wait for image to load in preview before marking complete
        const selfiePreviewImg = document.getElementById('selfiePreview');
        if (selfiePreviewImg) {
            // Set up image load verification
            let imageVerified = false;

            const verifyImage = () => {
                if (selfiePreviewImg.complete && selfiePreviewImg.naturalWidth > 0) {
                    imageVerified = true;
                    debugLog('Selfie image verified as loaded');
                    updateStepStatus('selfie', true);

                    // Finish biometric capture process
                    finishBiometricCapture();
                } else {
                    debugWarn('Selfie image not loading properly');
                }

                if (captureBtn) {
                    captureBtn.disabled = false;
                    captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
                }
            };

            if (selfiePreviewImg.complete) {
                verifyImage();
            } else {
                selfiePreviewImg.onload = verifyImage;
                selfiePreviewImg.onerror = () => {
                    debugError('Selfie image failed to load');
                    showToast('Selfie image failed to load. Please recapture.', 'error');
                    updateStepStatus('selfie', false);
                    capturedSelfie = null;
                    updateSelfiePreview(null);

                    if (captureBtn) {
                        captureBtn.disabled = false;
                        captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
                    }
                };

                // Timeout after 3 seconds
                setTimeout(() => {
                    if (!imageVerified) {
                        verifyImage(); // Final check
                    }
                }, 3000);
            }
        } else {
            // If preview element doesn't exist, just validate data
            if (imageData && imageData.length > 100) {
                updateStepStatus('selfie', true);
                finishBiometricCapture();
            }

            if (captureBtn) {
                captureBtn.disabled = false;
                captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            }
        }
    }
    
    // Re-enable capture button (only if not already handled above)
    if (captureBtn && !captureBtn.disabled) {
        captureBtn.disabled = false;
        captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
    }
    
    // Show retake button
    if (retakeBtn) {
        retakeBtn.style.display = 'inline-block';
    }
}

function retakePhoto() {
    if (currentCaptureMode === 'id_front') {
        capturedIdCardFront = null;
        updateIdCardFrontPreview(null);
        updateStepStatus('id_front', false);
        const preview = document.getElementById('idCardFrontPreview');
        if (preview && preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
    } else if (currentCaptureMode === 'id_back') {
        capturedIdCardBack = null;
        updateIdCardBackPreview(null);
        updateStepStatus('id_back', false);
        const preview = document.getElementById('idCardBackPreview');
        if (preview && preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
    } else if (currentCaptureMode === 'id') {
        // Handle single ID card mode (used in auctions.html, create-auction.html, etc.)
        capturedIdCardFront = null;
        updateStepStatus('id', false);
        const preview = document.getElementById('idCardPreview');
        if (preview) {
            preview.src = '';
            preview.removeAttribute('src');
            if (preview.parentElement) {
                preview.parentElement.style.display = 'none';
            }
        } else {
            // Fallback to ID front preview
            updateIdCardFrontPreview(null);
            const frontPreview = document.getElementById('idCardFrontPreview');
            if (frontPreview && frontPreview.parentElement) {
                frontPreview.parentElement.style.display = 'none';
            }
        }
    } else if (currentCaptureMode === 'selfie') {
        capturedSelfie = null;
        updateSelfiePreview(null);
        updateStepStatus('selfie', false);
        const preview = document.getElementById('selfiePreview');
        if (preview && preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
    }
    
    // Hide retake button and restart camera
    const retakeBtn = document.getElementById('retakeBtn');
    if (retakeBtn) {
        retakeBtn.style.display = 'none';
    }
    startCamera(currentCaptureMode);
}

function updateIdCardFrontPreview(imageData) {
    const preview = document.getElementById('idCardFrontPreview');
    const container = document.getElementById('capturedImages');
    
    if (!preview) {
        debugWarn('ID Card front preview element not found');
        return;
    }
    
    if (!imageData) {
        debugWarn('No image data provided for ID Card front preview');
        // Clear the preview if no data
        preview.src = '';
        preview.removeAttribute('src');
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        return;
    }
    
    // Validate image data is a valid data URL
    if (!imageData.startsWith('data:image/')) {
        debugError('Invalid image data format for ID Card front');
        return;
    }
    
    // Set the image source
    preview.src = imageData;
    
    // Show the container and parent element
    if (container) {
        container.style.display = 'block';
    }
    
    if (preview.parentElement) {
        preview.parentElement.style.display = 'block';
    }
    
    // Add error handler to detect broken images
    preview.onerror = function() {
        debugError('Failed to load ID Card front preview image');
        preview.src = '';
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        showToast('ID Card front image failed to load. Please recapture.', 'error');
    };
    
    // Add load handler to confirm image loaded successfully
    preview.onload = function() {
        debugLog('ID Card front preview image loaded successfully');
    };
    
    debugLog('ID Card front preview updated');
}

function updateIdCardBackPreview(imageData) {
    const preview = document.getElementById('idCardBackPreview');
    const container = document.getElementById('capturedImages');
    
    if (!preview) {
        debugWarn('ID Card back preview element not found');
        return;
    }
    
    if (!imageData) {
        debugWarn('No image data provided for ID Card back preview');
        // Clear the preview if no data
        preview.src = '';
        preview.removeAttribute('src');
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        return;
    }
    
    // Validate image data is a valid data URL
    if (!imageData.startsWith('data:image/')) {
        debugError('Invalid image data format for ID Card back');
        return;
    }
    
    // Set the image source
    preview.src = imageData;
    
    // Show the container and parent element
    if (container) {
        container.style.display = 'block';
    }
    
    if (preview.parentElement) {
        preview.parentElement.style.display = 'block';
    }
    
    // Add error handler to detect broken images
    preview.onerror = function() {
        debugError('Failed to load ID Card back preview image');
        preview.src = '';
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        showToast('ID Card back image failed to load. Please recapture.', 'error');
    };
    
    // Add load handler to confirm image loaded successfully
    preview.onload = function() {
        debugLog('ID Card back preview image loaded successfully');
    };
    
    debugLog('ID Card back preview updated');
}

function updateSelfiePreview(imageData) {
    const preview = document.getElementById('selfiePreview');
    const container = document.getElementById('capturedImages');
    
    if (!preview) {
        debugWarn('Selfie preview element not found');
        return;
    }
    
    if (!imageData) {
        debugWarn('No image data provided for selfie preview');
        // Clear the preview if no data
        preview.src = '';
        preview.removeAttribute('src');
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        return;
    }
    
    // Validate image data is a valid data URL
    if (!imageData.startsWith('data:image/')) {
        debugError('Invalid image data format for selfie');
        return;
    }
    
    // Set the image source
    preview.src = imageData;
    
    // Show the container and parent element
    if (container) {
        container.style.display = 'block';
    }
    
    if (preview.parentElement) {
        preview.parentElement.style.display = 'block';
    }
    
    // Add error handler to detect broken images
    preview.onerror = function() {
        debugError('Failed to load selfie preview image');
        preview.src = '';
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        showToast('Selfie image failed to load. Please recapture.', 'error');
    };
    
    // Add load handler to confirm image loaded successfully
    preview.onload = function() {
        debugLog('Selfie preview image loaded successfully');
    };
    
    debugLog('Selfie preview updated');
}

function updateStepStatus(step, completed) {
    // Helper for translations (safe if i18n not loaded yet)
    const t = (window.i18n && window.i18n.t)
        ? window.i18n.t
        : (key, def) => def || key;

    // Map step names to element IDs - support both naming conventions
    // index.html uses: stepIdFront, stepIdBack, stepSelfie
    // Other pages use: stepId, stepSelfie
    let stepId = null;
    let statusId = null;
    
    // Try to find the step element using flexible matching
    if (step === 'id_front') {
        // Try stepIdFront first (index.html), fallback to stepId (other pages)
        stepId = document.getElementById('stepIdFront') ? 'stepIdFront' : 'stepId';
        statusId = stepId === 'stepIdFront' ? 'stepIdFrontStatus' : 'stepIdStatus';
    } else if (step === 'id_back') {
        stepId = 'stepIdBack';
        statusId = 'stepIdBackStatus';
    } else if (step === 'id') {
        // Single ID card mode (other pages)
        stepId = 'stepId';
        statusId = 'stepIdStatus';
    } else if (step === 'selfie') {
        stepId = 'stepSelfie';
        statusId = 'stepSelfieStatus';
    } else {
        // Fallback: try step name as-is
        stepId = step;
        statusId = step + 'Status';
    }
    
    const stepElement = document.getElementById(stepId);
    const statusElement = document.getElementById(statusId);
    
    if (stepElement && statusElement) {
        stepElement.classList.remove('active', 'completed');
        
        if (completed) {
            stepElement.classList.add('completed');
            statusElement.textContent = t('register.doneShort', '✅ Completed');
            statusElement.style.color = 'var(--success-color)';
        } else {
            statusElement.textContent = t('register.pending', 'Pending');
            statusElement.style.color = '#a0a0c0';
        }
    }
    
    // Update active step - try both naming conventions
    // Remove active from all possible step elements
    document.getElementById('stepIdFront')?.classList.remove('active');
    document.getElementById('stepIdBack')?.classList.remove('active');
    document.getElementById('stepId')?.classList.remove('active');
    document.getElementById('stepSelfie')?.classList.remove('active');
    
    // Add active to current step based on capture mode
    if (currentCaptureMode === 'id_front') {
        document.getElementById('stepIdFront')?.classList.add('active');
    } else if (currentCaptureMode === 'id_back') {
        document.getElementById('stepIdBack')?.classList.add('active');
    } else if (currentCaptureMode === 'id') {
        document.getElementById('stepId')?.classList.add('active');
    } else if (currentCaptureMode === 'selfie') {
        document.getElementById('stepSelfie')?.classList.add('active');
    }
}

function updateStepUI() {
    updateStepStatus('id_front', !!capturedIdCardFront);
    updateStepStatus('id_back', !!capturedIdCardBack);
    updateStepStatus('selfie', !!capturedSelfie);
}

// Process ID card image with OCR
async function processIDCardWithOCR(imageData, side = 'front') {
    try {
        // Check if Tesseract is available
        if (typeof Tesseract === 'undefined') {
            debugWarn('Tesseract.js not loaded, skipping OCR');
            return null;
        }
        
        const sideText = side === 'front' ? 'front' : 'back';
        showToast(`Extracting text from ID card ${sideText}...`, 'info');
        
        // Use Tesseract to recognize text from the image
        const { data: { text } } = await Tesseract.recognize(imageData, 'eng', {
            logger: (info) => {
                if (info.status === 'recognizing text') {
                    const progress = Math.round(info.progress * 100);
                    // Could show progress if needed
                }
            }
        });
        
        debugLog('OCR Extracted Text:', text);
        
        // Parse the extracted text to find name, birth date, and ID number
        const extractedData = parseIDCardText(text);
        
        return extractedData;
    } catch (error) {
        console.error('OCR processing error:', error);
        throw error;
    }
}

// Parse ID card text to extract name, birth date, and ID number
function parseIDCardText(text) {
    const extracted = {
        name: null,
        birthDate: null,
        idNumber: null
    };
    
    // Normalize text - remove extra whitespace and convert to uppercase for pattern matching
    const normalizedText = text.replace(/\s+/g, ' ').trim();
    const lines = normalizedText.split('\n').map(line => line.trim()).filter(line => line.length > 0);
    
    debugLog('Parsing text lines:', lines);
    
    // Try to extract name (usually appears near the top, may contain letters and spaces)
    // Look for lines that look like names (contain letters, possibly with spaces, 2-50 characters)
    for (let i = 0; i < Math.min(10, lines.length); i++) {
        const line = lines[i];
        // Name pattern: mostly letters, spaces, hyphens, 2-50 chars
        if (/^[A-Za-z\s\-']{2,50}$/.test(line) && line.split(' ').length >= 2) {
            if (!extracted.name || line.length > extracted.name.length) {
                extracted.name = line;
            }
        }
    }
    
    // Try to extract ID number (usually numbers, possibly with letters, dashes)
    // Common patterns: all digits, digits with dashes, alphanumeric
    for (const line of lines) {
        // Remove common words/prefixes
        const cleanLine = line.replace(/^(ID|ID NUMBER|IDENTITY|NATIONAL ID|PASSPORT|CARD|NUMBER|NO|#|:|)\s*/i, '');
        
        // Pattern 1: All digits (8-20 digits)
        if (/^\d{8,20}$/.test(cleanLine)) {
            if (!extracted.idNumber || cleanLine.length >= extracted.idNumber.length) {
                extracted.idNumber = cleanLine;
            }
        }
        
        // Pattern 2: Digits with dashes/spaces (like XXX-XXX-XXX or XXX XXX XXX)
        const dashPattern = /^[\d\s\-]{10,25}$/.exec(cleanLine);
        if (dashPattern && cleanLine.replace(/[\s\-]/g, '').length >= 8) {
            if (!extracted.idNumber) {
                extracted.idNumber = cleanLine.replace(/\s+/g, '');
            }
        }
        
        // Pattern 3: Alphanumeric (like A1234567)
        if (/^[A-Za-z0-9]{8,20}$/i.test(cleanLine)) {
            // Prefer numeric-only, but accept alphanumeric if no numeric found
            if (!extracted.idNumber || (!/^\d+$/.test(extracted.idNumber) && /^\d+$/.test(cleanLine))) {
                extracted.idNumber = cleanLine.toUpperCase();
            }
        }
    }
    
    // Try to extract birth date
    // Common date formats: DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY, YYYY-MM-DD, DD MMM YYYY
    const datePatterns = [
        /\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})\b/, // DD/MM/YYYY or DD-MM-YYYY
        /\b(\d{4})[\/\-\.](\d{1,2})[\/\-\.](\d{1,2})\b/, // YYYY-MM-DD
        /\b(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{4})\b/i, // DD MMM YYYY
        /\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{1,2}),\s+(\d{4})\b/i, // MMM DD, YYYY
        /\b(\d{1,2})\s+(Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember)\s+(\d{4})\b/i, // Indonesian months
    ];
    
    for (const line of lines) {
        // Look for "DOB", "Birth", "Date of Birth", "Born" followed by date
        const birthKeywords = /(DOB|Birth|Date\s+of\s+Birth|Born|Tanggal|Lahir)[\s:]*([^\n]{0,30})/i;
        const match = line.match(birthKeywords);
        
        if (match) {
            const dateSection = match[2] || line;
            // Try all date patterns on this section
            for (const pattern of datePatterns) {
                const dateMatch = dateSection.match(pattern);
                if (dateMatch) {
                    extracted.birthDate = formatDate(dateMatch);
                    break;
                }
            }
        }
        
        // Also check for standalone dates (looks like a date format)
        for (const pattern of datePatterns) {
            const dateMatch = line.match(pattern);
            if (dateMatch) {
                // Validate it's a reasonable date (between 1900-2100)
                const year = parseInt(dateMatch[3] || dateMatch[1]);
                if (year >= 1900 && year <= 2100) {
                    if (!extracted.birthDate) {
                        extracted.birthDate = formatDate(dateMatch);
                    }
                }
            }
        }
    }
    
    // Clean up extracted values
    if (extracted.name) {
        extracted.name = extracted.name.trim();
        // Capitalize properly (First Last)
        extracted.name = extracted.name.split(' ').map(word => 
            word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
        ).join(' ');
    }
    
    if (extracted.idNumber) {
        extracted.idNumber = extracted.idNumber.replace(/[\s\-]/g, '');
    }
    
    debugLog('Extracted Data:', extracted);
    
    return extracted;
}

// Format date match to standard format (YYYY-MM-DD)
function formatDate(dateMatch) {
    let day, month, year;
    
    // Check if it's a date with month name (text month)
    const monthNames = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    const monthIdx = monthNames.findIndex(m => 
        dateMatch[1]?.toLowerCase().startsWith(m) || 
        dateMatch[2]?.toLowerCase().startsWith(m) ||
        dateMatch[1]?.toLowerCase().includes(m) ||
        dateMatch[2]?.toLowerCase().includes(m)
    );
    
    if (monthIdx !== -1) {
        // Date with text month (DD MMM YYYY or MMM DD, YYYY)
        if (dateMatch[3] && dateMatch[3].length === 4) {
            // DD MMM YYYY format
            day = dateMatch[1]?.padStart(2, '0') || dateMatch[2]?.padStart(2, '0');
            month = String(monthIdx + 1).padStart(2, '0');
            year = dateMatch[3];
        } else {
            // MMM DD, YYYY format
            day = dateMatch[2]?.padStart(2, '0') || dateMatch[1]?.padStart(2, '0');
            month = String(monthIdx + 1).padStart(2, '0');
            year = dateMatch[3] || dateMatch[4];
        }
    } else if (dateMatch[1] && dateMatch[1].length === 4 && /^\d{4}$/.test(dateMatch[1])) {
        // Format: YYYY-MM-DD
        year = dateMatch[1];
        month = dateMatch[2]?.padStart(2, '0');
        day = dateMatch[3]?.padStart(2, '0');
    } else if (dateMatch[1] && dateMatch[3] && dateMatch[3].length === 4) {
        // Format: DD-MM-YYYY or DD/MM/YYYY
        day = dateMatch[1].padStart(2, '0');
        month = dateMatch[2].padStart(2, '0');
        year = dateMatch[3];
    } else {
        // Try to parse as is
        const dateStr = dateMatch[0];
        // Try different separators
        const parts = dateStr.split(/[\/\-\.]/);
        if (parts.length === 3) {
            if (parts[0].length === 4) {
                // YYYY-MM-DD
                year = parts[0];
                month = parts[1].padStart(2, '0');
                day = parts[2].padStart(2, '0');
            } else {
                // DD-MM-YYYY
                day = parts[0].padStart(2, '0');
                month = parts[1].padStart(2, '0');
                year = parts[2];
            }
        }
    }
    
    if (day && month && year) {
        return `${year}-${month}-${day}`;
    }
    
    return dateMatch[0]; // Return original if can't parse
}

// Auto-fill registration form with extracted data
function autoFillRegistrationForm(extractedData, merge = false) {
    if (!extractedData) return;
    
    let filledCount = 0;
    
    // Auto-fill name/username (prefer front side if merging)
    if (extractedData.name) {
        const usernameField = document.getElementById('registerUsername');
        if (usernameField && (!usernameField.value || merge)) {
            // Use first name as username
            const firstName = extractedData.name.split(' ')[0].toLowerCase();
            if (!usernameField.value) {
                usernameField.value = firstName;
                filledCount++;
            }
        }
    }
    
    // Auto-fill ID number (prefer back side if merging, as ID numbers are often on the back)
    if (extractedData.idNumber) {
        const idField = document.getElementById('registerIdNumber');
        if (idField && (!idField.value || merge)) {
            if (!idField.value) {
                idField.value = extractedData.idNumber;
                filledCount++;
            } else if (merge && extractedData.idNumber.length >= idField.value.length) {
                // If merging and new ID number is longer/complete, use it
                idField.value = extractedData.idNumber;
            }
        }
    }
    
    // Auto-fill birth date
    if (extractedData.birthDate) {
        const birthDateField = document.getElementById('registerBirthDate');
        if (birthDateField) {
            // Convert extracted date to YYYY-MM-DD format for date input
            const extractedDate = extractedData.birthDate;
            // If already in YYYY-MM-DD format, use as-is
            if (/^\d{4}-\d{2}-\d{2}$/.test(extractedDate)) {
                if (!birthDateField.value || merge) {
                    birthDateField.value = extractedDate;
                    // Update date picker display
                    updateDatePickerDisplay(birthDateField);
                    filledCount++;
                }
            } else {
                // Try to parse and format the date
                const dateObj = new Date(extractedDate);
                if (!isNaN(dateObj.getTime())) {
                    const formattedDate = dateObj.toISOString().split('T')[0];
                    if (!birthDateField.value || merge) {
                        birthDateField.value = formattedDate;
                        // Update date picker display
                        updateDatePickerDisplay(birthDateField);
                        filledCount++;
                    }
                }
            }
        }
    }
    
    // Show message about what was filled
    if (filledCount > 0) {
        const message = `Auto-filled ${filledCount} field(s) from ID card. Please verify and complete the remaining fields.`;
        showToast(message, 'success');
        debugLog('Auto-filled form fields:', extractedData);
    } else {
        showToast('Could not extract information from ID card. Please enter manually.', 'warning');
    }
    
    // Log extracted data for debugging
    debugLog('Extracted ID Card Data:', extractedData);
}

function finishBiometricCapture() {
    // Determine if we're in single ID card mode (other pages) or two-step mode (index.html)
    const isSingleIdMode = capturedIdCardBack === null;
    
    // Validate required images based on mode
    if (isSingleIdMode) {
        // Single ID card mode: only need front ID and selfie
        if (!capturedIdCardFront || !capturedSelfie) {
            showToast('Please capture ID card and selfie', 'error');
            return;
        }
        
        // Validate image data format and size
        const frontValid = capturedIdCardFront.startsWith('data:image/') && capturedIdCardFront.length > 100;
        const selfieValid = capturedSelfie.startsWith('data:image/') && capturedSelfie.length > 100;
        
        if (!frontValid) {
            showToast('ID Card image is invalid. Please recapture.', 'error');
            updateStepStatus('id', false);
            return;
        }
        
        if (!selfieValid) {
            showToast('Selfie image is invalid. Please recapture.', 'error');
            updateStepStatus('selfie', false);
            return;
        }
    } else {
        // Two-step mode: need both sides of ID card and selfie
        if (!capturedIdCardFront || !capturedIdCardBack || !capturedSelfie) {
            showToast('Please capture both sides of ID card and selfie', 'error');
            return;
        }
        
        // Validate image data format and size
        const frontValid = capturedIdCardFront.startsWith('data:image/') && capturedIdCardFront.length > 100;
        const backValid = capturedIdCardBack.startsWith('data:image/') && capturedIdCardBack.length > 100;
        const selfieValid = capturedSelfie.startsWith('data:image/') && capturedSelfie.length > 100;
        
        if (!frontValid) {
            showToast('ID Card front image is invalid. Please recapture.', 'error');
            updateStepStatus('id_front', false);
            return;
        }
        
        if (!backValid) {
            showToast('ID Card back image is invalid. Please recapture.', 'error');
            updateStepStatus('id_back', false);
            return;
        }
        
        if (!selfieValid) {
            showToast('Selfie image is invalid. Please recapture.', 'error');
            updateStepStatus('selfie', false);
            return;
        }
    }
    
    // Save biometric data to localStorage
    const biometricData = isSingleIdMode
        ? {
            type: 'id_card_and_selfie',
            id_card_image: capturedIdCardFront,
            selfie_image: capturedSelfie,
            timestamp: Date.now(),
            device: navigator.userAgent
        }
        : {
            type: 'id_card_both_sides_and_selfie',
            id_card_front_image: capturedIdCardFront,
            id_card_back_image: capturedIdCardBack,
            selfie_image: capturedSelfie,
            timestamp: Date.now(),
            device: navigator.userAgent
        };
    
    localStorage.setItem('pending_biometric', JSON.stringify(biometricData));
    debugLog('Biometric data saved - Mode:', isSingleIdMode ? 'single ID' : 'both sides', 'Front:', !!capturedIdCardFront, 'Back:', !!capturedIdCardBack, 'Selfie:', !!capturedSelfie);
    
    // Update UI
    const captureBtn = document.getElementById('captureBiometric');
    const statusDiv = document.getElementById('biometricStatus');
    
    if (captureBtn) {
        captureBtn.classList.add('captured');
        captureBtn.innerHTML = '<span id="biometricIcon">✅</span> Biometric Verified';
    }
    
    if (statusDiv) {
        statusDiv.innerHTML = isSingleIdMode
            ? '✅ ID Card & Selfie captured successfully!'
            : '✅ ID Card (both sides) & Selfie captured successfully!';
        statusDiv.className = 'biometric-status success';
    }
    
    // Close camera modal
    closeCameraModal();
    
    showToast('Biometric verification completed!', 'success');
}

// Legacy function for compatibility - now opens camera modal
function captureBiometric() {
    openCameraModal();
}

function generateSimulatedBiometric() {
    // This function is kept for backwards compatibility
    // But now we use real camera capture
    const timestamp = Date.now();
    return JSON.stringify({
        type: 'id_card_and_selfie',
        timestamp: timestamp,
        simulated: true
    });
}

function getStoredBiometric() {
    const data = localStorage.getItem('pending_biometric');
    debugLog('Retrieving biometric data from localStorage:', data ? 'Found' : 'Not found');
    
    if (!data) return null;
    
    // Try to parse as JSON (new format with images)
    try {
        const parsed = JSON.parse(data);
        // New format with both sides
        if (parsed.id_card_front_image && parsed.id_card_back_image && parsed.selfie_image) {
            return data; // Return JSON string
        }
        // Old format (backward compatibility)
        else if (parsed.id_card_image && parsed.selfie_image) {
            return data; // Return JSON string
        }
    } catch (e) {
        // Old format - return as is
        return data;
    }
    
    return data;
}

function clearStoredBiometric() {
    // Clear from localStorage
    localStorage.removeItem('pending_biometric');
    
    // Clear state variables
    capturedIdCardFront = null;
    capturedIdCardBack = null;
    capturedSelfie = null;
    
    // Reset biometric UI to ensure everything is cleared
    resetBiometricUI();
    
    debugLog('Biometric data cleared from localStorage and state variables');
}

// Restore biometric UI state if data exists
function restoreBiometricState() {
    const biometricData = getStoredBiometric();
    if (biometricData) {
        try {
            const parsed = JSON.parse(biometricData);
            // New format with both sides
            if (parsed.id_card_front_image && parsed.id_card_back_image && parsed.selfie_image) {
                // Validate all images before restoring
                const frontValid = parsed.id_card_front_image && 
                                  parsed.id_card_front_image.startsWith('data:image/') && 
                                  parsed.id_card_front_image.length > 100;
                const backValid = parsed.id_card_back_image && 
                                 parsed.id_card_back_image.startsWith('data:image/') && 
                                 parsed.id_card_back_image.length > 100;
                const selfieValid = parsed.selfie_image && 
                                   parsed.selfie_image.startsWith('data:image/') && 
                                   parsed.selfie_image.length > 100;
                
                // Only restore if all images are valid
                if (frontValid && backValid && selfieValid) {
                    // Restore captured images
                    capturedIdCardFront = parsed.id_card_front_image;
                    capturedIdCardBack = parsed.id_card_back_image;
                    capturedSelfie = parsed.selfie_image;
                    
                    // Update previews
                    updateIdCardFrontPreview(capturedIdCardFront);
                    updateIdCardBackPreview(capturedIdCardBack);
                    updateSelfiePreview(capturedSelfie);
                    debugLog('Biometric state restored with valid images');
                } else {
                    // If any image is invalid, clear everything
                    debugWarn('Invalid image data found, clearing biometric state');
                    clearStoredBiometric();
                    return;
                }
            }
            // Old format (backward compatibility)
            else if (parsed.id_card_image && parsed.selfie_image) {
                // Validate images before restoring
                const frontValid = parsed.id_card_image && 
                                  parsed.id_card_image.startsWith('data:image/') && 
                                  parsed.id_card_image.length > 100;
                const selfieValid = parsed.selfie_image && 
                                   parsed.selfie_image.startsWith('data:image/') && 
                                   parsed.selfie_image.length > 100;
                
                if (frontValid && selfieValid) {
                    // Restore captured images (old format - single ID card image)
                    capturedIdCardFront = parsed.id_card_image;
                    capturedSelfie = parsed.selfie_image;
                    
                    // Update previews
                    updateIdCardFrontPreview(capturedIdCardFront);
                    updateSelfiePreview(capturedSelfie);
                    debugLog('Biometric state restored (old format)');
                } else {
                    // If any image is invalid, clear everything
                    debugWarn('Invalid image data found (old format), clearing biometric state');
                    clearStoredBiometric();
                    return;
                }
            }
        } catch (e) {
            debugError('Error parsing biometric data:', e);
            // If parsing fails, clear the invalid data
            clearStoredBiometric();
        }
        
        const captureBtn = document.getElementById('captureBiometric');
        const statusDiv = document.getElementById('biometricStatus');
        const biometricIcon = document.getElementById('biometricIcon');
        
        if (captureBtn) {
            captureBtn.disabled = false;
            captureBtn.classList.add('captured');
            captureBtn.innerHTML = '<span id="biometricIcon">✅</span> Biometric Verified';
        }
        if (statusDiv) {
            statusDiv.innerHTML = '✅ ID Card & Selfie captured successfully!';
            statusDiv.className = 'biometric-status success';
        }
        if (biometricIcon) {
            biometricIcon.textContent = '✅';
        }
    }
}

// Reset biometric UI state (without clearing data)
function resetBiometricUI() {
    const captureBtn = document.getElementById('captureBiometric');
    const statusDiv = document.getElementById('biometricStatus');
    const capturedImages = document.getElementById('capturedImages');
    
    if (captureBtn) {
        captureBtn.disabled = false;
        captureBtn.classList.remove('captured');
        captureBtn.innerHTML = '<span id="biometricIcon">📷</span> Scan ID & Take Selfie';
        debugLog('Biometric button reset');
    }
    
    if (statusDiv) {
        statusDiv.innerHTML = '';
        statusDiv.className = 'biometric-status';
        debugLog('Biometric status cleared');
    }
    
    // Hide captured images preview container
    if (capturedImages) {
        capturedImages.style.display = 'none';
        debugLog('Captured images container hidden');
    }
    
    // Reset preview images - get all preview images and clear them
    const frontPreview = document.getElementById('idCardFrontPreview');
    const backPreview = document.getElementById('idCardBackPreview');
    const selfiePreview = document.getElementById('selfiePreview');
    
    // Clear front preview
    if (frontPreview) {
        frontPreview.src = '';
        frontPreview.removeAttribute('src');
        if (frontPreview.parentElement) {
            frontPreview.parentElement.style.display = 'none';
        }
        debugLog('ID Card front preview cleared');
    } else {
        debugWarn('ID Card front preview not found');
    }
    
    // Clear back preview
    if (backPreview) {
        backPreview.src = '';
        backPreview.removeAttribute('src');
        if (backPreview.parentElement) {
            backPreview.parentElement.style.display = 'none';
        }
        debugLog('ID Card back preview cleared');
    } else {
        debugWarn('ID Card back preview not found');
    }
    
    // Clear selfie preview
    if (selfiePreview) {
        selfiePreview.src = '';
        selfiePreview.removeAttribute('src');
        if (selfiePreview.parentElement) {
            selfiePreview.parentElement.style.display = 'none';
        }
        debugLog('Selfie preview cleared');
    } else {
        debugWarn('Selfie preview not found');
    }
    
    // Also clear any old preview elements (backward compatibility)
    const oldIdPreview = document.getElementById('idCardPreview');
    if (oldIdPreview) {
        oldIdPreview.src = '';
        oldIdPreview.removeAttribute('src');
        if (oldIdPreview.parentElement) {
            oldIdPreview.parentElement.style.display = 'none';
        }
        debugLog('Old ID card preview cleared');
    }
    
    debugLog('Biometric UI reset complete');
}

// ===== MULTI-STEP FORM FUNCTIONS =====
let currentStep = 1;
const totalSteps = 3;

function nextStep() {
    if (validateStep(currentStep)) {
        if (currentStep < totalSteps) {
            const currentStepEl = document.getElementById(`step${currentStep}`);
            const nextStepEl = document.getElementById(`step${currentStep + 1}`);

            if (currentStepEl && nextStepEl) {
                currentStepEl.style.display = 'none';
                currentStep++;
                nextStepEl.style.display = 'block';
                updateStepButtons();
                window.scrollTo(0, 0);
            }
        }
    }
}

function previousStep() {
    if (currentStep > 1) {
        const currentStepEl = document.getElementById(`step${currentStep}`);
        const prevStepEl = document.getElementById(`step${currentStep - 1}`);

        if (currentStepEl && prevStepEl) {
            currentStepEl.style.display = 'none';
            currentStep--;
            prevStepEl.style.display = 'block';
            updateStepButtons();
            window.scrollTo(0, 0);
        }
    }
}

function updateStepButtons() {
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    const submitBtn = document.getElementById('submitBtn');

    // Safely check if buttons exist before updating
    if (!prevBtn || !nextBtn || !submitBtn) {
        console.warn('Multi-step form buttons not found on this page');
        return;
    }

    if (currentStep === 1) {
        prevBtn.style.display = 'none';
    } else {
        prevBtn.style.display = 'flex';
    }

    if (currentStep === totalSteps) {
        nextBtn.style.display = 'none';
        submitBtn.style.display = 'flex';
    } else {
        nextBtn.style.display = 'flex';
        submitBtn.style.display = 'none';
    }
}

function validateStep(step) {
    const username = document.getElementById('registerUsername').value.trim();
    const email = document.getElementById('registerEmail').value.trim();
    const password = document.getElementById('registerPassword').value;
    const idNumber = document.getElementById('registerIdNumber').value.trim();
    const birthDate = document.getElementById('registerBirthDate').value;
    const phone = document.getElementById('registerPhone').value.trim();
    const address = document.getElementById('registerAddress').value.trim();

    if (step === 1) {
        if (!username) {
            showNotification('Please enter a username', 'error');
            return false;
        }
        if (!email) {
            showNotification('Please enter an email address', 'error');
            return false;
        }
        if (!isValidEmail(email)) {
            showNotification('Please enter a valid email address', 'error');
            return false;
        }
        if (!password) {
            showNotification('Please enter a password', 'error');
            return false;
        }
        if (!isPasswordStrong(password)) {
            showNotification('Password does not meet all requirements', 'error');
            return false;
        }
        return true;
    } else if (step === 2) {
        if (!idNumber) {
            showNotification('Please enter your ID number or passport', 'error');
            return false;
        }
        if (!birthDate) {
            showNotification('Please select your date of birth', 'error');
            return false;
        }
        return true;
    } else if (step === 3) {
        if (!phone) {
            showNotification('Please enter your phone number', 'error');
            return false;
        }
        if (!address) {
            showNotification('Please enter your address', 'error');
            return false;
        }
        return true;
    }
    return true;
}

function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

function isPasswordStrong(password) {
    const hasLength = password.length >= 8;
    const hasLower = /[a-z]/.test(password);
    const hasUpper = /[A-Z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    const hasSpecial = /[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]/.test(password);

    return hasLength && hasLower && hasUpper && hasNumber && hasSpecial;
}

// Initialize multi-step form on modal open
function initializeMultiStepForm() {
    const step1 = document.getElementById('step1');
    const step2 = document.getElementById('step2');
    const step3 = document.getElementById('step3');

    // Only proceed if all steps exist
    if (!step1 || !step2 || !step3) {
        console.warn('Multi-step form elements not found on this page');
        return;
    }

    currentStep = 1;
    step1.style.display = 'block';
    step2.style.display = 'none';
    step3.style.display = 'none';
    updateStepButtons();
}

// Reset form when modal is closed
function resetMultiStepForm() {
    const step1 = document.getElementById('step1');
    const step2 = document.getElementById('step2');
    const step3 = document.getElementById('step3');
    const registerForm = document.getElementById('registerForm');

    // Only proceed if all steps exist
    if (!step1 || !step2 || !step3 || !registerForm) {
        console.warn('Multi-step form elements not found on this page');
        return;
    }

    currentStep = 1;
    registerForm.reset();
    step1.style.display = 'block';
    step2.style.display = 'none';
    step3.style.display = 'none';
    updateStepButtons();
}

// Override showRegister to initialize multi-step form
const originalShowRegister = window.showRegister;
window.showRegister = function() {
    if (originalShowRegister) {
        originalShowRegister();
    }
    initializeMultiStepForm();
};

// Override closeModalAndReset to reset multi-step form
const originalCloseModalAndReset = window.closeModalAndReset;
window.closeModalAndReset = function(modalId) {
    if (modalId === 'registerModal') {
        resetMultiStepForm();
    }
    if (originalCloseModalAndReset) {
        originalCloseModalAndReset(modalId);
    }
};
