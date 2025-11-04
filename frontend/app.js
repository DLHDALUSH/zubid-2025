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
    
    await checkAuth();
    authChecked = true;
    if (document.getElementById('featuredCarousel')) {
        loadFeaturedCarousel();
        loadFeaturedAuctions();
        loadCategories();
    }
    
    // Setup biometric modal reset
    setupBiometricModalReset();
    // Initialize date picker
    initializeDatePicker();
    // Initialize password strength checker
    initializePasswordStrength();
});

// Setup biometric modal reset function (now handled in closeModalAndReset and window.onclick)
function setupBiometricModalReset() {
    // This function is kept for compatibility but reset is now handled elsewhere
}

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

// Password strength checker
function checkPasswordStrength(password) {
    const strengthIndicator = document.getElementById('passwordStrength');
    if (!strengthIndicator) return;
    
    if (!password || password.length === 0) {
        strengthIndicator.className = 'password-strength';
        return;
    }
    
    let strength = 0;
    
    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    
    // Character variety checks
    if (/[a-z]/.test(password)) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/[0-9]/.test(password)) strength++;
    if (/[^a-zA-Z0-9]/.test(password)) strength++;
    
    // Determine strength level
    if (strength <= 2) {
        strengthIndicator.className = 'password-strength weak';
    } else if (strength <= 4) {
        strengthIndicator.className = 'password-strength medium';
    } else {
        strengthIndicator.className = 'password-strength strong';
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
        datePickerText.textContent = 'Click to choose date';
    }
}

