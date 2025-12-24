# Setup Splash Screens for ZUBID - Android & iOS
# This script sets up splash screen images for both platforms

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ZUBID Splash Screen Setup" -ForegroundColor Cyan
Write-Host "  Android & iOS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if splash source exists
$splashSource = "icons\icon-512x512.png"
if (!(Test-Path $splashSource)) {
    $splashSource = "icons\icon-192x192.png"
}

if (!(Test-Path $splashSource)) {
    Write-Host "[ERROR] No source image found in icons/ folder" -ForegroundColor Red
    Write-Host "Please add a splash image (icon-512x512.png recommended)" -ForegroundColor Yellow
    exit 1
}

Write-Host "Using source: $splashSource" -ForegroundColor Green
Write-Host ""

# ============================================
# ANDROID SPLASH SCREENS
# ============================================
Write-Host "Setting up Android splash screens..." -ForegroundColor Yellow

$androidResDir = "android\app\src\main\res"

# Android splash screen directories and sizes
$androidSplashDirs = @(
    "drawable",
    "drawable-port-hdpi",
    "drawable-port-mdpi", 
    "drawable-port-xhdpi",
    "drawable-port-xxhdpi",
    "drawable-port-xxxhdpi",
    "drawable-land-hdpi",
    "drawable-land-mdpi",
    "drawable-land-xhdpi", 
    "drawable-land-xxhdpi",
    "drawable-land-xxxhdpi"
)

foreach ($dir in $androidSplashDirs) {
    $destDir = "$androidResDir\$dir"
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item $splashSource -Destination "$destDir\splash.png" -Force
    Write-Host "  [OK] $dir\splash.png" -ForegroundColor Green
}

# ============================================
# iOS SPLASH SCREENS
# ============================================
Write-Host ""
Write-Host "Setting up iOS splash screens..." -ForegroundColor Yellow

$iosSplashDir = "ios\App\App\Assets.xcassets\Splash.imageset"

if (Test-Path $iosSplashDir) {
    # Copy splash images for iOS
    Copy-Item $splashSource -Destination "$iosSplashDir\splash-2732x2732.png" -Force
    Copy-Item $splashSource -Destination "$iosSplashDir\splash-2732x2732-1.png" -Force
    Copy-Item $splashSource -Destination "$iosSplashDir\splash-2732x2732-2.png" -Force
    
    Write-Host "  [OK] splash-2732x2732.png" -ForegroundColor Green
    Write-Host "  [OK] splash-2732x2732-1.png" -ForegroundColor Green
    Write-Host "  [OK] splash-2732x2732-2.png" -ForegroundColor Green
    
    # Update Contents.json
    $splashContents = @'
{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "splash-2732x2732.png",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "filename" : "splash-2732x2732-1.png",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "filename" : "splash-2732x2732-2.png",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
'@
    $splashContents | Out-File -FilePath "$iosSplashDir\Contents.json" -Encoding UTF8 -Force
    Write-Host "  [OK] Contents.json" -ForegroundColor Green
} else {
    Write-Host "  [--] iOS splash directory not found" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Splash screen setup complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "For best results, create a splash image at:" -ForegroundColor White
Write-Host "  - 2732x2732 pixels (for iOS)" -ForegroundColor Yellow
Write-Host "  - With your logo centered" -ForegroundColor Yellow
Write-Host "  - Background color: #FF6600 (ZUBID orange)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Run 'npx cap sync' to apply changes" -ForegroundColor White

