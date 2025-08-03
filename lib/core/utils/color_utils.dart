import 'package:flutter/material.dart';

class ColorUtils {
  /// Parses a color string that can be in either #RRGGBB or 0xAARRGGBB format
  static Color parseColor(String colorStr) {
    if (colorStr.startsWith('#')) {
      // Handle #RRGGBB format
      final hex = colorStr.substring(1);
      return Color(int.parse('FF$hex', radix: 16));
    } else if (colorStr.startsWith('0x') || colorStr.startsWith('0X')) {
      // Handle 0xAARRGGBB format (legacy)
      return Color(int.parse(colorStr));
    } else {
      // Assume it's a raw hex number in AARRGGBB format
      return Color(int.parse(colorStr));
    }
  }
}