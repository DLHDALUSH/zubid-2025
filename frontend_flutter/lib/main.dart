import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/auction_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZubidApp());
}

class ZubidApp extends StatelessWidget {
  const ZubidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AuctionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ZUBID',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: themeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/home': (context) => const MainScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();

    // Failsafe: Force proceed to main screen after 12 seconds
    Timer(const Duration(seconds: 12), () {
      if (mounted && _isChecking) {
        print('[AUTH_WRAPPER] Failsafe timeout - forcing proceed to main screen');
        setState(() => _isChecking = false);
      }
    });
  }

  Future<void> _checkAuth() async {
    try {
      print('[AUTH_WRAPPER] Starting auth check...');
      // Add timeout to prevent infinite loading
      await context.read<AuthProvider>().checkAuth().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          print('[AUTH_WRAPPER] Auth check timed out after 8 seconds - continuing without auth');
        },
      );
      print('[AUTH_WRAPPER] Auth check completed');
    } catch (e) {
      print('[AUTH_WRAPPER] Auth check failed: $e - continuing without auth');
    } finally {
      if (mounted) {
        print('[AUTH_WRAPPER] Setting _isChecking = false');
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Always show main screen - user can browse without login
    return const MainScreen();
  }
}
