// lib/theme/design_tokens.dart
//
// Identidad visual de Lumio -- azul noche + azul sofisticado + lavanda
// sobre superficies claras, calma y premium, con fuente nativa del
// sistema (SF Pro en iPhone, Roboto en Android), igual criterio que
// Repara/Convive/VecindApp/Vence: debe sentirse de app, no de web.
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

class LumioColors extends ThemeExtension<LumioColors> {
  const LumioColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceSunken,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.brand,
    required this.brandStrong,
    required this.brandOn,
    required this.brandTint,
    required this.lavanda,
    required this.accentCyan,
    required this.success,
    required this.warning,
    required this.warningText,
    required this.error,
    required this.errorText,
    required this.overlay,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceSunken;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint; // NUNCA para texto que haya que leer
  final Color brand;
  final Color brandStrong;
  final Color brandOn;
  final Color brandTint;
  final Color lavanda; // acento decorativo, nunca semántico
  final Color accentCyan; // acento decorativo (categorías), nunca semántico
  final Color success;
  final Color warning; // SOLO icono o fondo tenue -- como texto usa warningText
  final Color warningText;
  final Color error; // SOLO icono, borde o fondo tenue -- como texto usa errorText
  final Color errorText;
  final Color overlay;

  static const light = LumioColors(
    background: Color(0xFFF7F3EC),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEFE8D8),
    surfaceSunken: Color(0xFFE2D9C4),
    ink: Color(0xFF16302C),
    inkMuted: Color(0xFF5C6E69),
    inkFaint: Color(0xFF8FA19C),
    brand: Color(0xFF0F8679),
    brandStrong: Color(0xFF0B655B),
    brandOn: Color(0xFFFFFFFF),
    brandTint: Color(0x260F8679),
    lavanda: Color(0xFF7FAE9E),
    accentCyan: Color(0xFF3E98B8),
    success: Color(0xFF3C9456),
    warning: Color(0xFFD99A3E),
    warningText: Color(0xFF7A5220),
    error: Color(0xFFC75C52),
    errorText: Color(0xFF9C3E36),
    overlay: Color(0x26142420),
  );

  static const dark = LumioColors(
    background: Color(0xFF0D1917),
    surface: Color(0xFF15221F),
    surfaceMuted: Color(0xFF1C2B27),
    surfaceSunken: Color(0xFF24362F),
    ink: Color(0xFFE9F2EE),
    inkMuted: Color(0xFF9FB3AC),
    inkFaint: Color(0xFF6C7F78),
    brand: Color(0xFF4BC2B2),
    brandStrong: Color(0xFF6ED4C6),
    brandOn: Color(0xFF08201C),
    brandTint: Color(0x334BC2B2),
    lavanda: Color(0xFFA7D2C3),
    accentCyan: Color(0xFF72C8E3),
    success: Color(0xFF5FC27D),
    warning: Color(0xFFEFB95E),
    warningText: Color(0xFFF3CB8E),
    error: Color(0xFFDE8B82),
    errorText: Color(0xFFF0ACA4),
    overlay: Color(0x59000000),
  );

  @override
  LumioColors copyWith({
    Color? background, Color? surface, Color? surfaceMuted, Color? surfaceSunken,
    Color? ink, Color? inkMuted, Color? inkFaint,
    Color? brand, Color? brandStrong, Color? brandOn, Color? brandTint,
    Color? lavanda, Color? accentCyan, Color? success, Color? warning, Color? warningText,
    Color? error, Color? errorText, Color? overlay,
  }) {
    return LumioColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      brand: brand ?? this.brand,
      brandStrong: brandStrong ?? this.brandStrong,
      brandOn: brandOn ?? this.brandOn,
      brandTint: brandTint ?? this.brandTint,
      lavanda: lavanda ?? this.lavanda,
      accentCyan: accentCyan ?? this.accentCyan,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      warningText: warningText ?? this.warningText,
      error: error ?? this.error,
      errorText: errorText ?? this.errorText,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  LumioColors lerp(ThemeExtension<LumioColors>? other, double t) {
    if (other is! LumioColors) return this;
    return t < 0.5 ? this : other;
  }
}

class LumioRadius {
  LumioRadius._();
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 28;
  static const double pill = 999;
}

class LumioSpace {
  LumioSpace._();
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
}

extension LumioThemeContextX on BuildContext {
  LumioColors get colors => Theme.of(this).extension<LumioColors>()!;
}

class LumioText {
  LumioText._();

  static String get fontFamily => defaultTargetPlatform == TargetPlatform.iOS ? '.SF Pro Text' : 'Roboto';

  static TextTheme uiTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final palette = brightness == Brightness.dark ? LumioColors.dark : LumioColors.light;
    final sistema = base.apply(
      fontFamily: fontFamily,
      bodyColor: palette.ink,
      displayColor: palette.ink,
    );
    TextStyle display(double size, double height) => TextStyle(
          fontFamily: fontFamily,
          color: palette.ink,
          fontSize: size,
          height: height / size,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        );
    return sistema.copyWith(
      displayMedium: display(28, 34),
      displaySmall: display(22, 28),
      headlineSmall: display(18, 24),
      labelSmall: sistema.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
      bodyLarge: sistema.bodyLarge?.copyWith(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400),
      titleMedium: sistema.titleMedium?.copyWith(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600),
      bodySmall: sistema.bodySmall?.copyWith(fontSize: 12.5, height: 17 / 12.5, fontWeight: FontWeight.w500, color: palette.inkMuted),
      labelLarge: sistema.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );
  }
}

ThemeData _buildLumioTheme(Brightness brightness) {
  final palette = brightness == Brightness.dark ? LumioColors.dark : LumioColors.light;
  final textTheme = LumioText.uiTextTheme(brightness);
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: palette.background,
    textTheme: textTheme,
    extensions: [palette],
    colorScheme: ColorScheme(
      brightness: brightness,
      surface: palette.surface,
      onSurface: palette.ink,
      primary: palette.brand,
      onPrimary: palette.brandOn,
      secondary: palette.lavanda,
      onSecondary: palette.ink,
      tertiary: palette.success,
      onTertiary: Colors.white,
      error: palette.error,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: LumioText.fontFamily,
        color: palette.ink,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 1,
      shadowColor: palette.ink.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LumioRadius.md),
        side: BorderSide(color: palette.ink.withValues(alpha: 0.05)),
      ),
    ),
    dividerColor: palette.inkMuted.withValues(alpha: 0.15),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surfaceMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LumioRadius.sm),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: palette.inkMuted.withValues(alpha: 0.8)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.brand,
        foregroundColor: palette.brandOn,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LumioRadius.sm)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.brand,
        side: BorderSide(color: palette.brand.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LumioRadius.sm)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: palette.brand,
      side: BorderSide(color: palette.ink.withValues(alpha: 0.12)),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: palette.ink, fontSize: 13, fontWeight: FontWeight.w500),
      secondaryLabelStyle: TextStyle(color: palette.brandOn, fontSize: 13, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: palette.surface,
      selectedItemColor: palette.brand,
      unselectedItemColor: palette.inkFaint,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.ink,
      contentTextStyle: TextStyle(color: palette.background),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

ThemeData buildLumioLightTheme() => _buildLumioTheme(Brightness.light);
ThemeData buildLumioDarkTheme() => _buildLumioTheme(Brightness.dark);
