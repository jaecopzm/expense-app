import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'auth_setup_screen.dart';
import 'auth_lock_screen.dart';

import '../../main.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize authentication state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground, check if should auto-lock
        authProvider.checkAutoLock();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App going to background, update activity time
        authProvider.updateActivity();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading screen while initializing
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show setup screen if authentication is not set up
        if (!authProvider.isSetupComplete) {
          return const AuthSetupScreen();
        }

        // Show lock screen if not authenticated
        if (!authProvider.isAuthenticated) {
          return const AuthLockScreen();
        }

        // Show main app if authenticated
        return const BottomNavWrapper();
      },
    );
  }
}
