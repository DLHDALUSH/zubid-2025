import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/theme_config.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/utils/app_router.dart';
import 'core/utils/logger.dart';
import 'core/widgets/connectivity_banner.dart';
import 'l10n/app_localizations.dart';

class ZubidApp extends ConsumerStatefulWidget {
  const ZubidApp({super.key});

  @override
  ConsumerState<ZubidApp> createState() => _ZubidAppState();
}

class _ZubidAppState extends ConsumerState<ZubidApp>
    with WidgetsBindingObserver {
  bool _isInitialized = false;
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        AppLogger.info('App resumed');
        _checkConnectivity();
        break;
      case AppLifecycleState.paused:
        AppLogger.info('App paused');
        break;
      case AppLifecycleState.inactive:
        AppLogger.info('App inactive');
        break;
      case AppLifecycleState.detached:
        AppLogger.info('App detached');
        break;
      case AppLifecycleState.hidden:
        AppLogger.info('App hidden');
        break;
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize connectivity monitoring
      await _setupConnectivityMonitoring();

      setState(() {
        _isInitialized = true;
      });

      AppLogger.info('App initialization completed');
    } catch (error) {
      AppLogger.error('App initialization failed', error: error);
      // Continue with limited functionality
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _setupConnectivityMonitoring() async {
    try {
      _connectivityService.connectivityStream.listen((status) {
        AppLogger.info('Connectivity changed: $status');
      });
    } catch (e) {
      AppLogger.error('Failed to setup connectivity monitoring', error: e);
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final isConnected = await _connectivityService.isConnected();
      AppLogger.info(
          'Connectivity check: ${isConnected ? "connected" : "disconnected"}');
    } catch (e) {
      AppLogger.error('Failed to check connectivity', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing ZUBID...'),
              ],
            ),
          ),
        ),
      );
    }

    return ErrorBoundary(
      fallbackBuilder: (context, error, stackTrace) {
        return _buildErrorFallback(error, stackTrace);
      },
      child: _buildMainApp(),
    );
  }

  Widget _buildMainApp() {
    try {
      final router = ref.watch(appRouterProvider);
      final themeMode = ref.watch(themeModeProvider);

      return MaterialApp.router(
        title: 'ZUBID - Auction Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: _getAdaptiveThemeMode(themeMode),
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('ar', ''), // Arabic
          Locale('ku', ''), // Kurdish
        ],
        builder: (context, child) {
          return ConnectivityBanner(
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    } catch (error) {
      AppLogger.error('Error building main app', error: error);
      return _buildErrorFallback(error, null);
    }
  }

  ThemeMode _getAdaptiveThemeMode(ThemeMode userThemeMode) {
    if (userThemeMode != ThemeMode.system) {
      return userThemeMode;
    }

    // For system theme, we could add more sophisticated detection here
    // For now, just return system
    return ThemeMode.system;
  }

  Widget _buildErrorFallback(Object error, StackTrace? stackTrace) {
    return MaterialApp(
      title: 'ZUBID - Error',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ZUBID encountered an unexpected error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${error.toString()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isInitialized = false;
                    });
                    _initializeApp();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Global error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, Object, StackTrace?) fallbackBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.fallbackBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Catch Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error('Flutter Error',
          error: details.exception, stackTrace: details.stack);
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallbackBuilder(context, _error!, _stackTrace);
    }

    return widget.child;
  }
}