// Authentication functions
async function checkAuth() {
    try {
        const response = await UserAPI.getProfile();
        currentUser = response;
        updateNavAuth(true);
        if (document.getElementById('userName')) {
            document.getElementById('userName').textContent = response.username;
        }
        // Show admin link if user is admin
        if (response.role === 'admin') {
            const navMenu = document.getElementById('navMenu');
            if (navMenu) {
                let adminLink = document.getElementById('adminLink');
                if (!adminLink) {
                    adminLink = document.createElement('a');
                    adminLink.href = 'admin.html';
                    adminLink.className = 'nav-link';
                    adminLink.id = 'adminLink';
                    adminLink.textContent = 'Admin';
                    const navUser = document.getElementById('navUser');
                    if (navUser && navUser.parentNode) {
                        navMenu.insertBefore(adminLink, navUser);
                    }
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
        updateNavAuth(false);
    }
}

function updateNavAuth(isAuthenticated) {
    const navAuth = document.getElementById('navAuth');
    const navUser = document.getElementById('navUser');
    const myBidsLink = document.getElementById('myBidsLink');
    const paymentsLink = document.getElementById('paymentsLink');
    
    if (navAuth && navUser) {
        if (isAuthenticated) {
            navAuth.style.display = 'none';
            navUser.style.display = 'flex';
            // Show My Bids link
            if (myBidsLink) myBidsLink.style.display = 'inline-block';
            // Show Payments link
            if (paymentsLink) paymentsLink.style.display = 'inline-block';
        } else {
            navAuth.style.display = 'flex';
            navUser.style.display = 'none';
            // Hide My Bids link
            if (myBidsLink) myBidsLink.style.display = 'none';
            // Hide Payments link
            if (paymentsLink) paymentsLink.style.display = 'none';
        }
    }
}

async function handleLogin(event) {
    event.preventDefault();
    
    // Check if backend is reachable first
    try {
        const testResponse = await fetch('http://localhost:5000/api/test');
        if (!testResponse.ok) {
            throw new Error('Backend server is not responding correctly');
        }
    } catch (error) {
        showToast('Cannot connect to server! Make sure the backend is running on port 5000. Check the terminal where you ran "python app.py"', 'error');
        console.error('Backend connection error:', error);
        return;
    }
    
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;
    
    const submitBtn = event.target.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.textContent = 'Logging in...';
    
    try {
        const response = await UserAPI.login(username, password);
        currentUser = response.user;
        updateNavAuth(true);
        if (document.getElementById('userName')) {
            document.getElementById('userName').textContent = response.user.username;
        }
        closeModal('loginModal');
        showToast('Login successful!', 'success');
        
        // Load user-specific sections immediately after login
        if (document.getElementById('myAuctionsSection')) {
            loadMyAuctions();
            loadMyBids();
        }
        
        // Reload page to update UI
        setTimeout(() => window.location.reload(), 1000);
    } catch (error) {
        console.error('Login error:', error);
        showToast(error.message || 'Login failed. Please check your credentials.', 'error');
    } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
    }
}

async function handleRegister(event) {
    event.preventDefault();
    
    // Check if backend is reachable first
    try {
        const testResponse = await fetch('http://localhost:5000/api/test');
        if (!testResponse.ok) {
            throw new Error('Backend server is not responding correctly');
        }
    } catch (error) {
        showToast('Cannot connect to server! Make sure the backend is running on port 5000. Check the terminal where you ran "python app.py"', 'error');
        console.error('Backend connection error:', error);
        return;
    }
    
    // Check if biometric data has been captured
    const biometricData = getStoredBiometric();
    console.log('Checking for biometric data:', biometricData ? 'Found' : 'Not found');
    if (!biometricData) {
        showToast('Please scan your ID card and take a selfie first', 'error');
        console.warn('Registration blocked: No biometric data found in localStorage');
        return;
    }
    
    // Validate that both ID card sides and selfie are captured
    try {
        const parsed = JSON.parse(biometricData);
        // New format with both sides (preferred)
        if (parsed.id_card_front_image && parsed.id_card_back_image && parsed.selfie_image) {
            // All required images captured - proceed
        }
        // Old format (backward compatibility)
        else if (parsed.id_card_image && parsed.selfie_image) {
            // Old format - single ID card + selfie is valid and registration will proceed
            // No warning needed since this is a supported format and registration succeeds
            // Users on pages like auctions.html, create-auction.html use single ID mode by design
        }
        else {
            showToast('Please capture both sides of ID card and selfie before registering', 'error');
            console.warn('Registration blocked: Missing ID card sides or selfie image');
            return;
        }
    } catch (e) {
        // Old format - might not have images
        showToast('Please capture both sides of ID card and selfie using the camera feature', 'error');
        return;
    }
    
    const userData = {
        username: document.getElementById('registerUsername').value,
        email: document.getElementById('registerEmail').value,
        password: document.getElementById('registerPassword').value,
        id_number: document.getElementById('registerIdNumber').value,
        birth_date: document.getElementById('registerBirthDate').value,
        biometric_data: biometricData,
        address: document.getElementById('registerAddress').value,
        phone: document.getElementById('registerPhone').value,
    };
    
    // Show loading
    const submitBtn = event.target.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.textContent = 'Registering...';
    
    try {
        await UserAPI.register(userData);
        
        // Clear biometric data after successful registration FIRST
        // This clears localStorage, state variables, and UI
        clearStoredBiometric();
        
        // Clear all form fields immediately (before closing modal)
        // Note: resetRegistrationForm also clears biometric variables, but they're already cleared
        window.skipBiometricUIReset = true; // Prevent double UI reset
        resetRegistrationForm();
        window.skipBiometricUIReset = false;
        
        // Close modal
        closeModal('registerModal');
        
        // Show success message
        showToast('Registration successful! Please login.', 'success');
        
        // Open login modal after a short delay
        setTimeout(() => {
            showLogin();
        }, 500);
    } catch (error) {
        console.error('Registration error:', error);
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
        submitBtn.textContent = originalText;
    }
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
    // Reset form before showing to ensure it's clean
    // Note: We don't clear biometric data here - user might have captured it
    // Only reset the form fields, not the biometric capture state
    resetRegistrationFormFields();
    
    // Show modal
    document.getElementById('registerModal').style.display = 'block';
    
    // Restore biometric state if data exists (so user doesn't lose their captured images)
    restoreBiometricState();
}

// Reset only form fields (not biometric data)
function resetRegistrationFormFields() {
    const form = document.getElementById('registerForm');
    if (!form) return;
    
    // Use native form reset method
    try {
        form.reset();
    } catch (e) {
        console.warn('Form reset() method failed');
    }
    
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
        if (datePickerText) datePickerText.textContent = 'Select your date of birth';
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
        console.warn('Register form not found');
        return;
    }
    
    // Use native form reset method (resets all fields to default values)
    try {
        form.reset();
    } catch (e) {
        console.warn('Form reset() method failed, using manual reset');
    }
    
    // Manually reset all form fields as backup
    // First, reset all inputs in the form using querySelectorAll
    const allInputs = form.querySelectorAll('input, textarea, select');
    allInputs.forEach(input => {
        if (input.type === 'checkbox' || input.type === 'radio') {
            input.checked = false;
        } else {
            input.value = '';
            input.classList.remove('is-invalid', 'is-valid');
        }
        console.log(`Cleared field: ${input.id || input.name || 'unnamed'}`);
    });
    
    // Specifically target known fields to ensure they're cleared
    const usernameField = document.getElementById('registerUsername');
    const emailField = document.getElementById('registerEmail');
    const passwordField = document.getElementById('registerPassword');
    const idNumberField = document.getElementById('registerIdNumber');
    const birthDateField = document.getElementById('registerBirthDate');
    const addressField = document.getElementById('registerAddress');
    const phoneField = document.getElementById('registerPhone');
    
    if (usernameField) {
        usernameField.value = '';
        usernameField.classList.remove('is-invalid', 'is-valid');
        console.log('Username field cleared');
    } else {
        console.warn('Username field not found');
    }
    if (emailField) {
        emailField.value = '';
        emailField.classList.remove('is-invalid', 'is-valid');
        console.log('Email field cleared');
    } else {
        console.warn('Email field not found');
    }
    if (passwordField) {
        passwordField.value = '';
        passwordField.classList.remove('is-invalid', 'is-valid');
        console.log('Password field cleared');
    } else {
        console.warn('Password field not found');
    }
    if (idNumberField) {
        idNumberField.value = '';
        idNumberField.classList.remove('is-invalid', 'is-valid');
        console.log('ID Number field cleared');
    } else {
        console.warn('ID Number field not found');
    }
    if (birthDateField) {
        birthDateField.value = '';
        birthDateField.classList.remove('is-invalid', 'is-valid');
        // Reset date picker display
        const datePickerText = document.getElementById('registerBirthDateText');
        if (datePickerText) datePickerText.textContent = 'Select your date of birth';
        console.log('Birth Date field cleared');
    } else {
        console.warn('Birth Date field not found');
    }
    if (addressField) {
        addressField.value = '';
        addressField.classList.remove('is-invalid', 'is-valid');
        console.log('Address field cleared');
    } else {
        console.warn('Address field not found');
    }
    if (phoneField) {
        phoneField.value = '';
        phoneField.classList.remove('is-invalid', 'is-valid');
        console.log('Phone field cleared');
    } else {
        console.warn('Phone field not found');
    }
    
    // Reset form validation state
    form.classList.remove('was-validated');
    
    // Clear any error messages
    const errorElements = form.querySelectorAll('.error-message');
    errorElements.forEach(el => {
        el.style.display = 'none';
        el.textContent = '';
    });
    
    // Reset camera capture state variables (already done by clearStoredBiometric if called)
    // But ensure they're cleared here too
    capturedIdCardFront = null;
    capturedIdCardBack = null;
    capturedSelfie = null;
    
    // Reset biometric UI (only if not already reset by clearStoredBiometric)
    // Check if we should skip to avoid double reset
    if (!window.skipBiometricUIReset) {
        resetBiometricUI();
    }
    
    console.log('Registration form reset successfully');
}

// Close modal and reset biometric data for registration modal
function closeModalAndReset(modalId) {
    if (modalId === 'registerModal') {
        // Reset biometric UI
        resetBiometricUI();
        // Also reset form when closing modal (unless it's after successful registration which handles it separately)
        // Use a small delay to ensure modal closes first
        setTimeout(() => {
            resetRegistrationForm();
        }, 50);
    }
    closeModal(modalId);
}

// Close modal when clicking outside
window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            if (modal.id === 'registerModal') {
                // Reset biometric UI state
                // Biometric data will be cleared after successful registration
                resetBiometricUI();
                // Close the modal
                closeModal('registerModal');
            } else if (modal.id === 'cameraModal') {
                // Close camera modal properly
                closeCameraModal();
            } else {
                // Close other modals
                modal.style.display = 'none';
            }
        }
    });
};

