import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/theme_config.dart';
import 'core/providers/theme_provider.dart';
import 'core/utils/app_router.dart';
import 'core/widgets/connectivity_banner.dart';
import 'l10n/app_localizations.dart';

class ZubidApp extends ConsumerWidget {
  const ZubidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final router = ref.watch(appRouterProvider);
      final themeMode = ref.watch(themeModeProvider);

      return MaterialApp.router(
        title: 'ZUBID - Auction Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: themeMode,
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
          return ConnectivityBanner(child: child ?? const SizedBox.shrink());
        },
      );
    } catch (error) {
      // Fallback UI if router or theme fails
      return MaterialApp(
        title: 'ZUBID - Auction Platform',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gavel, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'ZUBID',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Auction Platform'),
                const SizedBox(height: 16),
                Text('Loading error: $error'),
              ],
            ),
          ),
        ),
      );
    }
  }
}
