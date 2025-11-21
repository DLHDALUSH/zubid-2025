// How to Bid page functionality
document.addEventListener('DOMContentLoaded', async () => {
    // Check authentication status
    await checkAuth();
    
    // Update navigation based on auth status
    updateNavAuth(!!currentUser);
});

