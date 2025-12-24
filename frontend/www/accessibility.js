// Accessibility Enhancements for ZUBID

// Keyboard Navigation
const KeyboardNavigation = {
    init() {
        // Add skip to content link
        this.addSkipToContent();
        
        // Enhance modal keyboard navigation
        this.enhanceModals();
        
        // Add keyboard shortcuts
        this.addKeyboardShortcuts();
        
        // Trap focus in modals
        this.setupFocusTrap();
    },
    
    addSkipToContent() {
        if (document.getElementById('skip-to-content')) return;
        
        const skipLink = document.createElement('a');
        skipLink.href = '#main-content';
        skipLink.id = 'skip-to-content';
        skipLink.className = 'skip-to-content';
        skipLink.textContent = 'Skip to main content';
        document.body.insertBefore(skipLink, document.body.firstChild);
        
        // Add main content landmark if missing
        const mainContent = document.getElementById('main-content') || 
                           document.querySelector('main') ||
                           document.querySelector('.container');
        if (mainContent && !mainContent.id) {
            mainContent.id = 'main-content';
        }
    },
    
    enhanceModals() {
        document.addEventListener('keydown', (e) => {
            // Close modal on Escape
            if (e.key === 'Escape') {
                const openModal = document.querySelector('.modal[style*="display: flex"], .modal[style*="display: block"]');
                if (openModal) {
                    const closeBtn = openModal.querySelector('[data-dismiss="modal"], .close-modal');
                    if (closeBtn) {
                        closeBtn.click();
                    }
                }
            }
        });
    },
    
    addKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Alt + S: Focus search
            if (e.altKey && e.key === 's') {
                e.preventDefault();
                const searchInput = document.querySelector('input[type="search"], #searchInput, #searchFilter');
                if (searchInput) {
                    searchInput.focus();
                }
            }
            
            // Alt + H: Go to home
            if (e.altKey && e.key === 'h') {
                e.preventDefault();
                window.location.href = 'index.html';
            }
            
            // Alt + A: Go to auctions
            if (e.altKey && e.key === 'a') {
                e.preventDefault();
                window.location.href = 'auctions.html';
            }
        });
    },
    
    setupFocusTrap() {
        document.addEventListener('keydown', (e) => {
            const modal = document.querySelector('.modal[style*="display: flex"], .modal[style*="display: block"]');
            if (!modal || e.key !== 'Tab') return;
            
            const focusableElements = modal.querySelectorAll(
                'a[href], button:not([disabled]), textarea:not([disabled]), input:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])'
            );
            
            if (focusableElements.length === 0) return;
            
            const firstElement = focusableElements[0];
            const lastElement = focusableElements[focusableElements.length - 1];
            
            if (e.shiftKey && document.activeElement === firstElement) {
                e.preventDefault();
                lastElement.focus();
            } else if (!e.shiftKey && document.activeElement === lastElement) {
                e.preventDefault();
                firstElement.focus();
            }
        });
    }
};

// Screen Reader Announcements
const ScreenReader = {
    announce(message, priority = 'polite') {
        const announcement = document.createElement('div');
        announcement.setAttribute('role', 'status');
        announcement.setAttribute('aria-live', priority);
        announcement.setAttribute('aria-atomic', 'true');
        announcement.className = 'sr-only';
        announcement.style.cssText = `
            position: absolute;
            left: -10000px;
            width: 1px;
            height: 1px;
            overflow: hidden;
        `;
        announcement.textContent = message;
        document.body.appendChild(announcement);
        
        setTimeout(() => {
            document.body.removeChild(announcement);
        }, 1000);
    }
};

// ARIA Label Management
const ARIAHelper = {
    enhanceButtons() {
        document.querySelectorAll('button:not([aria-label]):not([aria-labelledby])').forEach(btn => {
            if (btn.textContent.trim() && !btn.getAttribute('aria-label')) {
                // Only add if button has meaningful text
                if (btn.textContent.trim().length > 0) {
                    btn.setAttribute('aria-label', btn.textContent.trim());
                }
            }
        });
    },
    
    enhanceImages() {
        document.querySelectorAll('img:not([alt])').forEach(img => {
            if (!img.getAttribute('alt')) {
                // Try to infer alt text from context
                const parent = img.closest('.auction-card, .carousel-item');
                if (parent) {
                    const title = parent.querySelector('h2, h3, .item-name');
                    if (title) {
                        img.setAttribute('alt', title.textContent.trim());
                    } else {
                        img.setAttribute('alt', 'Auction item image');
                    }
                } else {
                    img.setAttribute('alt', '');
                }
            }
        });
    },
    
    enhanceForms() {
        document.querySelectorAll('form').forEach(form => {
            if (!form.getAttribute('aria-label') && !form.getAttribute('aria-labelledby')) {
                const legend = form.querySelector('legend');
                const title = form.querySelector('h2, h3');
                if (legend) {
                    form.setAttribute('aria-labelledby', legend.id || 'form-title');
                } else if (title) {
                    form.setAttribute('aria-labelledby', title.id || 'form-title');
                }
            }
        });
    }
};

// Initialize on load
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        KeyboardNavigation.init();
        ARIAHelper.enhanceButtons();
        ARIAHelper.enhanceImages();
        ARIAHelper.enhanceForms();
    });
    
    window.KeyboardNavigation = KeyboardNavigation;
    window.ScreenReader = ScreenReader;
    window.ARIAHelper = ARIAHelper;
}

