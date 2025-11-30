# Setup Android Icons for ZUBID
Write-Host "Setting up Android app icons..." -ForegroundColor Cyan

$resDir = "android\app\src\main\res"

# Icon mappings (Android density -> our icon size)
$iconMappings = @{
    "mipmap-mdpi" = "icon-72x72.png"
    "mipmap-hdpi" = "icon-72x72.png"
    "mipmap-xhdpi" = "icon-96x96.png"
    "mipmap-xxhdpi" = "icon-144x144.png"
    "mipmap-xxxhdpi" = "icon-192x192.png"
}

foreach ($mapping in $iconMappings.GetEnumerator()) {
    $destDir = "$resDir\$($mapping.Key)"
    $srcFile = "icons\$($mapping.Value)"
    
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    if (Test-Path $srcFile) {
        # Copy as ic_launcher.png (Android's default launcher icon name)
        Copy-Item $srcFile -Destination "$destDir\ic_launcher.png" -Force
        Copy-Item $srcFile -Destination "$destDir\ic_launcher_round.png" -Force
        Copy-Item $srcFile -Destination "$destDir\ic_launcher_foreground.png" -Force
        Write-Host "  Copied to $($mapping.Key)" -ForegroundColor Green
    }
}

Write-Host "`nAndroid icons setup complete!" -ForegroundColor Cyan

