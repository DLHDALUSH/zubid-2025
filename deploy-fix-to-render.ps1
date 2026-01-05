# PowerShell script to deploy the fix to Render
# Run this script to commit and push the backend fix

Write-Host "🔧 ZUBID - Deploy Backend Fix to Render" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: Not in a git repository!" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory." -ForegroundColor Yellow
    exit 1
}

# Show current status
Write-Host "📊 Current Git Status:" -ForegroundColor Yellow
git status --short
Write-Host ""

# Check if there are changes to commit
$changes = git status --porcelain
if (-not $changes) {
    Write-Host "✅ No changes to commit. Everything is up to date!" -ForegroundColor Green
    exit 0
}

# Show what will be committed
Write-Host "📝 Files to be committed:" -ForegroundColor Yellow
git diff --name-only
Write-Host ""

# Ask for confirmation
Write-Host "🤔 Do you want to commit and push these changes? (Y/N)" -ForegroundColor Cyan
$confirmation = Read-Host
if ($confirmation -ne "Y" -and $confirmation -ne "y") {
    Write-Host "❌ Deployment cancelled." -ForegroundColor Red
    exit 0
}

# Add all changes
Write-Host ""
Write-Host "📦 Adding changes..." -ForegroundColor Yellow
git add .

# Commit with a descriptive message
Write-Host "💾 Committing changes..." -ForegroundColor Yellow
$commitMessage = "Fix: Backend deployment issues - Move Flask g import to top, add API versioning"
git commit -m $commitMessage

# Check if commit was successful
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Commit failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Changes committed successfully!" -ForegroundColor Green
Write-Host ""

# Push to remote
Write-Host "🚀 Pushing to remote repository..." -ForegroundColor Yellow
git push origin main

# Check if push was successful
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Push failed!" -ForegroundColor Red
    Write-Host "You may need to pull changes first: git pull origin main" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "✅ Successfully pushed to remote!" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 Deployment initiated!" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Go to https://dashboard.render.com" -ForegroundColor White
Write-Host "2. Select your 'zubid-backend' service" -ForegroundColor White
Write-Host "3. Watch the deployment logs" -ForegroundColor White
Write-Host "4. Wait for 'Deploy live' status" -ForegroundColor White
Write-Host ""
Write-Host "🧪 Test your deployment:" -ForegroundColor Yellow
Write-Host "curl https://zubid-2025.onrender.com/api/health" -ForegroundColor White
Write-Host "curl https://zubid-2025.onrender.com/api/v1/health" -ForegroundColor White
Write-Host ""
Write-Host "📖 For troubleshooting, see: RENDER_TROUBLESHOOTING_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "✨ Done! Your backend should be deploying now." -ForegroundColor Green

