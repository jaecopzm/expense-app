import 'package:flutter/material.dart';

/// WizeBudge branding constants and utilities
class WizeBudgeBranding {
  // App Information
  static const String appName = 'WizeBudge';
  static const String appTagline = 'Smart Financial Management';
  static const String appDescription =
      'Track your spending with style and gain insights into your financial habits with intelligent budgeting';
  static const String version = '2.0.0';
  static const String versionName = 'Enhanced Edition';

  // Logo Assets (when available)
  static const String logoPath = 'assets/images/logo.png';
  static const String logoWhitePath = 'assets/images/logo_white.png';
  static const String iconPath = 'assets/images/icon.png';

  // App Colors (matching theme)
  static const Color primaryColor = Color(0xFF6366F1); // Indigo-500
  static const Color secondaryColor = Color(0xFF10B981); // Emerald-500

  /// Returns the app logo widget with fallback to icon
  static Widget getLogo({
    double size = 24,
    Color? color,
    bool useWhiteVersion = false,
  }) {
    // TODO: Uncomment when logo files are available
    // try {
    //   return Image.asset(
    //     useWhiteVersion ? logoWhitePath : logoPath,
    //     width: size,
    //     height: size,
    //     color: color,
    //   );
    // } catch (e) {
    //   // Fallback to icon if logo not found
    //   return Icon(
    //     Icons.account_balance_wallet,
    //     size: size,
    //     color: color ?? (useWhiteVersion ? Colors.white : primaryColor),
    //   );
    // }

    // Current fallback implementation
    return Icon(
      Icons.account_balance_wallet,
      size: size,
      color: color ?? (useWhiteVersion ? Colors.white : primaryColor),
    );
  }

  /// Returns the app icon widget
  static Widget getAppIcon({double size = 32}) {
    // TODO: Uncomment when icon file is available
    // try {
    //   return Image.asset(
    //     iconPath,
    //     width: size,
    //     height: size,
    //   );
    // } catch (e) {
    //   return Icon(
    //     Icons.account_balance_wallet,
    //     size: size,
    //     color: primaryColor,
    //   );
    // }

    // Current fallback implementation
    return Icon(Icons.account_balance_wallet, size: size, color: primaryColor);
  }

  /// Returns formatted app title with emoji
  static String getAppTitle({bool includeEmoji = true}) {
    return includeEmoji ? '$appName 💰' : appName;
  }

  /// Returns app version string
  static String getVersionString() {
    return 'Version $version - $versionName';
  }

  /// Returns welcome message
  static String getWelcomeMessage() {
    return 'Welcome to $appName! 👋';
  }
}
