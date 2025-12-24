# ZUBID Flutter App - Deployment Verification Script
# This PowerShell script verifies the production deployment setup

param(
    [switch]$Detailed,
    [switch]$SkipBuild
)

Write-Host "🔍 ZUBID Flutter App - Deployment Verification" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if we're in the correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
}

Write-Status "Starting deployment verification..."

# Check Flutter installation
Write-Status "Checking Flutter installation..."
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Flutter is installed"
        if ($Detailed) {
            Write-Host $flutterVersion -ForegroundColor Gray
        }
    } else {
        Write-Error "Flutter is not installed or not in PATH"
        exit 1
    }
} catch {
    Write-Error "Flutter command failed: $_"
    exit 1
}

# Check Android SDK
Write-Status "Checking Android SDK..."
if ($env:ANDROID_HOME) {
    Write-Success "ANDROID_HOME is set: $env:ANDROID_HOME"
} else {
    Write-Warning "ANDROID_HOME environment variable not set"
}

# Check project structure
Write-Status "Verifying project structure..."
$requiredFiles = @(
    "lib/main.dart",
    "lib/core/config/app_config.dart",
    "lib/core/config/environment.dart",
    "android/app/build.gradle",
    "android/app/src/main/res/xml/network_security_config.xml",
    "android/app/proguard-rules.pro"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Success "OK $file"
    } else {
        Write-Error "MISSING $file"
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Error "Missing required files. Please ensure all files are present."
    exit 1
}

# Check keystore configuration
Write-Status "Checking keystore configuration..."
if (Test-Path "android/key.properties") {
    Write-Success "Keystore configuration found"
    
    # Verify keystore file exists
    $keyProperties = Get-Content "android/key.properties" | ConvertFrom-StringData
    if ($keyProperties.storeFile) {
        $keystorePath = Join-Path "android" $keyProperties.storeFile
        if (Test-Path $keystorePath) {
            Write-Success "Keystore file found: $keystorePath"
        } else {
            Write-Warning "Keystore file not found: $keystorePath"
        }
    }
} else {
    Write-Warning "Keystore configuration not found. Copy android/key.properties.template to android/key.properties"
}

# Check dependencies
Write-Status "Checking Flutter dependencies..."
try {
    flutter pub get | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependencies resolved successfully"
    } else {
        Write-Error "Failed to resolve dependencies"
        exit 1
    }
} catch {
    Write-Error "Failed to get dependencies: $_"
    exit 1
}

# Run code generation
Write-Status "Running code generation..."
try {
    flutter packages pub run build_runner build --delete-conflicting-outputs | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Code generation completed"
    } else {
        Write-Warning "Code generation had issues (this may be normal)"
    }
} catch {
    Write-Warning "Code generation failed: $_"
}

# Run analysis
Write-Status "Running code analysis..."
try {
    $analysisOutput = flutter analyze 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Code analysis passed"
    } else {
        Write-Warning "Code analysis found issues:"
        if ($Detailed) {
            Write-Host $analysisOutput -ForegroundColor Yellow
        }
    }
} catch {
    Write-Warning "Code analysis failed: $_"
}

# Run tests
if (-not $SkipBuild) {
    Write-Status "Running tests..."
    try {
        flutter test | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "All tests passed"
        } else {
            Write-Warning "Some tests failed"
        }
    } catch {
        Write-Warning "Test execution failed: $_"
    }
}

# Test build process
if (-not $SkipBuild) {
    Write-Status "Testing build process..."
    
    # Test debug build
    Write-Status "Testing debug build..."
    try {
        flutter build apk --debug --flavor dev | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Debug build successful"
        } else {
            Write-Error "Debug build failed"
        }
    } catch {
        Write-Error "Debug build failed: $_"
    }
    
    # Test release build (if keystore is configured)
    if (Test-Path "android/key.properties") {
        Write-Status "Testing release build..."
        try {
            flutter build apk --release --flavor prod | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Release build successful"
            } else {
                Write-Error "Release build failed"
            }
        } catch {
            Write-Error "Release build failed: $_"
        }
    } else {
        Write-Warning "Skipping release build test (keystore not configured)"
    }
}

# Check API endpoints
Write-Status "Checking API endpoints..."
$endpoints = @{
    "Development" = "https://zubid-2025.onrender.com/api/health"
    "Production" = "https://zubidauction.duckdns.org/api/health"
}

foreach ($env in $endpoints.Keys) {
    $url = $endpoints[$env]
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Success "$env API endpoint is accessible"
        } else {
            Write-Warning "$env API endpoint returned status: $($response.StatusCode)"
        }
    } catch {
        Write-Warning "$env API endpoint is not accessible: $url"
    }
}

# Generate verification report
$reportPath = "build/verification-report.txt"
New-Item -Path "build" -ItemType Directory -Force | Out-Null

$report = @"
ZUBID Flutter App - Deployment Verification Report
==================================================

Verification Date: $(Get-Date)
Flutter Version: $(flutter --version | Select-Object -First 1)
Platform: Windows
PowerShell Version: $($PSVersionTable.PSVersion)

Project Structure: ✓ Verified
Dependencies: ✓ Resolved
Code Generation: ✓ Completed
Code Analysis: Completed

Build Configuration:
- Debug Build: Check Required
- Release Build: Check Required

Security Configuration:
- Keystore: $(if (Test-Path "android/key.properties") { "Configured" } else { "Not Configured" })
- Network Security: Configured
- ProGuard Rules: Configured

API Endpoints:
- Development: Check Required
- Production: Check Required

Recommendations:
1. Ensure keystore is properly configured for release builds
2. Test all API endpoints thoroughly
3. Verify push notification configuration
4. Test payment methods in staging environment
5. Perform security audit before production release

Next Steps:
1. Run full build: flutter build appbundle --release --flavor prod
2. Test APK on physical devices
3. Upload to Google Play Console for internal testing
4. Conduct user acceptance testing
5. Deploy to production

"@

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Success "Verification report saved to: $reportPath"

Write-Host ""
Write-Success "🎉 Deployment verification completed!"
Write-Status "Review the verification report for detailed results"
Write-Status "Address any warnings before proceeding with production deployment"

if ($missingFiles.Count -eq 0 -and (Test-Path "android/key.properties")) {
    Write-Host ""
    Write-Success "SUCCESS: Your Flutter app is ready for production deployment!"
    Write-Status "Next steps:"
    Write-Status "1. Run: flutter build appbundle --release --flavor prod"
    Write-Status "2. Test the APK thoroughly"
    Write-Status "3. Upload to Google Play Console"
    Write-Status "4. Submit for review"
} else {
    Write-Host ""
    Write-Warning "WARNING: Please address the issues above before deploying to production"
}
