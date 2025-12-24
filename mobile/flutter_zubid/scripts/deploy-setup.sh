#!/bin/bash

# ZUBID Flutter App - Deployment Setup Script
# This script sets up the environment for production deployment

set -e  # Exit on any error

echo "🔧 ZUBID Flutter App - Deployment Setup"
echo "========================================"

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

print_question() {
    echo -e "${YELLOW}[QUESTION]${NC} $1"
}

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

print_status "Setting up ZUBID Flutter app for production deployment..."

# Create necessary directories
print_status "Creating directory structure..."
mkdir -p android/app/src/main/res/xml
mkdir -p android/app/src/main/res/values
mkdir -p build/outputs
mkdir -p scripts
mkdir -p docs

# Check for keystore
KEYSTORE_FILE="android/key.properties"
if [ ! -f "$KEYSTORE_FILE" ]; then
    print_warning "Keystore configuration not found!"
    print_status "Setting up keystore configuration..."
    
    print_question "Do you want to generate a new keystore? (y/n)"
    read -r generate_keystore
    
    if [ "$generate_keystore" = "y" ] || [ "$generate_keystore" = "Y" ]; then
        print_status "Generating new keystore..."
        
        # Get keystore details
        print_question "Enter keystore password:"
        read -s keystore_password
        echo
        
        print_question "Enter key alias (default: zubid):"
        read key_alias
        key_alias=${key_alias:-zubid}
        
        print_question "Enter key password:"
        read -s key_password
        echo
        
        print_question "Enter your name:"
        read developer_name
        
        print_question "Enter your organization:"
        read organization
        
        print_question "Enter your city:"
        read city
        
        print_question "Enter your country code (e.g., IQ):"
        read country
        
        # Generate keystore
        KEYSTORE_PATH="android/zubid-release-key.jks"
        keytool -genkey -v -keystore "$KEYSTORE_PATH" \
            -keyalg RSA -keysize 2048 -validity 10000 \
            -alias "$key_alias" \
            -storepass "$keystore_password" \
            -keypass "$key_password" \
            -dname "CN=$developer_name, OU=$organization, L=$city, C=$country"
        
        # Create key.properties file
        cat > "$KEYSTORE_FILE" << EOF
storePassword=$keystore_password
keyPassword=$key_password
keyAlias=$key_alias
storeFile=zubid-release-key.jks
EOF
        
        print_success "Keystore generated and configured!"
        print_warning "⚠️  IMPORTANT: Keep your keystore file and passwords secure!"
        print_warning "⚠️  Back up your keystore file - you cannot recover it if lost!"
        
    else
        print_status "Copying keystore template..."
        cp android/key.properties.template "$KEYSTORE_FILE"
        print_warning "Please edit $KEYSTORE_FILE with your keystore information"
    fi
else
    print_success "Keystore configuration found"
fi

# Check Flutter installation
print_status "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    print_status "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

flutter --version

# Check Android SDK
print_status "Checking Android SDK..."
if [ -z "$ANDROID_HOME" ]; then
    print_warning "ANDROID_HOME environment variable not set"
    print_status "Please set ANDROID_HOME to your Android SDK path"
fi

# Install dependencies
print_status "Installing Flutter dependencies..."
flutter pub get

# Run code generation
print_status "Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Create .gitignore entries
GITIGNORE_FILE=".gitignore"
print_status "Updating .gitignore..."

# Add keystore and sensitive files to .gitignore
cat >> "$GITIGNORE_FILE" << 'EOF'

# ZUBID specific
android/key.properties
android/zubid-release-key.jks
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/core/config/secrets.dart
.env
.env.local
.env.production

# Build outputs
build/outputs/
*.apk
*.aab
*.ipa

# Sensitive files
keystore/
certificates/
secrets/
EOF

# Create environment configuration
print_status "Creating environment configuration..."
cat > "lib/core/config/secrets.dart.template" << 'EOF'
// Copy this file to secrets.dart and fill in your actual values
// DO NOT commit secrets.dart to version control

class Secrets {
  static const String firebaseApiKey = 'your_firebase_api_key';
  static const String firebaseAppId = 'your_firebase_app_id';
  static const String sentryDsn = 'your_sentry_dsn';
  static const String mixpanelToken = 'your_mixpanel_token';
  static const String amplitudeApiKey = 'your_amplitude_api_key';
  
  // Payment gateway keys
  static const String stripePublishableKey = 'your_stripe_publishable_key';
  static const String paypalClientId = 'your_paypal_client_id';
  
  // Social media app IDs
  static const String facebookAppId = 'your_facebook_app_id';
  static const String googleClientId = 'your_google_client_id';
  
  // API keys for external services
  static const String googleMapsApiKey = 'your_google_maps_api_key';
  static const String oneSignalAppId = 'your_onesignal_app_id';
}
EOF

# Make scripts executable
print_status "Making scripts executable..."
chmod +x scripts/*.sh

# Create documentation
print_status "Creating deployment documentation..."
cat > "docs/DEPLOYMENT.md" << 'EOF'
# ZUBID Flutter App Deployment Guide

## Prerequisites

1. Flutter SDK installed and configured
2. Android SDK with build tools
3. Keystore file for signing release builds
4. Access to Google Play Console (for Play Store deployment)

## Build Commands

### Development Build
```bash
flutter build apk --debug --flavor dev
```

### Staging Build
```bash
flutter build apk --profile --flavor staging
```

### Production Build
```bash
flutter build apk --release --flavor prod
flutter build appbundle --release --flavor prod
```

## Automated Build
```bash
./scripts/build-production.sh
```

## Environment Configuration

- **Development**: Connects to https://zubid-2025.onrender.com/api
- **Staging**: Connects to https://zubid-staging.onrender.com/api  
- **Production**: Connects to https://zubidauction.duckdns.org/api

## Deployment Checklist

- [ ] Update version number in pubspec.yaml
- [ ] Test all features in staging environment
- [ ] Verify API endpoints are accessible
- [ ] Test payment methods
- [ ] Check push notifications
- [ ] Verify SSL certificates
- [ ] Build and test APK/AAB files
- [ ] Upload to Play Store
- [ ] Submit for review

## Security Notes

- Keep keystore file secure and backed up
- Never commit sensitive keys to version control
- Use environment-specific configurations
- Enable ProGuard for release builds
- Implement certificate pinning for production
EOF

print_success "Deployment setup completed!"
print_status "Next steps:"
print_status "1. Review and update lib/core/config/secrets.dart.template"
print_status "2. Configure Firebase (if using)"
print_status "3. Set up Google Play Console"
print_status "4. Test the build process: ./scripts/build-production.sh"
print_status "5. Review docs/DEPLOYMENT.md for detailed instructions"

echo ""
print_warning "⚠️  Security reminders:"
print_warning "- Never commit keystore files or passwords"
print_warning "- Keep API keys and secrets secure"
print_warning "- Use different keys for different environments"
print_warning "- Regularly rotate sensitive credentials"

echo ""
print_success "🎉 Setup completed! Your Flutter app is ready for production deployment."
