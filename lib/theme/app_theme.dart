import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color greenPrimary = Color(0xFF1DB954); // verde vibrante
  static const Color greenDark = Color(0xFF0D5C35);
  static const Color greenGlow = Color(0xFF12664F);
  static const Color white = Colors.white;

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: darkBg,
    fontFamily: 'Poppins', // adicione no pubspec.yaml
    colorScheme: const ColorScheme.dark(primary: greenPrimary, surface: darkBg),
  );
}
