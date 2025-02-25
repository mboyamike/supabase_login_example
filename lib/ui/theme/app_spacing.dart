import 'package:flutter/material.dart';

class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.zero = 0,
    this.xxxs = 2,
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 40,
    this.xxxl = 48,
    this.layout = 64,
    this.layoutLg = 80,
    this.layoutXl = 128,
  });

  final double zero;
  final double xxxs;
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double layout;
  final double layoutLg;
  final double layoutXl;

  @override
  AppSpacing copyWith({
    double? zero,
    double? xxxs,
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? layout,
    double? layoutLg,
    double? layoutXl,
  }) {
    return AppSpacing(
      zero: zero ?? this.zero,
      xxxs: xxxs ?? this.xxxs,
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      layout: layout ?? this.layout,
      layoutLg: layoutLg ?? this.layoutLg,
      layoutXl: layoutXl ?? this.layoutXl,
    );
  }

  @override
  ThemeExtension<AppSpacing> lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) {
      return this;
    }
    return const AppSpacing();
  }
}

extension SpacingX on BuildContext {
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
}
