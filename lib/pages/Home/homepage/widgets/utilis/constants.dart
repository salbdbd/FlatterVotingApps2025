import 'package:flutter/material.dart';

/// Constants used throughout the application
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 800);
  static const Duration slideAnimationDuration = Duration(milliseconds: 1000);
  static const Duration fastAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 1200);

  // Colors
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color secondaryPurple = Color(0xFFA29BFE);
  static const Color darkBlue = Color(0xFF0A0E1A);
  static const Color lightDark = Color(0xFF1A1F2E);
  static const Color cardBackground = Color(0xFF2D3748);
  static const Color cardBackgroundSecondary = Color(0xFF1A202C);
  static const Color successGreen = Color(0xFF00D2FF);
  static const Color errorRed = Color(0xFFFF6B6B);

  // Additional colors for accounts section
  static const Color accentBlue = Color(0xFF74B9FF);
  static const Color warningYellow = Color(0xFFFFD93D);
  static const Color infoGray = Color(0xFF636E72);
  static const Color backgroundGradientStart = Color(0xFF2D3748);
  static const Color backgroundGradientEnd = Color(0xFF1A202C);

  // Text colors
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFB2B2B2);
  static const Color mutedTextColor = Color(0xFF666666);
  static const Color linkTextColor = Color(0xFF74B9FF);

  // Spacing and dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 20.0;

  static const double defaultElevation = 4.0;
  static const double smallElevation = 2.0;
  static const double largeElevation = 8.0;

  // Font sizes
  static const double titleFontSize = 24.0;
  static const double subtitleFontSize = 18.0;
  static const double bodyFontSize = 14.0;
  static const double captionFontSize = 12.0;
  static const double smallFontSize = 10.0;

  // Icon sizes
  static const double defaultIconSize = 24.0;
  static const double smallIconSize = 18.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;

  // API timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortApiTimeout = Duration(seconds: 15);
  static const Duration longApiTimeout = Duration(seconds: 60);

  // Currency settings
  static const String defaultCurrency = '৳';
  static const int defaultDecimalPlaces = 2;
  static const int compactDecimalPlaces = 0;

  // Table settings
  static const double tableHeaderHeight = 56.0;
  static const double tableRowHeight = 48.0;
  static const double tableRowPadding = 12.0;

  // Account-specific constants
  static const int maxLedgerEntriesPerPage = 50;
  static const int refreshThresholdMinutes = 5;

  // Error messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String timeoutErrorMessage =
      'Request timeout. Please try again.';
  static const String noDataErrorMessage = 'No data available at the moment.';

  // Success messages
  static const String dataLoadedSuccessMessage = 'Data loaded successfully';
  static const String refreshSuccessMessage = 'Data refreshed successfully';

  // Loading messages
  static const String loadingAccountsMessage = 'Loading account data...';
  static const String refreshingDataMessage = 'Refreshing data...';
  static const String processingRequestMessage = 'Processing request...';
}

/// Gradient definitions for reuse
class AppGradients {
  AppGradients._();

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppConstants.primaryPurple, AppConstants.secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [AppConstants.darkBlue, AppConstants.lightDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      AppConstants.cardBackground,
      AppConstants.cardBackgroundSecondary,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient successGradient = LinearGradient(
    colors: [
      AppConstants.successGreen,
      AppConstants.successGreen.withOpacity(0.7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient errorGradient = LinearGradient(
    colors: [
      AppConstants.errorRed,
      AppConstants.errorRed.withOpacity(0.7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Shadow definitions for consistent elevation
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get defaultShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get largeShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> coloredShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
}

/// Border definitions for consistent styling
class AppBorders {
  AppBorders._();

  static Border get defaultBorder => Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      );

  static Border get primaryBorder => Border.all(
        color: AppConstants.primaryPurple.withOpacity(0.3),
        width: 1.5,
      );

  static Border get successBorder => Border.all(
        color: AppConstants.successGreen.withOpacity(0.3),
        width: 1,
      );

  static Border get errorBorder => Border.all(
        color: AppConstants.errorRed.withOpacity(0.3),
        width: 1,
      );

  static BorderSide get tableBorder => BorderSide(
        color: Colors.white.withOpacity(0.1),
        width: 0.5,
      );
}

/// Text style definitions for consistency
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: AppConstants.titleFontSize,
    fontWeight: FontWeight.bold,
    color: AppConstants.primaryTextColor,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: AppConstants.subtitleFontSize,
    fontWeight: FontWeight.w600,
    color: AppConstants.primaryTextColor,
    letterSpacing: 0.3,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: AppConstants.bodyFontSize,
    fontWeight: FontWeight.normal,
    color: AppConstants.primaryTextColor,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppConstants.captionFontSize,
    fontWeight: FontWeight.w400,
    color: AppConstants.secondaryTextColor,
  );

  static const TextStyle button = TextStyle(
    fontSize: AppConstants.bodyFontSize,
    fontWeight: FontWeight.w600,
    color: AppConstants.primaryTextColor,
    letterSpacing: 0.5,
  );

  static TextStyle amount(Color color) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 0.3,
      );

  static const TextStyle tableHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppConstants.primaryTextColor,
    letterSpacing: 0.5,
  );

  static const TextStyle tableCell = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppConstants.primaryTextColor,
    letterSpacing: 0.2,
  );
}
