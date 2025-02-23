import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromRGBO(32, 160, 144, 1.0),
    secondary: Colors.white,
    surface: Color.fromRGBO(0, 14, 8, 1.0),
    onSurface: Color.fromRGBO(121, 124, 123, 1.0),
      primaryContainer: Color.fromRGBO(243, 246, 246, 1.0),
      secondaryContainer: Color.fromRGBO(222, 236, 248, 1),
    error: Color.fromRGBO(255, 45, 27, 1.0),
  ),
  scaffoldBackgroundColor: Colors.white,
  progressIndicatorTheme:const ProgressIndicatorThemeData(
    color: Colors.black
  )
);