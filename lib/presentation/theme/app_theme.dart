import 'package:flutter/material.dart';

class AppTheme {
  static const Color ink = Color(0xFF181816);
  static const Color stone = Color(0xFFE8E2D8);
  static const Color mist = Color(0xFFF7F4EE);
  static const Color canvas = Color(0xFFF3EFE8);
  static const Color line = Color(0xFFD7D1C7);
  static const Color accent = Color(0xFF245C56);
  static const Color accentSoft = Color(0xFFDCE9E5);
  static const Color successSoft = Color(0xFFE3EEE8);
  static const Color danger = Color(0xFF9B4747);
  static const Color dangerSoft = Color(0xFFF5E7E4);

  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 28;

  static ThemeData light() {
    final TextTheme baseText = ThemeData.light(useMaterial3: true).textTheme;
    final TextTheme textTheme = baseText.copyWith(
      displaySmall: baseText.displaySmall?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.5,
        color: ink,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.5,
        color: ink.withValues(alpha: 0.82),
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontSize: 12,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w700,
        color: ink.withValues(alpha: 0.72),
      ),
    );

    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
          primary: accent,
          surface: mist,
        ).copyWith(
          surface: mist,
          onSurface: ink,
          primary: accent,
          onPrimary: Colors.white,
          secondary: accentSoft,
          onSecondary: ink,
          error: danger,
          onError: Colors.white,
          errorContainer: dangerSoft,
          onErrorContainer: danger,
          outline: line,
          outlineVariant: line.withValues(alpha: 0.7),
          surfaceContainerHighest: stone,
          surfaceContainerHigh: stone.withValues(alpha: 0.6),
          primaryContainer: successSoft,
          onPrimaryContainer: accent,
        );

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSm),
      borderSide: const BorderSide(color: line),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      dividerColor: line,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accentSoft,
        selectionHandleColor: accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: ink.withValues(alpha: 0.42),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: ink.withValues(alpha: 0.68),
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: accent, width: 1.2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: textTheme.titleMedium,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: Colors.white.withValues(alpha: 0.72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: Colors.white.withValues(alpha: 0.68),
        selectedColor: accentSoft,
        labelStyle: textTheme.bodyMedium!,
        secondaryLabelStyle: textTheme.bodyMedium!,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.68),
        shadowColor: Colors.black.withValues(alpha: 0.04),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: mist,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    );
  }

  static TextStyle codeText(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: ink,
      height: 1.45,
      fontFamilyFallback: const <String>[
        'Consolas',
        'Menlo',
        'Monaco',
        'Courier New',
      ],
    );
  }
}
