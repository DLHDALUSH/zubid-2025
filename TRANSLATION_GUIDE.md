# Translation System (i18n) Documentation

## Overview

The ZUBID platform now supports **three languages**:
- **English** (en) - Default
- **Kurdish** (ku) - کوردی
- **Arabic** (ar) - العربية

## Features

- ✅ Full RTL (Right-to-Left) support for Kurdish and Arabic
- ✅ Language switcher in navigation
- ✅ Persistent language preference (saved in localStorage)
- ✅ Automatic translation of all UI elements
- ✅ Dynamic content translation support

## How to Use

### 1. Include Required Scripts

Add these scripts to your HTML files **before** closing `</body>` tag:

```html
<!-- Translation System -->
<script src="i18n.js"></script>
<!-- Language Switcher Helper (optional, for pages without switcher) -->
<script src="language-switcher.js"></script>
```

### 2. Add Translation Attributes to HTML

Use `data-i18n` attribute for translatable text:

```html
<!-- Simple text -->
<h2 data-i18n="home.featuredAuctions">Featured Auctions</h2>
<a href="#" data-i18n="nav.home">Home</a>

<!-- Buttons -->
<button data-i18n="nav.login">Login</button>

<!-- Input placeholders -->
<input type="text" data-i18n-placeholder="common.searchPlaceholder" placeholder="Search...">
```

### 3. Use Translations in JavaScript

Use the `t()` function for dynamic content:

```javascript
// Basic usage
const message = i18n.t('auth.loginSuccess');
showToast(message);

// With fallback
const message = i18n.t('auth.loginSuccess', 'Login successful!');

// Access nested translations
const navHome = i18n.t('nav.home');
```

### 4. Language Switcher

The language switcher is automatically added to navigation. Users can:
- Click the language button to see available languages
- Select a language to switch immediately
- Their preference is saved automatically

## Available Translation Keys

### Navigation (`nav.*`)
- `nav.home` - Home
- `nav.auctions` - Auctions
- `nav.myBids` - My Bids
- `nav.payments` - Payments
- `nav.profile` - Profile
- `nav.admin` - Admin
- `nav.login` - Login
- `nav.signUp` - Sign Up
- `nav.logout` - Logout

### Common (`common.*`)
- `common.search` - Search
- `common.searchPlaceholder` - Search placeholder text
- `common.loading` - Loading...
- `common.error` - Error
- `common.success` - Success
- `common.cancel` - Cancel
- `common.confirm` - Confirm
- `common.save` - Save
- `common.delete` - Delete
- `common.edit` - Edit
- `common.create` - Create
- `common.update` - Update
- `common.close` - Close

### Authentication (`auth.*`)
- `auth.login` - Login
- `auth.signUp` - Sign Up
- `auth.logout` - Logout
- `auth.username` - Username
- `auth.password` - Password
- `auth.email` - Email
- `auth.loginSuccess` - Login successful!
- `auth.loginFailed` - Login failed...

### Auctions (`auctions.*`)
- `auctions.title` - All Auctions
- `auctions.featured` - Featured Auctions
- `auctions.currentBid` - Current Bid
- `auctions.placeBid` - Place Bid
- `auctions.bidPlaced` - Bid placed successfully
- And many more...

### And More...

See `frontend/i18n.js` for the complete list of available translation keys.

## Adding New Translations

To add new translations:

1. Open `frontend/i18n.js`
2. Find the appropriate section (e.g., `nav`, `common`, `auth`)
3. Add your key-value pairs for all three languages:

```javascript
en: {
    nav: {
        // ... existing translations
        newKey: 'English Text'
    }
},
ku: {
    nav: {
        // ... existing translations
        newKey: 'کوردی Text'
    }
},
ar: {
    nav: {
        // ... existing translations
        newKey: 'النص العربي'
    }
}
```

4. Use in HTML: `<span data-i18n="nav.newKey">English Text</span>`
5. Use in JavaScript: `i18n.t('nav.newKey')`

## RTL Support

RTL (Right-to-Left) is automatically applied for Kurdish and Arabic:
- Navigation reverses direction
- Text alignment adjusts
- Forms and inputs adapt
- Modal dialogs adapt

No additional CSS needed - it's handled automatically!

## Language Change Events

Listen for language changes:

```javascript
document.addEventListener('languageChanged', function(event) {
    const newLang = event.detail.language;
    console.log('Language changed to:', newLang);
    // Update your dynamic content here
});
```

## Best Practices

1. **Always provide fallback text** in HTML for accessibility
2. **Use translation keys** consistently across the app
3. **Test all languages** when adding new features
4. **Keep translations concise** - RTL languages may need more space
5. **Use `i18n.t()`** for dynamic JavaScript content

## Files Modified

- `frontend/i18n.js` - Translation system core
- `frontend/language-switcher.js` - Language switcher helper
- `frontend/styles.css` - RTL and language switcher styles
- `frontend/index.html` - Example implementation

## Quick Start

1. Include `i18n.js` in your HTML
2. Add `data-i18n` attributes to translatable elements
3. Use `i18n.t('key')` in JavaScript for dynamic content
4. That's it! The system handles the rest automatically.

## Support

For questions or issues with translations, check:
- `frontend/i18n.js` - Full translation dictionary
- Browser console for translation errors
- localStorage for language preference

---

**Note:** The language preference is saved in browser localStorage and persists across sessions.

