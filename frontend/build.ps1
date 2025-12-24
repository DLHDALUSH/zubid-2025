# ZUBID Build Script for Capacitor
# This script copies web files to www folder for mobile build

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ZUBID Mobile Build Script" -ForegroundColor Cyan
Write-Host "  Building for Android & iOS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Create www directory if it doesn't exist
if (!(Test-Path "www")) {
    New-Item -ItemType Directory -Path "www" | Out-Null
    Write-Host "Created www directory" -ForegroundColor Green
}

# Clean www directory
Write-Host "Cleaning www directory..." -ForegroundColor Yellow
Remove-Item -Path "www\*" -Recurse -Force -ErrorAction SilentlyContinue

# HTML files
$htmlFiles = @(
    "index.html",
    "auctions.html",
    "auction-detail.html",
    "my-auctions.html",
    "my-bids.html",
    "payments.html",
    "profile.html",
    "admin.html",
    "admin-auctions.html",
    "admin-categories.html",
    "admin-users.html",
    "admin-create-auction.html",
    "create-auction.html",
    "contact-us.html",
    "how-to-bid.html",
    "return-requests.html"
)

# CSS files
$cssFiles = @(
    "styles.css",
    "admin.css"
)

# JavaScript files
$jsFiles = @(
    "app.js",
    "api.js",
    "auctions.js",
    "auction-detail.js",
    "my-auctions.js",
    "my-bids.js",
    "payments.js",
    "profile.js",
    "profile-standalone.js",
    "admin.js",
    "admin-auctions.js",
    "admin-categories.js",
    "admin-users.js",
    "admin-create-auction.js",
    "create-auction.js",
    "contact-us.js",
    "how-to-bid.js",
    "return-requests.js",
    "utils.js",
    "enhanced-utils.js",
    "performance.js",
    "accessibility.js",
    "i18n.js",
    "language-switcher.js",
    "notifications.js",
    "social-share.js",
    "theme.js",
    "config.production.js",
    "push-notifications.js"
)

# Other files
$otherFiles = @(
    "manifest.json",
    "sw.js"
)

# Folders to copy
$foldersToCopy = @(
    "icons"
)

Write-Host ""
Write-Host "Copying HTML files..." -ForegroundColor Cyan
foreach ($file in $htmlFiles) {
    if (Test-Path $file) {
        Copy-Item $file -Destination "www\" -Force
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [--] $file (not found)" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "Copying CSS files..." -ForegroundColor Cyan
foreach ($file in $cssFiles) {
    if (Test-Path $file) {
        Copy-Item $file -Destination "www\" -Force
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [--] $file (not found)" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "Copying JavaScript files..." -ForegroundColor Cyan
foreach ($file in $jsFiles) {
    if (Test-Path $file) {
        Copy-Item $file -Destination "www\" -Force
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [--] $file (not found)" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "Copying other files..." -ForegroundColor Cyan
foreach ($file in $otherFiles) {
    if (Test-Path $file) {
        Copy-Item $file -Destination "www\" -Force
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [--] $file (not found)" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "Copying folders..." -ForegroundColor Cyan
foreach ($folder in $foldersToCopy) {
    if (Test-Path $folder) {
        Copy-Item $folder -Destination "www\" -Recurse -Force
        Write-Host "  [OK] $folder/" -ForegroundColor Green
    } else {
        Write-Host "  [--] $folder/ (not found)" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Build complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. npx cap sync              - Sync to all platforms" -ForegroundColor Yellow
Write-Host "  2. npx cap sync android      - Sync to Android only" -ForegroundColor Yellow
Write-Host "  3. npx cap sync ios          - Sync to iOS only" -ForegroundColor Yellow
Write-Host "  4. npx cap open android      - Open Android Studio" -ForegroundColor Yellow
Write-Host "  5. npx cap open ios          - Open Xcode (Mac only)" -ForegroundColor Yellow
Write-Host ""

