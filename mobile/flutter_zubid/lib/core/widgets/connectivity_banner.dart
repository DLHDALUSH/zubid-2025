import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/connectivity_service.dart';

class ConnectivityBanner extends ConsumerWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    return connectivityAsync.when(
      data: (status) =>
          _buildBannerWithStatus(_mapConnectivityStatus(status), ref),
      loading: () => child,
      error: (error, stack) => child,
    );
  }

  Widget _buildBannerWithStatus(ConnectivityResult status, WidgetRef ref) {
    return Column(
      children: [
        if (status == ConnectivityResult.none)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.red.shade600,
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'No internet connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Trigger a connectivity check
                    ref.invalidate(connectivityStatusProvider);
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (status == ConnectivityResult.none)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange.shade600,
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Checking connection...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }

  ConnectivityResult _mapConnectivityStatus(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return ConnectivityResult.wifi; // Default to wifi when connected
      case ConnectivityStatus.disconnected:
        return ConnectivityResult.none;
      case ConnectivityStatus.checking:
        return ConnectivityResult.none; // Will show checking banner
    }
  }
}
