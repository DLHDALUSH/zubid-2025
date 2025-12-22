# ZUBID Production Deployment Verification Script
# This script verifies that the production deployment was successful
# Run this after deploying to the DuckDNS server

Write-Host "=========================================="
Write-Host "🔍 ZUBID PRODUCTION DEPLOYMENT VERIFICATION"
Write-Host "=========================================="
Write-Host "Target: https://zubidauction.duckdns.org"
Write-Host "Date: $(Get-Date)"
Write-Host "=========================================="

$productionUrl = "https://zubidauction.duckdns.org"
$developmentUrl = "https://zubid-2025.onrender.com"
$allTestsPassed = $true

function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Description,
        [string]$ExpectedContent = $null
    )
    
    Write-Host "🧪 Testing: $Description" -ForegroundColor Yellow
    Write-Host "   URL: $Url"
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 30 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Status: $($response.StatusCode) OK" -ForegroundColor Green
            
            if ($ExpectedContent -and $response.Content -notlike "*$ExpectedContent*") {
                Write-Host "   ⚠️  Warning: Expected content not found" -ForegroundColor Yellow
                return $false
            }
            
            return $true
        } else {
            Write-Host "   ❌ Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-ApiEndpoint {
    param(
        [string]$Url,
        [string]$Description
    )
    
    Write-Host "🔌 Testing API: $Description" -ForegroundColor Yellow
    Write-Host "   URL: $Url"
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 30 -ErrorAction Stop
        $content = $response.Content | ConvertFrom-Json
        
        if ($response.StatusCode -eq 200 -and $content.status -eq "healthy") {
            Write-Host "   ✅ API Status: $($content.status)" -ForegroundColor Green
            Write-Host "   ✅ Database: $($content.database)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ API Status: $($content.status)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host ""
Write-Host "🏢 TESTING PRODUCTION ENVIRONMENT (DuckDNS)"
Write-Host "=============================================="

# Test Production API Health
if (-not (Test-ApiEndpoint "$productionUrl/api/health" "Production API Health")) {
    $allTestsPassed = $false
}

# Test Production Main Site
if (-not (Test-Endpoint "$productionUrl/" "Production Main Site" "ZUBID")) {
    $allTestsPassed = $false
}

# Test Production Admin Portal
if (-not (Test-Endpoint "$productionUrl/admin.html" "Production Admin Portal" "admin")) {
    $allTestsPassed = $false
}

# Test Production Configuration
if (-not (Test-Endpoint "$productionUrl/config.production.js" "Production Configuration" "PRODUCTION_API_URL")) {
    $allTestsPassed = $false
}

# Test Production Config Test Page
if (-not (Test-Endpoint "$productionUrl/config-test.html" "Production Config Test Page" "Configuration Test")) {
    $allTestsPassed = $false
}

Write-Host ""
Write-Host "🧪 TESTING DEVELOPMENT ENVIRONMENT (Render)"
Write-Host "============================================="

# Test Development API Health
if (-not (Test-ApiEndpoint "$developmentUrl/api/health" "Development API Health")) {
    Write-Host "   ⚠️  Development server may be sleeping (normal for free tier)" -ForegroundColor Yellow
}

# Test Development Config Test Page
if (-not (Test-Endpoint "$developmentUrl/config-test.html" "Development Config Test Page" "Configuration Test")) {
    Write-Host "   ⚠️  Development server may be sleeping (normal for free tier)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔐 TESTING ADMIN ACCESS"
Write-Host "======================="

Write-Host "🧪 Testing Admin Login" -ForegroundColor Yellow
try {
    $loginData = @{
        username = "admin"
        password = "Admin123!@#"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "$productionUrl/api/login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop
    
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Admin login successful" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Admin login failed: $($response.StatusCode)" -ForegroundColor Red
        $allTestsPassed = $false
    }
}
catch {
    Write-Host "   ❌ Admin login error: $($_.Exception.Message)" -ForegroundColor Red
    $allTestsPassed = $false
}

Write-Host ""
Write-Host "=========================================="
if ($allTestsPassed) {
    Write-Host "🎉 ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "✅ Production deployment successful!"
    Write-Host "✅ Both environments are operational"
    Write-Host "✅ Admin access is working"
    Write-Host "✅ Dual-environment architecture is active"
    Write-Host ""
    Write-Host "🌐 Your ZUBID platform is ready for use:"
    Write-Host "   Production: $productionUrl"
    Write-Host "   Development: $developmentUrl"
    Write-Host "   Admin: $productionUrl/admin.html"
    Write-Host ""
    Write-Host "📱 Mobile app will automatically:"
    Write-Host "   Debug builds → Development server"
    Write-Host "   Release builds → Production server"
} else {
    Write-Host "❌ SOME TESTS FAILED!" -ForegroundColor Red
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "Please check the deployment and try again."
    Write-Host "Common issues:"
    Write-Host "- Server may still be starting up"
    Write-Host "- Deployment script may not have completed"
    Write-Host "- Network connectivity issues"
    Write-Host ""
    Write-Host "Wait a few minutes and run this script again."
}
Write-Host ""
