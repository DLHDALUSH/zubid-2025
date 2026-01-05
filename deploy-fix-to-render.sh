#!/bin/bash
# Bash script to deploy the fix to Render
# Run this script to commit and push the backend fix

echo "🔧 ZUBID - Deploy Backend Fix to Render"
echo "========================================"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository!"
    echo "Please run this script from the project root directory."
    exit 1
fi

# Show current status
echo "📊 Current Git Status:"
git status --short
echo ""

# Check if there are changes to commit
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ No changes to commit. Everything is up to date!"
    exit 0
fi

# Show what will be committed
echo "📝 Files to be committed:"
git diff --name-only
echo ""

# Ask for confirmation
echo "🤔 Do you want to commit and push these changes? (y/n)"
read -r confirmation
if [ "$confirmation" != "y" ] && [ "$confirmation" != "Y" ]; then
    echo "❌ Deployment cancelled."
    exit 0
fi

# Add all changes
echo ""
echo "📦 Adding changes..."
git add .

# Commit with a descriptive message
echo "💾 Committing changes..."
commit_message="Fix: Backend deployment issues - Move Flask g import to top, add API versioning"
git commit -m "$commit_message"

# Check if commit was successful
if [ $? -ne 0 ]; then
    echo "❌ Commit failed!"
    exit 1
fi

echo "✅ Changes committed successfully!"
echo ""

# Push to remote
echo "🚀 Pushing to remote repository..."
git push origin main

# Check if push was successful
if [ $? -ne 0 ]; then
    echo "❌ Push failed!"
    echo "You may need to pull changes first: git pull origin main"
    exit 1
fi

echo ""
echo "✅ Successfully pushed to remote!"
echo ""
echo "🎉 Deployment initiated!"
echo ""
echo "📋 Next Steps:"
echo "1. Go to https://dashboard.render.com"
echo "2. Select your 'zubid-backend' service"
echo "3. Watch the deployment logs"
echo "4. Wait for 'Deploy live' status"
echo ""
echo "🧪 Test your deployment:"
echo "curl https://zubid-2025.onrender.com/api/health"
echo "curl https://zubid-2025.onrender.com/api/v1/health"
echo ""
echo "📖 For troubleshooting, see: RENDER_TROUBLESHOOTING_GUIDE.md"
echo ""
echo "✨ Done! Your backend should be deploying now."

