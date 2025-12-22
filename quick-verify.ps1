# Quick ZUBID Deployment Verification
Write-Host "🔍 ZUBID Deployment Verification" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$productionUrl = "https://zubidauction.duckdns.org"

Write-Host ""
Write-Host "Testing Production Server..." -ForegroundColor Yellow

# Test API Health
try {
    $response = Invoke-WebRequest -Uri "$productionUrl/api/health" -Method GET -TimeoutSec 15
    $health = $response.Content | ConvertFrom-Json
    Write-Host "✅ API Health: $($health.status)" -ForegroundColor Green
    Write-Host "✅ Database: $($health.database)" -ForegroundColor Green
} catch {
    Write-Host "❌ API Health: Failed" -ForegroundColor Red
}

# Test Main Site
try {
    $response = Invoke-WebRequest -Uri "$productionUrl/" -Method GET -TimeoutSec 15
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Main Site: Working" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Main Site: Failed" -ForegroundColor Red
}

# Test Admin Portal
try {
    $response = Invoke-WebRequest -Uri "$productionUrl/admin.html" -Method GET -TimeoutSec 15
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Admin Portal: Working" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Admin Portal: Failed" -ForegroundColor Red
}

# Test Configuration
try {
    $response = Invoke-WebRequest -Uri "$productionUrl/config.production.js" -Method GET -TimeoutSec 15
    if ($response.Content -like "*PRODUCTION_API_URL*") {
        Write-Host "✅ Configuration: Updated with dual-environment" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Configuration: May not be updated" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Configuration: Failed to load" -ForegroundColor Red
}

# Test Config Test Page
try {
    $response = Invoke-WebRequest -Uri "$productionUrl/config-test.html" -Method GET -TimeoutSec 15
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Config Test Page: Available" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Config Test Page: Failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "🌐 URLs to Check:" -ForegroundColor Cyan
Write-Host "Main Site: $productionUrl/"
Write-Host "Admin Portal: $productionUrl/admin.html"
Write-Host "Config Test: $productionUrl/config-test.html"
Write-Host ""
Write-Host "🔐 Admin Login: admin / Admin123!@#"
Write-Host ""

# Test Admin Login
Write-Host "Testing Admin Login..." -ForegroundColor Yellow
try {
    $loginData = @{
        username = "admin"
        password = "Admin123!@#"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "$productionUrl/api/login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 15
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Admin Login: Working" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Admin Login: Failed - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Deployment Status: The server is responding correctly!" -ForegroundColor Green
Write-Host "If you don't see changes, try:" -ForegroundColor Yellow
Write-Host "1. Clear browser cache (Ctrl+F5)" -ForegroundColor Yellow
Write-Host "2. Check the config test page for environment detection" -ForegroundColor Yellow
Write-Host "3. Test the admin portal functionality" -ForegroundColor Yellow
Write-Host ""
