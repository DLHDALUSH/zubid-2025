# Setup App Icons for ZUBID - Android & iOS
# This script copies icons to the correct locations for both platforms

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ZUBID App Icon Setup" -ForegroundColor Cyan
Write-Host "  Android & iOS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# ANDROID ICONS
# ============================================
Write-Host "Setting up Android icons..." -ForegroundColor Yellow

$androidResDir = "android\app\src\main\res"

# Android icon mappings (density -> source icon)
# mdpi: 48x48, hdpi: 72x72, xhdpi: 96x96, xxhdpi: 144x144, xxxhdpi: 192x192
$androidIconMappings = @{
    "mipmap-mdpi" = "icon-72x72.png"      # 48dp (using 72 as closest)
    "mipmap-hdpi" = "icon-72x72.png"      # 72dp
    "mipmap-xhdpi" = "icon-96x96.png"     # 96dp
    "mipmap-xxhdpi" = "icon-144x144.png"  # 144dp
    "mipmap-xxxhdpi" = "icon-192x192.png" # 192dp
}

foreach ($mapping in $androidIconMappings.GetEnumerator()) {
    $destDir = "$androidResDir\$($mapping.Key)"
    $srcFile = "icons\$($mapping.Value)"

    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    if (Test-Path $srcFile) {
        Copy-Item $srcFile -Destination "$destDir\ic_launcher.png" -Force
        Copy-Item $srcFile -Destination "$destDir\ic_launcher_round.png" -Force
        Copy-Item $srcFile -Destination "$destDir\ic_launcher_foreground.png" -Force
        Write-Host "  [OK] $($mapping.Key)" -ForegroundColor Green
    } else {
        Write-Host "  [--] $($mapping.Key) - source not found: $srcFile" -ForegroundColor DarkGray
    }
}

# ============================================
# iOS ICONS
# ============================================
Write-Host ""
Write-Host "Setting up iOS icons..." -ForegroundColor Yellow

$iosIconDir = "ios\App\App\Assets.xcassets\AppIcon.appiconset"

if (Test-Path $iosIconDir) {
    # iOS uses different sizes - we'll copy closest matches
    # iOS requires specific sizes: 20, 29, 40, 60, 76, 83.5, 1024 (App Store)

    $iosIconMappings = @{
        "icon-72x72.png" = @("Icon-App-20x20@2x.png", "Icon-App-20x20@3x.png", "Icon-App-29x29@2x.png")
        "icon-96x96.png" = @("Icon-App-29x29@3x.png", "Icon-App-40x40@2x.png")
        "icon-128x128.png" = @("Icon-App-40x40@3x.png", "Icon-App-60x60@2x.png")
        "icon-192x192.png" = @("Icon-App-60x60@3x.png", "Icon-App-76x76@2x.png", "Icon-App-83.5x83.5@2x.png")
        "icon-512x512.png" = @("Icon-App-1024x1024@1x.png")
    }

    foreach ($mapping in $iosIconMappings.GetEnumerator()) {
        $srcFile = "icons\$($mapping.Key)"
        if (Test-Path $srcFile) {
            foreach ($destName in $mapping.Value) {
                Copy-Item $srcFile -Destination "$iosIconDir\$destName" -Force
                Write-Host "  [OK] $destName" -ForegroundColor Green
            }
        }
    }

    # Create Contents.json for iOS icons
    $contentsJson = @'
{
  "images" : [
    { "idiom" : "iphone", "scale" : "2x", "size" : "20x20", "filename" : "Icon-App-20x20@2x.png" },
    { "idiom" : "iphone", "scale" : "3x", "size" : "20x20", "filename" : "Icon-App-20x20@3x.png" },
    { "idiom" : "iphone", "scale" : "2x", "size" : "29x29", "filename" : "Icon-App-29x29@2x.png" },
    { "idiom" : "iphone", "scale" : "3x", "size" : "29x29", "filename" : "Icon-App-29x29@3x.png" },
    { "idiom" : "iphone", "scale" : "2x", "size" : "40x40", "filename" : "Icon-App-40x40@2x.png" },
    { "idiom" : "iphone", "scale" : "3x", "size" : "40x40", "filename" : "Icon-App-40x40@3x.png" },
    { "idiom" : "iphone", "scale" : "2x", "size" : "60x60", "filename" : "Icon-App-60x60@2x.png" },
    { "idiom" : "iphone", "scale" : "3x", "size" : "60x60", "filename" : "Icon-App-60x60@3x.png" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "20x20", "filename" : "Icon-App-20x20@2x.png" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "29x29", "filename" : "Icon-App-29x29@2x.png" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "40x40", "filename" : "Icon-App-40x40@2x.png" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "76x76", "filename" : "Icon-App-76x76@2x.png" },
    { "idiom" : "ipad", "scale" : "2x", "size" : "83.5x83.5", "filename" : "Icon-App-83.5x83.5@2x.png" },
    { "idiom" : "ios-marketing", "scale" : "1x", "size" : "1024x1024", "filename" : "Icon-App-1024x1024@1x.png" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
'@
    $contentsJson | Out-File -FilePath "$iosIconDir\Contents.json" -Encoding UTF8 -Force
    Write-Host "  [OK] Contents.json updated" -ForegroundColor Green
} else {
    Write-Host "  [--] iOS directory not found (run 'npx cap add ios' first)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Icon setup complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: For best results, create icons at these exact sizes:" -ForegroundColor White
Write-Host "  - 1024x1024 (App Store)" -ForegroundColor Yellow
Write-Host "  - 512x512" -ForegroundColor Yellow
Write-Host "  - 192x192" -ForegroundColor Yellow
Write-Host "  - 144x144" -ForegroundColor Yellow
Write-Host "  - 96x96" -ForegroundColor Yellow
Write-Host "  - 72x72" -ForegroundColor Yellow
Write-Host ""

