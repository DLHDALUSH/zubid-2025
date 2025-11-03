// Standalone profile page - no dependencies on app.js
// This prevents conflicts and flashing

// Prevent multiple executions
if (window.profileInitialized) {
    console.log('Profile already initialized, skipping...');
} else {
    window.profileInitialized = true;
    
    // Simple toast function
    window.showToast = window.showToast || function(message, type) {
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
    
    // Profile page functionality
    document.addEventListener('DOMContentLoaded', async () => {
        // Prevent duplicate execution
        if (window.profilePageLoaded) {
            return;
        }
        window.profilePageLoaded = true;
        
        try {
            // Try to get profile - if fails, user is not logged in
            let profile;
            try {
                profile = await UserAPI.getProfile();
                
                // Update nav manually
                const navAuth = document.getElementById('navAuth');
                const navUser = document.getElementById('navUser');
                const userName = document.getElementById('userName');
                
                if (navAuth) navAuth.style.display = 'none';
                if (navUser) {
                    navUser.style.display = 'flex';
                    if (userName) {
                        userName.textContent = profile.username;
                    }
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
            await loadMyAuctions();
            await loadMyBids();
            
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
}