// Toast notification
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast ${type}`;
    toast.style.display = 'block';
    
    setTimeout(() => {
        toast.style.display = 'none';
    }, 3000);
}

// Mobile menu toggle
function toggleMobileMenu() {
    const navMenu = document.getElementById('navMenu');
    navMenu.classList.toggle('active');
}

// Carousel functions
let currentSlide = 0;
let carouselInterval;

async function loadFeaturedCarousel() {
    try {
        const featured = await AuctionAPI.getFeatured();
        const carousel = document.getElementById('featuredCarousel');
        const indicators = document.getElementById('carouselIndicators');
        
        if (!featured || featured.length === 0) {
            carousel.innerHTML = '<div class="carousel-item"><div class="carousel-placeholder">No featured auctions available</div></div>';
            return;
        }
        
        carousel.innerHTML = '';
        indicators.innerHTML = '';
        
        featured.forEach((auction, index) => {
            const item = document.createElement('div');
            item.className = 'carousel-item';
            item.innerHTML = `
                <img src="${auction.image_url || 'https://via.placeholder.com/1200x400?text=No+Image'}" alt="${auction.item_name}">
                <div class="carousel-overlay">
                    <h2>${auction.item_name}</h2>
                    <p>Current Bid: $${auction.current_bid.toFixed(2)}</p>
                    <button class="btn btn-primary" onclick="window.location.href='auction-detail.html?id=${auction.id}'">View Auction</button>
                </div>
            `;
            carousel.appendChild(item);
            
            const indicator = document.createElement('span');
            indicator.className = 'indicator';
            if (index === 0) indicator.classList.add('active');
            indicator.onclick = () => goToSlide(index);
            indicators.appendChild(indicator);
        });
        
        startCarousel();
    } catch (error) {
        console.error('Error loading carousel:', error);
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
    try {
        const response = await AuctionAPI.getAll({ featured: 'true', status: 'active', per_page: 6 });
        const container = document.getElementById('featuredAuctions');
        
        if (!container) return;
        
        if (response.auctions && response.auctions.length > 0) {
            container.innerHTML = response.auctions.map(auction => createAuctionCard(auction)).join('');
        } else {
            container.innerHTML = '<p>No featured auctions available</p>';
        }
    } catch (error) {
        console.error('Error loading featured auctions:', error);
    }
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
        console.error('Error loading categories:', error);
    }
}

// Load user's auctions
async function loadMyAuctions() {
    try {
        const section = document.getElementById('myAuctionsSection');
        const container = document.getElementById('myAuctions');
        
        if (!section || !container) {
            console.log('My Auctions section elements not found');
            return;
        }
        
        if (!currentUser) {
            console.log('No current user, hiding My Auctions section');
            section.style.display = 'none';
            return;
        }
        
        console.log('Loading user auctions...');
        const auctions = await AuctionAPI.getUserAuctions();
        console.log('User auctions loaded:', auctions);
        
        if (auctions && auctions.length > 0) {
            console.log(`Showing ${auctions.length} user auctions`);
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
            console.log('No user auctions found');
            // Show section even if empty with a message
            section.style.display = 'none';
        }
    } catch (error) {
        console.error('Error loading my auctions:', error);
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
            console.log('My Bids section elements not found');
            return;
        }
        
        if (!currentUser) {
            console.log('No current user, hiding My Bids section');
            section.style.display = 'none';
            return;
        }
        
        console.log('Loading user bids...');
        const bids = await BidAPI.getUserBids();
        console.log('User bids loaded:', bids);
        
        if (bids && bids.length > 0) {
            console.log(`Showing ${bids.length} user bids`);
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
            
            console.log(`Showing ${uniqueBids.length} unique bids (from ${bids.length} total bids)`);
            
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
            console.log('No user bids found');
            section.style.display = 'none';
        }
    } catch (error) {
        console.error('Error loading my bids:', error);
        const section = document.getElementById('myBidsSection');
        if (section) {
            section.style.display = 'none';
        }
    }
}

// Create auction card HTML
function createAuctionCard(auction) {
    const timeLeft = formatTimeLeft(auction.time_left);
    const statusClass = auction.status === 'active' ? 'active' : 'ended';
    
    return `
        <div class="auction-card" onclick="window.location.href='auction-detail.html?id=${auction.id}'">
            <div class="auction-image">
                <img src="${auction.image_url || 'https://via.placeholder.com/300x200?text=No+Image'}" alt="${auction.item_name}">
                <span class="status-badge ${statusClass}">${auction.status}</span>
            </div>
            <div class="auction-card-content">
                <h3>${auction.item_name}</h3>
                <p class="auction-description">${auction.description}</p>
                <div class="auction-stats">
                    <div class="stat">
                        <label>Current Bid</label>
                        <span class="price">$${auction.current_bid.toFixed(2)}</span>
                    </div>
                    <div class="stat">
                        <label>Time Left</label>
                        <span class="time-left">${timeLeft}</span>
                    </div>
                    <div class="stat">
                        <label>Bids</label>
                        <span>${auction.bid_count}</span>
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
    let initialTitle = 'Scan ID Card Front';
    
    if (!hasStepIdFront && hasStepId) {
        // Other pages (auctions.html, create-auction.html, etc.) use single ID mode
        initialMode = 'id';
        initialTitle = 'Scan ID Card';
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
        console.error('Camera access error:', error);
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
        captureBtn.innerHTML = '<span id="captureIcon">⏳</span> Processing...';
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
        console.log('ID Card front captured, data length:', imageData.length);
        
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
                console.error('OCR processing error:', error);
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
                    console.log('ID Card front image verified as loaded');
                    updateStepStatus('id_front', true);
                    
                    // Move to ID card back capture
    setTimeout(() => {
                        if (!capturedIdCardBack) {
                            showToast('ID Card front captured! Now scan the back', 'success');
                            startCamera('id_back');
                        }
                    }, 500);
                } else {
                    console.warn('ID Card front image not loading properly');
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
                    console.error('ID Card front image failed to load');
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
        console.log('ID Card back captured, data length:', imageData.length);
        
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
                console.error('OCR processing error:', error);
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
                    console.log('ID Card back image verified as loaded');
                    updateStepStatus('id_back', true);
                    
                    // Move to selfie capture
                    setTimeout(() => {
                        if (!capturedSelfie) {
                            showToast('ID Card back captured! Now take your selfie', 'success');
                            startCamera('selfie');
                        }
                    }, 500);
                } else {
                    console.warn('ID Card back image not loading properly');
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
                    console.error('ID Card back image failed to load');
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
        console.log('ID Card captured (single mode), data length:', imageData.length);
        
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
                console.error('OCR processing error:', error);
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
                    console.log('ID Card image verified as loaded (single mode)');
                    updateStepStatus('id', true);
                    
                    // Move to selfie capture
                    setTimeout(() => {
                        if (!capturedSelfie) {
                            showToast('ID Card captured! Now take your selfie', 'success');
                            startCamera('selfie');
                        }
                    }, 500);
                } else {
                    console.warn('ID Card image not loading properly');
                }
                captureBtn.disabled = false;
                captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
            };
            
            if (previewImg.complete) {
                verifyImage();
            } else {
                previewImg.onload = verifyImage;
                previewImg.onerror = () => {
                    console.error('ID Card image failed to load');
                    showToast('ID Card image failed to load. Please recapture.', 'error');
                    updateStepStatus('id', false);
                    capturedIdCardFront = null;
                    if (idCardPreview) {
                        idCardPreview.src = '';
                        idCardPreview.removeAttribute('src');
                        if (idCardPreview.parentElement) {
                            idCardPreview.parentElement.style.display = 'none';
                        }
                    }
                    captureBtn.disabled = false;
                    captureBtn.innerHTML = '<span id="captureIcon">📸</span> Capture Photo';
                };
                
                setTimeout(() => {
                    if (!imageVerified) {
                        verifyImage();
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
        capturedSelfie = imageData;
        updateSelfiePreview(imageData);
        updateStepStatus('selfie', true);
        showToast('Selfie captured!', 'success');
        
        // Stop camera and show done button
        stopCamera();
        document.getElementById('videoStream').style.display = 'none';
        document.getElementById('cameraPlaceholder').style.display = 'block';
        document.getElementById('captureControls').style.display = 'none';
        
        // Show done button - check for both two-step and single ID card modes
        // If capturedIdCardBack is null, we're in single ID card mode (only front captured)
        // Otherwise, we're in two-step mode (both front and back captured)
        const allCaptured = capturedIdCardBack === null
            ? (capturedIdCardFront && capturedSelfie)
            : (capturedIdCardFront && capturedIdCardBack && capturedSelfie);
            
        if (allCaptured) {
            document.getElementById('cameraActions').style.display = 'block';
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
        console.warn('ID Card front preview element not found');
        return;
    }
    
    if (!imageData) {
        console.warn('No image data provided for ID Card front preview');
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
        console.error('Invalid image data format for ID Card front');
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
        console.error('Failed to load ID Card front preview image');
        preview.src = '';
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        showToast('ID Card front image failed to load. Please recapture.', 'error');
    };
    
    // Add load handler to confirm image loaded successfully
    preview.onload = function() {
        console.log('ID Card front preview image loaded successfully');
    };
    
    console.log('ID Card front preview updated');
}

function updateIdCardBackPreview(imageData) {
    const preview = document.getElementById('idCardBackPreview');
    const container = document.getElementById('capturedImages');
    
    if (!preview) {
        console.warn('ID Card back preview element not found');
        return;
    }
    
    if (!imageData) {
        console.warn('No image data provided for ID Card back preview');
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
        console.error('Invalid image data format for ID Card back');
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
        console.error('Failed to load ID Card back preview image');
        preview.src = '';
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        showToast('ID Card back image failed to load. Please recapture.', 'error');
    };
    
    // Add load handler to confirm image loaded successfully
    preview.onload = function() {
        console.log('ID Card back preview image loaded successfully');
    };
    
    console.log('ID Card back preview updated');
}

function updateSelfiePreview(imageData) {
    const preview = document.getElementById('selfiePreview');
    const container = document.getElementById('capturedImages');
    
    if (!preview) {
        console.warn('Selfie preview element not found');
        return;
    }
    
    if (!imageData) {
        console.warn('No image data provided for selfie preview');
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
        console.error('Invalid image data format for selfie');
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
        console.error('Failed to load selfie preview image');
        preview.src = '';
        if (preview.parentElement) {
            preview.parentElement.style.display = 'none';
        }
        showToast('Selfie image failed to load. Please recapture.', 'error');
    };
    
    // Add load handler to confirm image loaded successfully
    preview.onload = function() {
        console.log('Selfie preview image loaded successfully');
    };
    
    console.log('Selfie preview updated');
}

function updateStepStatus(step, completed) {
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
            statusElement.textContent = '✅ Completed';
            statusElement.style.color = 'var(--success-color)';
        } else {
            statusElement.textContent = 'Pending';
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
            console.warn('Tesseract.js not loaded, skipping OCR');
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
        
        console.log('OCR Extracted Text:', text);
        
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
    
    console.log('Parsing text lines:', lines);
    
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
    
    console.log('Extracted Data:', extracted);
    
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
        console.log('Auto-filled form fields:', extractedData);
    } else {
        showToast('Could not extract information from ID card. Please enter manually.', 'warning');
    }
    
    // Log extracted data for debugging
    console.log('Extracted ID Card Data:', extractedData);
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
    console.log('Biometric data saved - Mode:', isSingleIdMode ? 'single ID' : 'both sides', 'Front:', !!capturedIdCardFront, 'Back:', !!capturedIdCardBack, 'Selfie:', !!capturedSelfie);
    
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
    console.log('Retrieving biometric data from localStorage:', data ? 'Found' : 'Not found');
    
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
    
    console.log('Biometric data cleared from localStorage and state variables');
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
                    console.log('Biometric state restored with valid images');
                } else {
                    // If any image is invalid, clear everything
                    console.warn('Invalid image data found, clearing biometric state');
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
                    console.log('Biometric state restored (old format)');
                } else {
                    // If any image is invalid, clear everything
                    console.warn('Invalid image data found (old format), clearing biometric state');
                    clearStoredBiometric();
                    return;
                }
            }
        } catch (e) {
            console.error('Error parsing biometric data:', e);
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
        console.log('Biometric button reset');
    }
    
    if (statusDiv) {
        statusDiv.innerHTML = '';
        statusDiv.className = 'biometric-status';
        console.log('Biometric status cleared');
    }
    
    // Hide captured images preview container
    if (capturedImages) {
        capturedImages.style.display = 'none';
        console.log('Captured images container hidden');
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
        console.log('ID Card front preview cleared');
    } else {
        console.warn('ID Card front preview not found');
    }
    
    // Clear back preview
    if (backPreview) {
        backPreview.src = '';
        backPreview.removeAttribute('src');
        if (backPreview.parentElement) {
            backPreview.parentElement.style.display = 'none';
        }
        console.log('ID Card back preview cleared');
    } else {
        console.warn('ID Card back preview not found');
    }
    
    // Clear selfie preview
    if (selfiePreview) {
        selfiePreview.src = '';
        selfiePreview.removeAttribute('src');
        if (selfiePreview.parentElement) {
            selfiePreview.parentElement.style.display = 'none';
        }
        console.log('Selfie preview cleared');
    } else {
        console.warn('Selfie preview not found');
    }
    
    // Also clear any old preview elements (backward compatibility)
    const oldIdPreview = document.getElementById('idCardPreview');
    if (oldIdPreview) {
        oldIdPreview.src = '';
        oldIdPreview.removeAttribute('src');
        if (oldIdPreview.parentElement) {
            oldIdPreview.parentElement.style.display = 'none';
        }
        console.log('Old ID card preview cleared');
    }
    
    console.log('Biometric UI reset complete');
}

