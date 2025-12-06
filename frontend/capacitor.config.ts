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
  server: isDevelopment ? {
    // Development: connects to local backend
    // 10.0.2.2 is Android emulator's localhost
    // Use your computer's IP for real device testing
    url: 'http://10.0.2.2:5000',
    cleartext: true
  } : {
    // Production: load from bundled files
    androidScheme: 'https',
    iosScheme: 'capacitor',
    hostname: 'zubid.app'
  },
  android: {
    buildOptions: {
      keystorePath: undefined,
      keystoreAlias: undefined
    },
    allowMixedContent: isDevelopment,
    useLegacyBridge: false,
    webContentsDebuggingEnabled: isDevelopment
  },
  ios: {
    contentInset: 'automatic',
    allowsLinkPreview: true,
    scheme: 'ZUBID',
    scrollEnabled: true,
    limitsNavigationsToAppBoundDomains: false,
    webContentsDebuggingEnabled: isDevelopment
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      launchAutoHide: true,
      backgroundColor: '#ff6600',
      showSpinner: true,
      spinnerColor: '#ffffff',
      androidScaleType: 'CENTER_CROP',
      iosSpinnerStyle: 'large',
      launchFadeOutDuration: 300,
      splashFullScreen: true,
      splashImmersive: true
    },
    StatusBar: {
      style: 'LIGHT',
      backgroundColor: '#ff6600',
      overlaysWebView: false
    },
    Keyboard: {
      resize: 'body',
      resizeOnFullScreen: true
    },
    PushNotifications: {
      presentationOptions: ['badge', 'sound', 'alert']
    }
  }
};

export default config;

