import 'package:chat_app/Theme/Theme.dart';
import 'package:chat_app/config/ColorTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  ThemeData themeData;
  ThemeState(this.themeData);
}

class Themecubit extends Cubit<ThemeState> {
  Color _primaryColor = const Color.fromRGBO(32, 160, 144, 1.0);
  Themecubit()
      : super(ThemeState(getTheme(
            const Color.fromRGBO(32, 160, 144, 1.0), Brightness.light)));
  Color get primaryColor => _primaryColor;
  ThemeData? _theme;
  ThemeData? get theme => _theme;

  Future<void> changePrimaryColor(Color color, Brightness brightness) async {
    final prefs = await SharedPreferences.getInstance();
    final String ColorValue = Colortheme.colorToRGBA(color);
    await prefs.setString('mainColor', ColorValue);
    emit(ThemeState(getTheme(color, brightness)));
  }

  Future<void> changeTheme(bool isLightMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme',!isLightMode ? 'lightMode': 'darkMode');
    isLightMode
        ? emit(ThemeState(getTheme(_primaryColor, Brightness.dark)))
        : emit(ThemeState(getTheme(_primaryColor, Brightness.light)));
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString('theme') ?? 'lightMode';
    final colorValue =
        prefs.getString('mainColor') ?? Colortheme.colorToRGBA(_primaryColor);
    _primaryColor = Colortheme.rgbaToColor(colorValue);
    if (themeValue == 'lightMode') {
      _theme = getTheme(_primaryColor, Brightness.light);
      emit(ThemeState(getTheme(_primaryColor, Brightness.light)));
    } else {
      _theme = getTheme(_primaryColor, Brightness.dark);
      emit(ThemeState(getTheme(_primaryColor, Brightness.dark)));
    }
  }
}
