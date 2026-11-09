import 'package:flutter/material.dart';

/// 앱 전체에서 쓰는 색상.
abstract final class AppColors {
  static const background = Color.fromARGB(255, 244, 244, 235);
  static const primary = Color.fromARGB(255, 252, 160, 0);
  static const text = Colors.brown;
  static const panelBorder = Color.fromARGB(255, 178, 155, 146);
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      foregroundColor: AppColors.text,
      backgroundColor: AppColors.primary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.primary),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
  );
}
