# ZUBID Build Script for Capacitor
# This script copies web files to www folder for mobile build

Write-Host "Building ZUBID for mobile..." -ForegroundColor Cyan

# Create www directory if it doesn't exist
if (!(Test-Path "www")) {
    New-Item -ItemType Directory -Path "www" | Out-Null
}

# Clean www directory
Remove-Item -Path "www\*" -Recurse -Force -ErrorAction SilentlyContinue

# Files and folders to copy
$filesToCopy = @(
    "index.html",
    "auctions.html",
    "my-bids.html",
    "payments.html",
    "profile.html",
    "admin.html",
    "styles.css",
    "app.js",
    "api.js",
    "auctions.js",
    "payments.js",
    "utils.js",
    "enhanced-utils.js",
    "performance.js",
    "accessibility.js",
    "i18n.js",
    "manifest.json",
    "sw.js"
)

$foldersToCopy = @(
    "icons"
)

# Copy files
foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Copy-Item $file -Destination "www\" -Force
        Write-Host "  Copied: $file" -ForegroundColor Green
    } else {
        Write-Host "  Skipped (not found): $file" -ForegroundColor Yellow
    }
}

# Copy folders
foreach ($folder in $foldersToCopy) {
    if (Test-Path $folder) {
        Copy-Item $folder -Destination "www\" -Recurse -Force
        Write-Host "  Copied folder: $folder" -ForegroundColor Green
    } else {
        Write-Host "  Skipped folder (not found): $folder" -ForegroundColor Yellow
    }
}

Write-Host "`nBuild complete! Files copied to www/" -ForegroundColor Cyan
Write-Host "Run 'npx cap sync' to sync with native projects" -ForegroundColor White

