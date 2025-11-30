import type { CapacitorConfig } from '@capacitor/cli';

// Set to true for development (connects to local backend)
// Set to false for production APK build
const isDevelopment = true;

// Your production backend URL (change this when you deploy)
const PRODUCTION_API_URL = 'https://your-backend-domain.com';

const config: CapacitorConfig = {
  appId: 'com.zubid.app',
  appName: 'ZUBID',
  webDir: 'www',
  server: isDevelopment ? {
    // Development: connects to local backend
    // 10.0.2.2 is Android emulator's localhost
    // Use your computer's IP for real device testing
    url: 'http://10.0.2.2:5000',
    cleartext: true
  } : {
    // Production: load from bundled files
    androidScheme: 'https'
  },
  android: {
    buildOptions: {
      keystorePath: undefined,
      keystoreAlias: undefined
    },
    allowMixedContent: isDevelopment
  },
  ios: {
    contentInset: 'automatic',
    allowsLinkPreview: true,
    scheme: 'ZUBID'
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      launchAutoHide: true,
      backgroundColor: '#ff6600',
      showSpinner: true,
      spinnerColor: '#ffffff',
      androidScaleType: 'CENTER_CROP'
    },
    StatusBar: {
      style: 'LIGHT',
      backgroundColor: '#ff6600'
    }
  }
};

export default config;

