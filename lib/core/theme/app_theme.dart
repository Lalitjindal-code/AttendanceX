import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_radius.dart';
import 'app_color_scheme.dart';
import 'app_text_theme.dart';

/// Material 3 [ThemeData] definitions for Attendify — Meridian design language.
///
/// Provides [light], [dark], and [amoled] theme getters.
/// All three themes share the same component styling logic; only the
/// [ColorScheme] differs between them.
abstract final class AppTheme {
  AppTheme._();

  // ── Theme Getters ─────────────────────────────────────────────────────────────

  /// Light theme.
  static ThemeData get light => _build(AppColorScheme.light, Brightness.light);

  /// Dark theme.
  static ThemeData get dark => _build(AppColorScheme.dark, Brightness.dark);

  /// AMOLED / true-black dark theme.
  /// Uses [AppColorScheme.amoled] which has a pure #000000 surface.
  static ThemeData get amoled => _build(AppColorScheme.amoled, Brightness.dark);

  // ── Builder ───────────────────────────────────────────────────────────────────

  static ThemeData _build(ColorScheme scheme, Brightness brightness) {
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
    );
    return base.copyWith(
      textTheme: AppTextTheme.build(base.textTheme),
      appBarTheme: _appBar(scheme, brightness),
      cardTheme: _card(scheme),
      filledButtonTheme: _filledButton(scheme),
      outlinedButtonTheme: _outlinedButton(scheme),
      textButtonTheme: _textButton(scheme),
      elevatedButtonTheme: _elevatedButton(scheme),
      inputDecorationTheme: _inputDecoration(scheme),
      navigationBarTheme: _navigationBar(scheme),
      chipTheme: _chip(scheme),
      snackBarTheme: _snackBar(scheme),
      dialogTheme: _dialog(scheme),
      bottomSheetTheme: _bottomSheet(scheme),
      floatingActionButtonTheme: _fab(scheme),
      dividerTheme: _divider(scheme),
      listTileTheme: _listTile(scheme),
      switchTheme: _switch(scheme),
      progressIndicatorTheme: _progressIndicator(scheme),
      badgeTheme: _badge(scheme),
      tooltipTheme: _tooltip(scheme),
      tabBarTheme: _tabBar(scheme),
    );
  }

  // ── Component Themes ──────────────────────────────────────────────────────────

  static AppBarTheme _appBar(ColorScheme scheme, Brightness brightness) {
    return AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: scheme.shadow.withAlpha(30),
      centerTitle: false,
      titleSpacing: 20,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        fontFamily: 'PlusJakartaSans',
      ),
      systemOverlayStyle: brightness == Brightness.light
          ? SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: scheme.surface,
              systemNavigationBarIconBrightness: Brightness.dark,
            )
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: scheme.surface,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
    );
  }

  static CardThemeData _card(ColorScheme scheme) {
    return CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    );
  }

  static FilledButtonThemeData _filledButton(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButton(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        side: BorderSide(color: scheme.outline, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButton(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButton(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecoration(ColorScheme scheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: scheme.outlineVariant, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return scheme.primary;
        return scheme.onSurfaceVariant;
      }),
      labelStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return TextStyle(
            color: scheme.primary,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        );
      }),
    );
  }

  static NavigationBarThemeData _navigationBar(ColorScheme scheme) {
    return NavigationBarThemeData(
      // The nav bar background blends with the surface
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      // Meridian: pill-shaped selected indicator (wider, tighter height)
      indicatorColor: scheme.primaryContainer,
      indicatorShape: const StadiumBorder(),
      elevation: 0,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: scheme.onPrimaryContainer,
            size: 22,
          );
        }
        return IconThemeData(
          color: scheme.onSurfaceVariant,
          size: 22,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: scheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          );
        }
        return TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        );
      }),
    );
  }

  static ChipThemeData _chip(ColorScheme scheme) {
    return ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primaryContainer,
      checkmarkColor: scheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: TextStyle(
        color: scheme.onPrimaryContainer,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: scheme.outlineVariant),
      // Meridian: fully rounded pill chips
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  static SnackBarThemeData _snackBar(ColorScheme scheme) {
    return SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(
        color: scheme.onInverseSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor: scheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static DialogThemeData _dialog(ColorScheme scheme) {
    return DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      contentTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }

  static BottomSheetThemeData _bottomSheet(ColorScheme scheme) {
    return BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalBackgroundColor: scheme.surfaceContainerHigh,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.bottomSheet),
          topRight: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      dragHandleColor: scheme.onSurfaceVariant.withAlpha(76),
      dragHandleSize: const Size(32, 4),
      showDragHandle: true,
    );
  }

  static FloatingActionButtonThemeData _fab(ColorScheme scheme) {
    return FloatingActionButtonThemeData(
      // Meridian: primary-colored FAB, pill shape
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: const StadiumBorder(),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      extendedTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }

  static DividerThemeData _divider(ColorScheme scheme) {
    return DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }

  static ListTileThemeData _listTile(ColorScheme scheme) {
    return ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 13,
        height: 1.4,
      ),
      minLeadingWidth: 24,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }

  static SwitchThemeData _switch(ColorScheme scheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.onPrimary;
        return scheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary;
        }
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.transparent;
        return scheme.outline;
      }),
    );
  }

  static ProgressIndicatorThemeData _progressIndicator(ColorScheme scheme) {
    return ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      circularTrackColor: scheme.surfaceContainerHighest,
      linearMinHeight: 6,
      borderRadius: BorderRadius.circular(AppRadius.circular),
    );
  }

  static BadgeThemeData _badge(ColorScheme scheme) {
    return BadgeThemeData(
      backgroundColor: scheme.error,
      textColor: scheme.onError,
      smallSize: 6,
      largeSize: 16,
      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    );
  }

  static TooltipThemeData _tooltip(ColorScheme scheme) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: TextStyle(
        color: scheme.onInverseSurface,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      preferBelow: true,
    );
  }

  static TabBarThemeData _tabBar(ColorScheme scheme) {
    return TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: scheme.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      dividerColor: scheme.outlineVariant,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return scheme.primary.withAlpha(20);
        }
        if (states.contains(WidgetState.hovered)) {
          return scheme.primary.withAlpha(10);
        }
        return Colors.transparent;
      }),
    );
  }
}
