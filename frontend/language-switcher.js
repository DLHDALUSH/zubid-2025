// Helper function to add language switcher to navigation if it doesn't exist
function addLanguageSwitcher() {
    const navMenu = document.getElementById('navMenu');
    if (!navMenu) return;
    
    // Check if language switcher already exists
    if (document.getElementById('languageSwitcher')) return;
    
    // Find nav-auth or nav-user to insert before
    const navAuth = document.getElementById('navAuth');
    const navUser = document.getElementById('navUser');
    const insertBefore = navAuth || navUser;
    
    if (insertBefore) {
        const languageSwitcher = document.createElement('div');
        languageSwitcher.className = 'language-switcher';
        languageSwitcher.id = 'languageSwitcher';
        languageSwitcher.innerHTML = `
            <button class="language-switcher-btn" onclick="toggleLanguageDropdown()">
                <span id="currentLangDisplay">EN</span>
                <span>▼</span>
            </button>
            <div class="language-dropdown" id="languageDropdown">
                <div class="language-option active" data-lang="en" onclick="changeLang('en')">
                    <span>English</span>
                </div>
                <div class="language-option" data-lang="ku" onclick="changeLang('ku')">
                    <span>کوردی</span>
                </div>
                <div class="language-option" data-lang="ar" onclick="changeLang('ar')">
                    <span>العربية</span>
                </div>
            </div>
        `;
        navMenu.insertBefore(languageSwitcher, insertBefore);
    }
}

// Run when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', addLanguageSwitcher);
} else {
    addLanguageSwitcher();
}

