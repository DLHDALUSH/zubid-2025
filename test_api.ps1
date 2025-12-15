# Test API endpoints
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Testing API endpoints..." -ForegroundColor Green

# Test 1: Health check
Write-Host "`n1. Testing /api/health..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://zubidauction.duckdns.org/api/health" -UseBasicParsing
    Write-Host "✅ Health check: $($response.StatusCode)" -ForegroundColor Green
    Write-Host $response.Content | ConvertFrom-Json | ConvertTo-Json
} catch {
    Write-Host "❌ Health check failed: $_" -ForegroundColor Red
}

# Test 2: Featured auctions
Write-Host "`n2. Testing /api/featured..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://zubidauction.duckdns.org/api/featured" -UseBasicParsing
    Write-Host "✅ Featured auctions: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Found $($data.Count) featured auctions" -ForegroundColor Green
    if ($data.Count -gt 0) {
        Write-Host "First auction: $($data[0].item_name)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Featured auctions failed: $_" -ForegroundColor Red
}

# Test 3: Categories
Write-Host "`n3. Testing /api/categories..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://zubidauction.duckdns.org/api/categories" -UseBasicParsing
    Write-Host "✅ Categories: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Found $($data.Count) categories" -ForegroundColor Green
} catch {
    Write-Host "❌ Categories failed: $_" -ForegroundColor Red
}

# Test 4: All auctions
Write-Host "`n4. Testing /api/auctions..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://zubidauction.duckdns.org/api/auctions?per_page=5" -UseBasicParsing
    Write-Host "✅ Auctions: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Found $($data.auctions.Count) auctions" -ForegroundColor Green
} catch {
    Write-Host "❌ Auctions failed: $_" -ForegroundColor Red
}

Write-Host "`n✅ API testing complete!" -ForegroundColor Green

