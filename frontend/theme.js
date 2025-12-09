// 🌙 ZUBID Theme Manager - Dark Mode & Light Mode Toggle
// =====================================================

const ThemeManager = {
    STORAGE_KEY: 'zubid-theme',
    DARK: 'dark',
    LIGHT: 'light',

    init() {
        // Check for saved preference or system preference
        const savedTheme = localStorage.getItem(this.STORAGE_KEY);
        const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

        // Apply theme: saved > system > light (default)
        const theme = savedTheme || (systemPrefersDark ? this.DARK : this.LIGHT);
        this.setTheme(theme, false);

        // Listen for system theme changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            if (!localStorage.getItem(this.STORAGE_KEY)) {
                this.setTheme(e.matches ? this.DARK : this.LIGHT, false);
            }
        });

        // Setup toggle button
        this.setupToggleButton();
    },

    setTheme(theme, save = true) {
        document.documentElement.setAttribute('data-theme', theme);
        
        if (save) {
            localStorage.setItem(this.STORAGE_KEY, theme);
        }

        // Update meta theme color
        const metaTheme = document.querySelector('meta[name="theme-color"]');
        if (metaTheme) {
            metaTheme.setAttribute('content', theme === this.DARK ? '#0f172a' : '#6366f1');
        }

        // Dispatch custom event
        window.dispatchEvent(new CustomEvent('themechange', { detail: { theme } }));
    },

    toggle() {
        const current = document.documentElement.getAttribute('data-theme') || this.LIGHT;
        const newTheme = current === this.DARK ? this.LIGHT : this.DARK;
        this.setTheme(newTheme);
        
        // Show toast notification
        if (typeof showToast === 'function') {
            const message = newTheme === this.DARK ? '🌙 Dark mode enabled' : '☀️ Light mode enabled';
            showToast(message, 'success');
        }
    },

    getCurrentTheme() {
        return document.documentElement.getAttribute('data-theme') || this.LIGHT;
    },

    setupToggleButton() {
        const toggleBtns = document.querySelectorAll('.theme-toggle');
        toggleBtns.forEach(btn => {
            btn.addEventListener('click', () => this.toggle());
        });
    }
};

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    ThemeManager.init();
});

// Export for use in other modules
window.ThemeManager = ThemeManager;

