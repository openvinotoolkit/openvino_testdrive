
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

enum NavigationIndicators { sticky, end }

class AppTheme extends ChangeNotifier {
  AccentColor? _color;
  AccentColor get color => _color ?? systemAccentColor;
  set color(AccentColor value) {
    _color = value;
    notifyListeners();
  }

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  set mode(ThemeMode value) {
    _mode = value;
    notifyListeners();
  }

  PaneDisplayMode _paneMode = PaneDisplayMode.auto;
  PaneDisplayMode get paneMode => _paneMode;
  set paneMode(PaneDisplayMode value) {
    _paneMode = value;
    notifyListeners();
  }

  NavigationIndicators _indicators = NavigationIndicators.sticky;
  NavigationIndicators get indicators => _indicators;
  set indicators(NavigationIndicators value) {
    _indicators = value;
    notifyListeners();
  }

  WindowEffect _windowEffect = WindowEffect.acrylic;
  WindowEffect get windowEffect => _windowEffect;
  set windowEffect(WindowEffect value) {
    _windowEffect = value;
    notifyListeners();
  }

  void setEffect(WindowEffect effect, BuildContext context) {
    Window.setEffect(
      effect: effect,
      color: [
        WindowEffect.solid,
        WindowEffect.acrylic,
      ].contains(effect)
        ? FluentTheme.of(context).micaBackgroundColor.withOpacity(0.05)
        : Colors.transparent,
      dark: FluentTheme.of(context).brightness.isDark,
    );
  }

  TextDirection _textDirection = TextDirection.ltr;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection direction) {
    _textDirection = direction;
    notifyListeners();
  }
}

AccentColor get systemAccentColor {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    return AccentColor.swatch({
      'darkest': SystemTheme.accentColor.darkest,
      'darker': SystemTheme.accentColor.darker,
      'dark': SystemTheme.accentColor.dark,
      'normal': SystemTheme.accentColor.accent,
      'light': SystemTheme.accentColor.light,
      'lighter': SystemTheme.accentColor.lighter,
      'lightest': SystemTheme.accentColor.lightest,
    });
  }
  return Colors.purple;
}
