import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI and orientation
  _setSystemUI();

  // Initialize core services
  await _initializeServices();

  // Run the actual ZUBID app
  runApp(
    const ProviderScope(
      child: ZubidApp(),
    ),
  );
}

/// Initialize all core services before app starts
Future<void> _initializeServices() async {
  try {
    // Initialize storage service first
    await StorageService.init();
    AppLogger.info('Storage service initialized');

    // Initialize Firebase
    await Firebase.initializeApp();
    AppLogger.info('Firebase initialized');

    // Initialize push notifications
    await NotificationService.init();
    AppLogger.info('Notification service initialized');
  } catch (e) {
    // Log error but don't crash - app should still work without notifications
    AppLogger.error('Error initializing services', error: e);
  }
}

void _setSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
