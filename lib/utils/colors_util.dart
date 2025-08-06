import 'package:flutter/material.dart';

class ColorsUtil {

  static Color hexColor(String hexString, {double alpha = 1.0}) {
    String colorCode = hexString.substring(hexString.startsWith("#")?1:0);
    if (colorCode.length == 6) {
      int r = int.parse(colorCode.substring(0, 2), radix: 16);
      int g = int.parse(colorCode.substring(2, 4), radix: 16);
      int b = int.parse(colorCode.substring(4, 6), radix: 16);
      return Color.fromARGB((alpha * 255).toInt(), r, g, b);
    }
    throw ArgumentError('Invalid color format');
  }

 }
