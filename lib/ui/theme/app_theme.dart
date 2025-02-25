import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_login_example/ui/theme/app_spacing.dart';

abstract final class AppTheme {
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.blueM3,
    tooltipsMatchBackground: true,
    extensions: [const AppSpacing()],
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      textButtonRadius: 4.0,
      filledButtonRadius: 4.0,
      elevatedButtonRadius: 4.0,
      outlinedButtonRadius: 4.0,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorBorderWidth: 0.5,
      inputDecoratorFocusedBorderWidth: 0.5,
      fabUseShape: true,
      fabAlwaysCircular: true,
      alignedDropdown: true,
      searchBarRadius: 5.0,
      searchViewRadius: 5.0,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.blueM3,
    tooltipsMatchBackground: true,
    extensions: [const AppSpacing()],
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      textButtonRadius: 4.0,
      filledButtonRadius: 4.0,
      elevatedButtonRadius: 4.0,
      outlinedButtonRadius: 4.0,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorBorderWidth: 0.5,
      inputDecoratorFocusedBorderWidth: 0.5,
      fabUseShape: true,
      fabAlwaysCircular: true,
      alignedDropdown: true,
      searchBarRadius: 5.0,
      searchViewRadius: 5.0,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
