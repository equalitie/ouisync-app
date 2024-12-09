import 'package:flutter/material.dart';

abstract class AppTypography {
  /// Body
  static const bodyBig = TextStyle(
      color: Color(0xdd000000),
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);
  static const bodyMedium = TextStyle(
      color: Color(0xdd000000),
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);
  static const bodySmall = TextStyle(
      color: Color(0x8a000000),
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);
  static const bodyMicro = TextStyle(
      color: Color(0x8a000000),
      fontSize: 10.0,
      fontWeight: FontWeight.w400,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);

  /// Title
  static const titleBig = TextStyle(
      color: Color(0xdd000000),
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);
  static const titleMedium = TextStyle(
      color: Color(0xdd000000),
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);
  static const titleSmall = TextStyle(
      color: Color(0xdd000000),
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);

  /// Label
  static const labelBig = TextStyle(
      color: Color(0xdd000000),
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);

  static const labelMedium = TextStyle(
      color: Color(0xdd000000),
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);

  static const labelSmall = TextStyle(
      color: Color(0xdd000000),
      fontSize: 10.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none);
}

// TextTheme.bodyLarge: color: Color(0xdd000000), family: Roboto, size: 14.0, weight: 500, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.bodyMedium: color: Color(0xdd000000), family: Roboto, size: 14.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.bodySmall: color: Color(0x8a000000), family: Roboto, size: 12.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)

// TextTheme.titleLarge: color: Color(0xdd000000), family: Roboto, size: 20.0, weight: 500, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.titleMedium: color: Color(0xdd000000), family: Roboto, size: 16.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.titleSmall: color: Color(0xff000000), family: Roboto, size: 14.0, weight: 500, letterSpacing: 0.1, baseline: alphabetic, decoration: TextDecoration.none)

// TextTheme.labelLarge: color: Color(0xdd000000), family: Roboto, size: 14.0, weight: 500, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.labelMedium: color: Color(0xff000000), family: Roboto, size: 12.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.labelSmall: color: Color(0xff000000), family: Roboto, size: 10.0, weight: 400, letterSpacing: 1.5, baseline: alphabetic, decoration: TextDecoration.none)

// TextTheme.displayLarge: color: Color(0x8a000000), family: Roboto, size: 112.0, weight: 100, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.displayMedium: color: Color(0x8a000000), family: Roboto, size: 56.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.displaySmall: color: Color(0x8a000000), family: Roboto, size: 45.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)

// TextTheme.headlineLarge: color: Color(0x8a000000), family: Roboto, size: 40.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.headlineMedium: color: Color(0x8a000000), family: Roboto, size: 34.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)
// TextTheme.headlineSmall: color: Color(0xdd000000), family: Roboto, size: 24.0, weight: 400, baseline: alphabetic, decoration: TextDecoration.none)
