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
        authProvider.checkAutoLock();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        authProvider.updateActivity();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isSetupComplete) {
          return const AuthSetupScreen();
        }

        if (!authProvider.isAuthenticated) {
          return const AuthLockScreen();
        }

        return const BottomNavWrapper();
      },
    );
  }
}
