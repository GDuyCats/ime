import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// Visual style of IME: black and white with square corners and bold
/// type, borrowed from the Chuvachi website. Colour is used only to show
/// the state of money (overdue, due today, profit).
abstract final class AppTheme {
  static const String bodyFont = 'BeVietnamPro';
  static const String displayFont = 'Anton';

  /// Wide windows (desktop, tablet in landscape) get top tabs and
  /// side-by-side sections instead of the phone layout.
  static const double wideBreakpoint = 840;

  /// Content never stretches wider than this on big screens.
  static const double maxContentWidth = 1100;

  static ThemeData light() => _build(_Palette.light);
  static ThemeData dark() => _build(_Palette.dark);

  static ThemeData _build(_Palette p) {
    const square = RoundedRectangleBorder();
    final thickBorder = BorderSide(color: p.ink, width: 1.5);
    final boldLabel = TextStyle(
      fontFamily: bodyFont,
      fontWeight: FontWeight.w700,
      fontSize: 15,
    );

    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.ink,
      onPrimary: p.paper,
      secondary: p.ink,
      onSecondary: p.paper,
      error: p.overdue,
      onError: p.paper,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.muted,
      outline: p.ink,
      outlineVariant: p.line,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surface,
      surfaceContainerHighest: p.tint,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      fontFamily: bodyFont,
      scaffoldBackgroundColor: p.page,
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      extensions: [
        StatusColors(
          overdue: p.overdue,
          dueToday: p.dueToday,
          positive: p.positive,
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: displayFont,
          fontSize: 22,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.ink,
          foregroundColor: p.paper,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: square,
          textStyle: boldLabel,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: square,
          side: thickBorder,
          textStyle: boldLabel,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(48, 48),
          shape: square,
          textStyle: boldLabel,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.ink,
        foregroundColor: p.paper,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: square,
        extendedTextStyle: boldLabel,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: thickBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: thickBorder,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.ink, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.overdue, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.overdue, width: 2.5),
        ),
        labelStyle: TextStyle(color: p.muted),
        floatingLabelStyle: TextStyle(color: p.ink, fontWeight: FontWeight.w600),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(side: thickBorder),
        textStyle: TextStyle(
          fontFamily: bodyFont,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: p.ink,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(side: thickBorder),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        height: 68,
        indicatorColor: p.ink,
        indicatorShape: square,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.paper : p.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: bodyFont,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected) ? p.ink : p.muted,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(iconColor: p.ink),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.ink),
      textSelectionTheme: TextSelectionThemeData(cursorColor: p.ink),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.paper, fontFamily: bodyFont),
        shape: square,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Big condensed headings ("THÁNG 11/2026"). Vietnamese accents need the
/// extra line height or they touch the line above.
TextStyle displayStyle(BuildContext context, {double size = 28}) {
  return TextStyle(
    fontFamily: AppTheme.displayFont,
    fontSize: size,
    height: 1.22,
    letterSpacing: 0.4,
    color: Theme.of(context).colorScheme.onSurface,
  );
}

/// Digits of equal width so amounts line up in columns.
const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

/// Colours that carry a meaning about money. Everything else stays
/// black and white.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.overdue,
    required this.dueToday,
    required this.positive,
  });

  /// Overdue amounts and losses.
  final Color overdue;

  /// Amounts due today.
  final Color dueToday;

  /// Profit and fully paid amounts.
  final Color positive;

  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>()!;

  @override
  StatusColors copyWith({Color? overdue, Color? dueToday, Color? positive}) {
    return StatusColors(
      overdue: overdue ?? this.overdue,
      dueToday: dueToday ?? this.dueToday,
      positive: positive ?? this.positive,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      overdue: Color.lerp(overdue, other.overdue, t)!,
      dueToday: Color.lerp(dueToday, other.dueToday, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
    );
  }
}

/// Raw colours for one brightness. Light values match the Chuvachi site.
class _Palette {
  const _Palette({
    required this.brightness,
    required this.ink,
    required this.paper,
    required this.muted,
    required this.line,
    required this.tint,
    required this.page,
    required this.surface,
    required this.overdue,
    required this.dueToday,
    required this.positive,
  });

  final Brightness brightness;

  /// Main text, borders and filled buttons.
  final Color ink;

  /// Text on top of [ink].
  final Color paper;
  final Color muted;
  final Color line;

  /// Faint fill behind bars and progress tracks.
  final Color tint;
  final Color page;
  final Color surface;
  final Color overdue;
  final Color dueToday;
  final Color positive;

  static const light = _Palette(
    brightness: Brightness.light,
    ink: Color(0xFF111111),
    paper: Color(0xFFFFFFFF),
    muted: Color(0xFF555555),
    line: Color(0xFFE5E5E5),
    tint: Color(0xFFF2F2F2),
    page: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    overdue: Color(0xFFA32D2D),
    dueToday: Color(0xFF854F0B),
    positive: Color(0xFF3B6D11),
  );

  static const dark = _Palette(
    brightness: Brightness.dark,
    ink: Color(0xFFF2F2F2),
    paper: Color(0xFF111111),
    muted: Color(0xFFA8A8A8),
    line: Color(0xFF2E2E2E),
    tint: Color(0xFF242424),
    page: Color(0xFF0B0B0B),
    surface: Color(0xFF161616),
    overdue: Color(0xFFF09595),
    dueToday: Color(0xFFFAC775),
    positive: Color(0xFF97C459),
  );
}
