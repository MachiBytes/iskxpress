import 'package:flutter/material.dart';
import 'package:iskxpress/core/constants/colors.dart';

final ThemeData kAppTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: TColors.primary,
    primary: TColors.primary,
    surface: TColors.background,
    error: TColors.error,
    onPrimary: TColors.textWhite,
    onSurface: TColors.textPrimary,
    onError: TColors.error,
    outline: TColors.borderDark
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: TColors.buttonSecondary,
      textStyle: TextStyle(
        color: TColors.textPrimary
      ),
      foregroundColor: TColors.textPrimary,
    )
  ),
  textTheme: TextTheme().copyWith(
    labelSmall: TextStyle(
      fontSize: 12,
      color: TColors.textWhite
    ),
    labelMedium: TextStyle(
      fontSize: 16,
      color: TColors.textWhite
    ),
    labelLarge: TextStyle(
      fontSize: 20,
      color: TColors.textPrimary
    ),
    bodyLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: TColors.textPrimary
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: TColors.textPrimary
    ),
    titleMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: TColors.textPrimary
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: TColors.textPrimary,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  shadowColor: TColors.shadow,
  dividerColor: TColors.borderDark
);