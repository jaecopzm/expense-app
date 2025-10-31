import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeEnhanced {
  // Enhanced spacing system
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 48.0;
  static const double space3xl = 64.0;

  // Enhanced border radius system
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radiusFull = 999.0;

  // Enhanced elevation system
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Enhanced color palette
  static const Color primaryLight = Color(0xFF6366F1); // Indigo-500
  static const Color primaryDark = Color(0xFF8B5CF6); // Violet-500
  static const Color secondaryLight = Color(0xFF10B981); // Emerald-500
  static const Color secondaryDark = Color(0xFF34D399); // Emerald-400

  // Success/Error/Warning colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Enhanced category colors with better accessibility
  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFEF4444), // Red-500
    'Transport': Color(0xFF06B6D4), // Cyan-500
    'Shopping': Color(0xFFF59E0B), // Amber-500
    'Entertainment': Color(0xFFEC4899), // Pink-500
    'Bills': Color(0xFF8B5CF6), // Violet-500
    'Health': Color(0xFF10B981), // Emerald-500
    'Education': Color(0xFF3B82F6), // Blue-500
    'Other': Color(0xFF6B7280), // Gray-500
  };

  // Enhanced shadows
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 25,
      offset: const Offset(0, 10),
    ),
  ];

  // Enhanced gradients
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1), // Indigo-500
      Color(0xFF8B5CF6), // Violet-500
    ],
  );

  static LinearGradient successGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Emerald-500
      Color(0xFF059669), // Emerald-600
    ],
  );

  static LinearGradient warningGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B), // Amber-500
      Color(0xFFD97706), // Amber-600
    ],
  );

  static LinearGradient errorGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444), // Red-500
      Color(0xFFDC2626), // Red-600
    ],
  );

  // Enhanced button styles
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: elevationNone,
      padding: const EdgeInsets.symmetric(
        horizontal: spaceLg,
        vertical: spaceMd,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: primaryLight,
      side: const BorderSide(color: primaryLight, width: 1.5),
      padding: const EdgeInsets.symmetric(
        horizontal: spaceLg,
        vertical: spaceMd,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  static ButtonStyle ghostButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: primaryLight,
      padding: const EdgeInsets.symmetric(
        horizontal: spaceLg,
        vertical: spaceMd,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  // Enhanced input decoration
  static InputDecorationTheme inputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? neutral800 : neutral50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: BorderSide(
          color: isDark ? neutral700 : neutral200,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceMd,
        vertical: spaceMd,
      ),
      hintStyle: GoogleFonts.inter(
        color: isDark ? neutral400 : neutral500,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // Enhanced card theme
  static CardTheme cardTheme(bool isDark) {
    return CardTheme(
      elevation: elevationNone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
      color: isDark ? neutral800 : Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.1),
    );
  }

  // Enhanced app bar theme
  static AppBarTheme appBarTheme(bool isDark) {
    return AppBarTheme(
      elevation: elevationNone,
      centerTitle: false,
      backgroundColor: isDark ? neutral900 : Colors.white,
      foregroundColor: isDark ? Colors.white : neutral900,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : neutral900,
      ),
      iconTheme: IconThemeData(color: isDark ? Colors.white : neutral900),
    );
  }

  // Utility methods
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? categoryColors['Other']!;
  }

  static LinearGradient getCategoryGradient(String category) {
    final color = getCategoryColor(category);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withValues(alpha: 0.8)],
    );
  }
}
