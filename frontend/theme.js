// 🌙 ZUBID Theme Manager - Dark Mode & Light Mode Toggle
// =====================================================

const ThemeManager = {
    STORAGE_KEY: 'zubid-theme',
    COLOR_STORAGE_KEY: 'zubid-color-scheme',
    DARK: 'dark',
    LIGHT: 'light',

    // Available color schemes for the entire site
    DEFAULT_COLOR_SCHEME: 'classic',
    AVAILABLE_COLOR_SCHEMES: ['classic', 'emerald', 'amber'],

    init() {
        // Check for saved preference or system preference
        const savedTheme = localStorage.getItem(this.STORAGE_KEY);
        const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

        // Apply theme: saved > system > light (default)
        const theme = savedTheme || (systemPrefersDark ? this.DARK : this.LIGHT);
        this.setTheme(theme, false);

        // Apply saved color scheme (or default)
        const savedScheme = localStorage.getItem(this.COLOR_STORAGE_KEY) || this.DEFAULT_COLOR_SCHEME;
        this.setColorScheme(savedScheme, false);

        // Listen for system theme changes (only when user has not chosen explicitly)
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            if (!localStorage.getItem(this.STORAGE_KEY)) {
                this.setTheme(e.matches ? this.DARK : this.LIGHT, false);
            }
        });

        // Setup UI controls
        this.setupToggleButton();
        this.setupColorSchemeControls();
    },

    setTheme(theme, save = true) {
        document.documentElement.setAttribute('data-theme', theme);

        if (save) {
            localStorage.setItem(this.STORAGE_KEY, theme);
        }

        // Update meta theme color (use primary-like color in light, deeper tone in dark)
        const metaTheme = document.querySelector('meta[name="theme-color"]');
        if (metaTheme) {
            metaTheme.setAttribute('content', theme === this.DARK ? '#020617' : '#2563eb');
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
            const message = newTheme === this.DARK ? 'Dark mode enabled' : 'Light mode enabled';
            showToast(message, 'success');
        }
    },

    getCurrentTheme() {
        return document.documentElement.getAttribute('data-theme') || this.LIGHT;
    },

    // ----- Color Scheme Management -----

    setColorScheme(scheme, save = true) {
        if (!this.AVAILABLE_COLOR_SCHEMES.includes(scheme)) {
            scheme = this.DEFAULT_COLOR_SCHEME;
        }

        document.documentElement.setAttribute('data-color-scheme', scheme);

        if (save) {
            localStorage.setItem(this.COLOR_STORAGE_KEY, scheme);
        }

        this.updateColorSchemeControls(scheme);
    },

    getCurrentColorScheme() {
        return (
            document.documentElement.getAttribute('data-color-scheme') ||
            localStorage.getItem(this.COLOR_STORAGE_KEY) ||
            this.DEFAULT_COLOR_SCHEME
        );
    },

    setupToggleButton() {
        const toggleBtns = document.querySelectorAll('.theme-toggle');
        toggleBtns.forEach((btn) => {
            btn.addEventListener('click', () => this.toggle());
        });
    },

    setupColorSchemeControls() {
        const buttons = document.querySelectorAll('[data-color-scheme-select]');
        if (!buttons.length) return;

        const current = this.getCurrentColorScheme();

        buttons.forEach((btn) => {
            const scheme = btn.getAttribute('data-color-scheme-select');
            btn.addEventListener('click', () => {
                this.setColorScheme(scheme);
            });
        });

        this.updateColorSchemeControls(current);
    },

    updateColorSchemeControls(activeScheme) {
        const buttons = document.querySelectorAll('[data-color-scheme-select]');
        buttons.forEach((btn) => {
            const scheme = btn.getAttribute('data-color-scheme-select');
            const isActive = scheme === activeScheme;
            btn.classList.toggle('is-active', isActive);
            btn.setAttribute('aria-pressed', isActive ? 'true' : 'false');
        });
    },
};

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    ThemeManager.init();
});

// Export for use in other modules
window.ThemeManager = ThemeManager;

// Global function for onclick handlers
function toggleTheme() {
    ThemeManager.toggle();
}
window.toggleTheme = toggleTheme;
