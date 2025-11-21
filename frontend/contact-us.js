// Contact Us page functionality
document.addEventListener('DOMContentLoaded', async () => {
    // Check authentication status
    await checkAuth();
    
    // Update navigation based on auth status
    updateNavAuth(!!currentUser);
});

// Handle contact form submission
async function handleContactSubmit(event) {
    event.preventDefault();
    
    const form = event.target;
    const submitBtn = document.getElementById('contactSubmitBtn');
    const messageDiv = document.getElementById('contactFormMessage');
    
    // Get form data
    const formData = {
        name: document.getElementById('contactName').value.trim(),
        email: document.getElementById('contactEmail').value.trim(),
        subject: document.getElementById('contactSubject').value,
        message: document.getElementById('contactMessage').value.trim()
    };
    
    // Validate
    if (!formData.name || !formData.email || !formData.subject || !formData.message) {
        showMessage(messageDiv, 'Please fill in all required fields.', 'error');
        return;
    }
    
    // Disable submit button
    submitBtn.disabled = true;
    submitBtn.textContent = 'Sending...';
    
    try {
        // In a real application, you would send this to your backend API
        // For now, we'll simulate a successful submission
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Show success message
        showMessage(messageDiv, 'Thank you! Your message has been sent successfully. We will get back to you soon.', 'success');
        
        // Reset form
        form.reset();
        
        // Show toast notification
        if (typeof showToast === 'function') {
            showToast('Message sent successfully!', 'success');
        }
        
    } catch (error) {
        console.error('Error sending message:', error);
        showMessage(messageDiv, 'Sorry, there was an error sending your message. Please try again later.', 'error');
        
        if (typeof showToast === 'function') {
            showToast('Failed to send message. Please try again.', 'error');
        }
    } finally {
        // Re-enable submit button
        submitBtn.disabled = false;
        submitBtn.textContent = 'Send Message';
    }
}

// Helper function to show messages
function showMessage(element, message, type) {
    element.style.display = 'block';
    element.textContent = message;
    element.className = type === 'success' ? 'success-message' : 'error-message';
    element.style.padding = '1rem';
    element.style.borderRadius = '12px';
    element.style.marginTop = '1rem';
    
    if (type === 'success') {
        element.style.background = 'rgba(0, 200, 83, 0.1)';
        element.style.color = '#00c853';
        element.style.border = '1px solid rgba(0, 200, 83, 0.3)';
    } else {
        element.style.background = 'rgba(211, 47, 47, 0.1)';
        element.style.color = '#d32f2f';
        element.style.border = '1px solid rgba(211, 47, 47, 0.3)';
    }
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
        element.style.display = 'none';
    }, 5000);
}

