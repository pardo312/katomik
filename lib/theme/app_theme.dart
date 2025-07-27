import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class AppTheme {
  static ThemeData getLightTheme(Color primaryColor) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: Platform.isIOS,
        elevation: 0,
        scrolledUnderElevation: Platform.isIOS ? 0 : 3,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: Platform.isIOS ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Platform.isIOS ? 16 : 24,
            vertical: Platform.isIOS ? 12 : 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: Platform.isIOS ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 28 : 16),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 14 : 28),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Platform.isIOS ? 10 : 20),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: Platform.isIOS ? 56 : 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      dividerTheme: DividerThemeData(
        space: Platform.isIOS ? 1 : 16,
        thickness: Platform.isIOS ? 0.5 : 1,
      ),
    );
  }
  
  static ThemeData getDarkTheme(Color primaryColor) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: Platform.isIOS,
        elevation: 0,
        scrolledUnderElevation: Platform.isIOS ? 0 : 3,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: Platform.isIOS ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Platform.isIOS ? 16 : 24,
            vertical: Platform.isIOS ? 12 : 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: Platform.isIOS ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 10 : 12),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 28 : 16),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 14 : 28),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Platform.isIOS ? 8 : 12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Platform.isIOS ? 10 : 20),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: Platform.isIOS ? 56 : 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      dividerTheme: DividerThemeData(
        space: Platform.isIOS ? 1 : 16,
        thickness: Platform.isIOS ? 0.5 : 1,
      ),
    );
  }
  
  static CupertinoThemeData getCupertinoTheme(Color primaryColor, bool isDark) {
    return CupertinoThemeData(
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: primaryColor,
        darkColor: primaryColor,
      ),
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
      ),
    );
  }
}