import type { CapacitorConfig } from '@capacitor/cli';

// Set to true for development (connects to local backend)
// Set to false for production APK build
const isDevelopment = false;

// Your production backend URL (change this when you deploy)
const PRODUCTION_API_URL = 'https://your-backend-domain.com';

const config: CapacitorConfig = {
  appId: 'com.zubid.app',
  appName: 'ZUBID',
  webDir: 'www',
  bundledWebRuntime: false,

  // Server configuration - bundled for production
  server: isDevelopment ? {
    url: 'http://10.0.2.2:5000',
    cleartext: true
  } : {
    androidScheme: 'https',
    iosScheme: 'capacitor',
    hostname: 'zubid.app'
  },

  // Android-specific native configuration
  android: {
    buildOptions: {
      keystorePath: undefined,
      keystoreAlias: undefined
    },
    allowMixedContent: isDevelopment,
    useLegacyBridge: false,
    webContentsDebuggingEnabled: isDevelopment,
    // Native-like behavior
    backgroundColor: '#ffffff',
    overrideUserAgent: 'ZUBID-Android/1.0',
    appendUserAgent: 'ZUBID-Mobile',
    // Better scrolling
    initialFocus: true,
    // Hardware acceleration
    hardwareBackButton: true
  },

  // iOS-specific configuration
  ios: {
    contentInset: 'automatic',
    allowsLinkPreview: true,
    scheme: 'ZUBID',
    scrollEnabled: true,
    limitsNavigationsToAppBoundDomains: false,
    webContentsDebuggingEnabled: isDevelopment,
    backgroundColor: '#ffffff'
  },

  // Plugin configurations for native features
  plugins: {
    // Splash Screen - Premium orange theme
    SplashScreen: {
      launchShowDuration: 1500,
      launchAutoHide: true,
      backgroundColor: '#f97316',
      showSpinner: true,
      spinnerColor: '#ffffff',
      androidScaleType: 'CENTER_CROP',
      iosSpinnerStyle: 'large',
      launchFadeOutDuration: 500,
      splashFullScreen: true,
      splashImmersive: true,
      androidSplashResourceName: 'splash'
    },

    // Status Bar - Orange theme
    StatusBar: {
      style: 'LIGHT',
      backgroundColor: '#f97316',
      overlaysWebView: false
    },

    // Keyboard behavior
    Keyboard: {
      resize: 'body',
      resizeOnFullScreen: true,
      style: 'LIGHT'
    },

    // Haptics for native touch feedback
    Haptics: {
      selectionChanged: true
    },

    // Push Notifications
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert']
    },

    // Camera for auction photos
    Camera: {
      presentationStyle: 'fullscreen',
      saveToGallery: true
    },

    // App lifecycle
    App: {
      launchUrl: 'zubid://'
    }
  }
};

export default config;

