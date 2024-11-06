
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

enum NavigationIndicators { sticky, end }

class AppTheme extends ChangeNotifier {
  final fontFamily = 'Intel One';

  AccentColor? _color;
  AccentColor get color => _color ?? electricCosmos;
  set color(AccentColor value) {
    _color = value;
    notifyListeners();
  }

  AccentColor? _darkColor;
  AccentColor get darkColor => _darkColor ?? cosmos;
  set darkColor(AccentColor value) {
    _darkColor = value;
    notifyListeners();
  }

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  set mode(ThemeMode value) {
    _mode = value;
    notifyListeners();
  }

  void toggleTheme() {
    switch (mode) {
      case ThemeMode.system:
        mode = ThemeMode.light;
        break;
      case ThemeMode.light:
        mode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        mode = ThemeMode.system;
        break;
    }
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

final AccentColor electricCosmos = AccentColor.swatch(const {
  'normal': Color(0xFF7000FF),
});

final AccentColor cosmos = AccentColor.swatch(const {
  'normal': Color(0xFFAF98FF),
});

final AccentColor darkCosmos = AccentColor.swatch(const {
  'normal': Color(0xFF38007F),
});

