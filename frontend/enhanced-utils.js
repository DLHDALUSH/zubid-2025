// Enhanced Utility Functions for ZUBID
// Provides improved error handling, loading states, and user feedback

// Loading State Management
const LoadingManager = {
    activeLoaders: new Set(),
    
    show(elementId, message = 'Loading...') {
        const element = document.getElementById(elementId);
        if (!element) return;
        
        this.activeLoaders.add(elementId);
        element.style.display = 'block';
        element.innerHTML = `
            <div class="loading-skeleton">
                <div class="skeleton-spinner"></div>
                <p>${message}</p>
            </div>
        `;
    },
    
    hide(elementId) {
        const element = document.getElementById(elementId);
        if (element) {
            element.style.display = 'none';
            element.innerHTML = '';
        }
        this.activeLoaders.delete(elementId);
    },
    
    hideAll() {
        this.activeLoaders.forEach(id => this.hide(id));
        this.activeLoaders.clear();
    }
};

// Enhanced Toast Notification System
const ToastManager = {
    queue: [],
    isShowing: false,
    
    show(message, type = 'info', duration = 3000) {
        const toast = {
            message,
            type,
            duration,
            id: Date.now()
        };
        
        this.queue.push(toast);
        this.processQueue();
    },
    
    processQueue() {
        if (this.isShowing || this.queue.length === 0) return;
        
        this.isShowing = true;
        const toast = this.queue.shift();
        this.displayToast(toast);
    },
    
    displayToast(toast) {
        let toastContainer = document.getElementById('toastContainer');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.id = 'toastContainer';
            toastContainer.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 10000;
                display: flex;
                flex-direction: column;
                gap: 10px;
                pointer-events: none;
            `;
            document.body.appendChild(toastContainer);
        }
        
        const toastEl = document.createElement('div');
        toastEl.className = `toast toast-${toast.type}`;
        toastEl.style.cssText = `
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            padding: 1rem 1.5rem;
            border-radius: 12px;
            box-shadow: var(--shadow-lg);
            border: 2px solid var(--glass-border);
            min-width: 300px;
            max-width: 500px;
            pointer-events: auto;
            animation: slideInRight 0.3s ease-out;
            display: flex;
            align-items: center;
            gap: 1rem;
        `;
        
        const icons = {
            success: '✅',
            error: '❌',
            warning: '⚠️',
            info: 'ℹ️'
        };
        
        toastEl.innerHTML = `
            <span style="font-size: 1.5rem;">${icons[toast.type] || icons.info}</span>
            <span style="flex: 1; color: var(--text-color);">${this.escapeHtml(toast.message)}</span>
            <button onclick="this.parentElement.remove(); ToastManager.onToastClose();" 
                    style="background: none; border: none; font-size: 1.2rem; cursor: pointer; color: var(--text-secondary); padding: 0; width: 24px; height: 24px; display: flex; align-items: center; justify-content: center;">×</button>
        `;
        
        toastContainer.appendChild(toastEl);
        
        // Auto remove after duration
        setTimeout(() => {
            toastEl.style.animation = 'slideOutRight 0.3s ease-in';
            setTimeout(() => {
                toastEl.remove();
                this.onToastClose();
            }, 300);
        }, toast.duration);
    },
    
    onToastClose() {
        this.isShowing = false;
        this.processQueue();
    },
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
};

// Enhanced Error Handler
const ErrorHandler = {
    handle(error, context = '') {
        console.error(`[${context}] Error:`, error);
        
        let userMessage = 'An unexpected error occurred. Please try again.';
        
        if (error.message) {
            if (error.message.includes('fetch') || error.message.includes('network')) {
                userMessage = 'Network error. Please check your internet connection.';
            } else if (error.message.includes('401') || error.message.includes('Authentication')) {
                userMessage = 'Please log in to continue.';
            } else if (error.message.includes('403') || error.message.includes('Forbidden')) {
                userMessage = 'You do not have permission to perform this action.';
            } else if (error.message.includes('404') || error.message.includes('Not found')) {
                userMessage = 'The requested resource was not found.';
            } else if (error.message.includes('500') || error.message.includes('Server error')) {
                userMessage = 'Server error. Please try again later.';
            } else {
                userMessage = error.message;
            }
        }
        
        ToastManager.show(userMessage, 'error');
        
        // Log to error tracking service (if available)
        if (window.errorTracker) {
            window.errorTracker.log(error, context);
        }
        
        return userMessage;
    }
};

// Form Validation Helper
const FormValidator = {
    validateEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    },
    
    validatePhone(phone) {
        const cleaned = phone.replace(/\D/g, '');
        return cleaned.length >= 8 && cleaned.length <= 15;
    },
    
    validatePassword(password) {
        return {
            valid: password.length >= 8,
            strength: this.getPasswordStrength(password),
            requirements: {
                length: password.length >= 8,
                uppercase: /[A-Z]/.test(password),
                lowercase: /[a-z]/.test(password),
                number: /\d/.test(password),
                special: /[!@#$%^&*(),.?":{}|<>]/.test(password)
            }
        };
    },
    
    getPasswordStrength(password) {
        let strength = 0;
        if (password.length >= 8) strength++;
        if (password.length >= 12) strength++;
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
        if (/\d/.test(password)) strength++;
        if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) strength++;
        
        if (strength <= 2) return 'weak';
        if (strength <= 3) return 'medium';
        if (strength <= 4) return 'strong';
        return 'very-strong';
    },
    
    validateRequired(value) {
        return value !== null && value !== undefined && String(value).trim().length > 0;
    },
    
    validateNumber(value, min = null, max = null) {
        const num = parseFloat(value);
        if (isNaN(num)) return false;
        if (min !== null && num < min) return false;
        if (max !== null && num > max) return false;
        return true;
    }
};

// Image Lazy Loading
const ImageLoader = {
    observer: null,
    
    init() {
        if ('IntersectionObserver' in window) {
            this.observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        this.loadImage(img);
                        this.observer.unobserve(img);
                    }
                });
            }, {
                rootMargin: '50px'
            });
        }
    },
    
    loadImage(img) {
        if (img.dataset.src) {
            img.src = img.dataset.src;
            img.classList.add('loaded');
            img.removeAttribute('data-src');
        }
    },
    
    observe(img) {
        if (this.observer) {
            this.observer.observe(img);
        } else {
            // Fallback for browsers without IntersectionObserver
            this.loadImage(img);
        }
    }
};

// Initialize on load
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        ImageLoader.init();
    });
}

// Export for global use
if (typeof window !== 'undefined') {
    window.LoadingManager = LoadingManager;
    window.ToastManager = ToastManager;
    window.ErrorHandler = ErrorHandler;
    window.FormValidator = FormValidator;
    window.ImageLoader = ImageLoader;
    
    // Enhanced showToast function
    window.showToast = (message, type = 'info', duration = 3000) => {
        ToastManager.show(message, type, duration);
    };
}

