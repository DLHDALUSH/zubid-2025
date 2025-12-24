#!/bin/bash

# ZUBID Flutter App - Production Build Script
# This script builds the Flutter app for production deployment

set -e  # Exit on any error

echo "🚀 ZUBID Flutter App - Production Build"
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

print_status "Checking Flutter installation..."
flutter --version

print_status "Getting Flutter dependencies..."
flutter pub get

print_status "Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

print_status "Analyzing code..."
flutter analyze

print_status "Running tests..."
flutter test

print_status "Cleaning previous builds..."
flutter clean
flutter pub get

# Build for different environments
print_status "Building APK for development environment..."
flutter build apk --debug --flavor dev --target lib/main.dart

print_status "Building APK for staging environment..."
flutter build apk --profile --flavor staging --target lib/main.dart

print_status "Building APK for production environment..."
flutter build apk --release --flavor prod --target lib/main.dart

# Build App Bundle for Play Store
print_status "Building App Bundle for Play Store..."
flutter build appbundle --release --flavor prod --target lib/main.dart

# Create output directory
OUTPUT_DIR="build/outputs"
mkdir -p "$OUTPUT_DIR"

# Copy built files to output directory
print_status "Copying build artifacts..."
cp build/app/outputs/flutter-apk/app-dev-debug.apk "$OUTPUT_DIR/zubid-dev-debug.apk" 2>/dev/null || print_warning "Dev debug APK not found"
cp build/app/outputs/flutter-apk/app-staging-profile.apk "$OUTPUT_DIR/zubid-staging-profile.apk" 2>/dev/null || print_warning "Staging profile APK not found"
cp build/app/outputs/flutter-apk/app-prod-release.apk "$OUTPUT_DIR/zubid-production-release.apk" 2>/dev/null || print_warning "Production release APK not found"
cp build/app/outputs/bundle/prodRelease/app-prod-release.aab "$OUTPUT_DIR/zubid-production-release.aab" 2>/dev/null || print_warning "Production App Bundle not found"

# Generate build info
BUILD_INFO_FILE="$OUTPUT_DIR/build-info.txt"
print_status "Generating build information..."
cat > "$BUILD_INFO_FILE" << EOF
ZUBID Flutter App - Build Information
=====================================

Build Date: $(date)
Flutter Version: $(flutter --version | head -n 1)
Dart Version: $(dart --version)
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "Not available")
Git Branch: $(git branch --show-current 2>/dev/null || echo "Not available")

Build Artifacts:
- Development APK: zubid-dev-debug.apk
- Staging APK: zubid-staging-profile.apk  
- Production APK: zubid-production-release.apk
- Production App Bundle: zubid-production-release.aab

Environment Configurations:
- Development: https://zubid-2025.onrender.com/api
- Staging: https://zubid-staging.onrender.com/api
- Production: https://zubidauction.duckdns.org/api

Installation Instructions:
1. For testing: Install the appropriate APK file
2. For Play Store: Upload the App Bundle (.aab file)
3. Make sure to test each environment before deployment

Security Notes:
- Production builds are signed with release keystore
- Network security config restricts cleartext traffic
- ProGuard obfuscation is enabled for release builds
- Debug tools are disabled in production builds
EOF

print_success "Build completed successfully!"
print_status "Build artifacts are available in: $OUTPUT_DIR"
print_status "Build information saved to: $BUILD_INFO_FILE"

# Display file sizes
print_status "Build artifact sizes:"
ls -lh "$OUTPUT_DIR"/*.apk "$OUTPUT_DIR"/*.aab 2>/dev/null || print_warning "Some build artifacts may be missing"

echo ""
print_success "🎉 Production build completed!"
print_status "Next steps:"
print_status "1. Test the APK files on different devices"
print_status "2. Upload the App Bundle to Google Play Console"
print_status "3. Configure Play Store listing and screenshots"
print_status "4. Submit for review"

echo ""
print_warning "⚠️  Important reminders:"
print_warning "- Test all payment methods in production"
print_warning "- Verify API endpoints are accessible"
print_warning "- Check push notification configuration"
print_warning "- Ensure proper SSL certificates are in place"
