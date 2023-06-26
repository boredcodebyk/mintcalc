import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  bool _isSystemColor = false;
  ThemeMode _themeMode = ThemeMode.system;
  int _sigFig = 7;
  int _customColor = 16777215;
  bool _firstLaunch = true;

  bool get isSystemColor => _isSystemColor;
  set isSystemColor(bool value) {
    if (_isSystemColor == value) return;
    _isSystemColor = value;
    notifyListeners();
    save();
  }

  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    save();
  }

  int get sigFig => _sigFig;
  set sigFig(int value) {
    if (_sigFig == value) return;
    _sigFig = value;
    notifyListeners();
    save();
  }

  int get customColor => _customColor;
  set customColor(int value) {
    if (_customColor == value) return;
    _customColor = value;
    notifyListeners();
    save();
  }

  bool get firstLaunch => _firstLaunch;
  set firstLaunch(bool value) {
    if (_firstLaunch == value) return;
    _firstLaunch = value;
    notifyListeners();
    save();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSystemColor', _isSystemColor);
    prefs.setString('themeMode', _themeMode.toString());
    prefs.setInt('sigFig', _sigFig);
    prefs.setInt('customColor', _customColor);
    prefs.setBool('firstLaunch', _firstLaunch);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isSystemColor = prefs.getBool('isSystemColor') ?? false;
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == prefs.getString('themeMode'),
      orElse: () => ThemeMode.system,
    );
    _sigFig = prefs.getInt('sigFig') ?? 7;
    _customColor = prefs.getInt('customColor') ?? 16777215;
    _firstLaunch = prefs.getBool('firstLaunch') ?? true;
    notifyListeners();
  }
}
