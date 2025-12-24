# Test frontend loading
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Testing frontend..." -ForegroundColor Green

# Test 1: Get home page
Write-Host "`n1. Testing home page..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://zubidauction.duckdns.org/" -UseBasicParsing
    Write-Host "✅ Home page: $($response.StatusCode)" -ForegroundColor Green
    
    # Check if key elements are present
    $content = $response.Content
    
    if ($content -match '<title>ZUBID') {
        Write-Host "✅ Title found" -ForegroundColor Green
    } else {
        Write-Host "❌ Title not found" -ForegroundColor Red
    }
    
    if ($content -match 'id="featuredCarousel"') {
        Write-Host "✅ Featured carousel element found" -ForegroundColor Green
    } else {
        Write-Host "❌ Featured carousel element not found" -ForegroundColor Red
    }
    
    if ($content -match 'src="config.production.js"') {
        Write-Host "✅ Config script found" -ForegroundColor Green
    } else {
        Write-Host "❌ Config script not found" -ForegroundColor Red
    }
    
    if ($content -match 'src="api.js"') {
        Write-Host "✅ API script found" -ForegroundColor Green
    } else {
        Write-Host "❌ API script not found" -ForegroundColor Red
    }
    
    if ($content -match 'src="app.js"') {
        Write-Host "✅ App script found" -ForegroundColor Green
    } else {
        Write-Host "❌ App script not found" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Home page failed: $_" -ForegroundColor Red
}

# Test 2: Get CSS
Write-Host "`n2. Testing CSS file..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://zubidauction.duckdns.org/styles.css" -UseBasicParsing
    Write-Host "✅ CSS file: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "CSS size: $($response.Content.Length) bytes" -ForegroundColor Green
} catch {
    Write-Host "❌ CSS file failed: $_" -ForegroundColor Red
}

# Test 3: Get app.js
Write-Host "`n3. Testing app.js..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://zubidauction.duckdns.org/app.js" -UseBasicParsing
    Write-Host "✅ app.js: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "app.js size: $($response.Content.Length) bytes" -ForegroundColor Green
} catch {
    Write-Host "❌ app.js failed: $_" -ForegroundColor Red
}

# Test 4: Get api.js
Write-Host "`n4. Testing api.js..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://zubidauction.duckdns.org/api.js" -UseBasicParsing
    Write-Host "✅ api.js: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "api.js size: $($response.Content.Length) bytes" -ForegroundColor Green
} catch {
    Write-Host "❌ api.js failed: $_" -ForegroundColor Red
}

Write-Host "`n✅ Frontend testing complete!" -ForegroundColor Green

