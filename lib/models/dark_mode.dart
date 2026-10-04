import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:fnmap/utilities/logger.dart';

export 'package:flex_color_scheme/flex_color_scheme.dart' show FlexScheme;

enum NMapThemeMode {
  light,
  dark,
  unknown,
}

class ThemeOption {
  final FlexScheme scheme;
  final String label;
  final String description;
  final Color primaryColor;

  const ThemeOption({
    required this.scheme,
    required this.label,
    required this.description,
    required this.primaryColor,
  });
}

class NMapDarkMode with ChangeNotifier {
  BuildContext? rootContext;
  late ThemeMode _themeMode;
  late FlexScheme _scheme;
  late bool initialized;
  NLog log = NLog('NMapDarkMode');

  static final List<ThemeOption> curatedSchemes = [
    ThemeOption(
      scheme: FlexScheme.indigo,
      label: 'Indigo (Brand)',
      description: 'Classic fnmap purple/indigo palette',
      primaryColor: FlexScheme.indigo.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.deepBlue,
      label: 'Deep Blue',
      description: 'Professional high-contrast tech blue',
      primaryColor: FlexScheme.deepBlue.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.aquaBlue,
      label: 'Aqua Blue',
      description: 'Fresh cyan & ocean blue',
      primaryColor: FlexScheme.aquaBlue.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.brandBlue,
      label: 'Brand Blue',
      description: 'Clean modern blue',
      primaryColor: FlexScheme.brandBlue.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.money,
      label: 'Emerald (Matrix)',
      description: 'Cyber hacker green aesthetic',
      primaryColor: FlexScheme.money.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.green,
      label: 'Forest Green',
      description: 'Lush natural green',
      primaryColor: FlexScheme.green.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.amber,
      label: 'Amber Sunset',
      description: 'Warm energetic amber/orange',
      primaryColor: FlexScheme.amber.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.espresso,
      label: 'Espresso',
      description: 'Warm earthy neutral palette',
      primaryColor: FlexScheme.espresso.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.shark,
      label: 'Shark Grey',
      description: 'Stealth dark slate & cool grey',
      primaryColor: FlexScheme.shark.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.shadViolet,
      label: 'Vibrant Violet',
      description: 'Modern deep violet/purple',
      primaryColor: FlexScheme.shadViolet.data.light.primary,
    ),
    ThemeOption(
      scheme: FlexScheme.materialBaseline,
      label: 'Material 3 Default',
      description: 'Google Material 3 baseline',
      primaryColor: FlexScheme.materialBaseline.data.light.primary,
    ),
  ];

  NMapDarkMode({
    bool isDark = false,
    ThemeMode? themeMode,
    FlexScheme? scheme,
  }) {
    if (themeMode != null) {
      _themeMode = themeMode;
    } else {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    _scheme = scheme ?? FlexScheme.indigo;
    initialized = true;
  }

  ThemeMode get themeMode => _themeMode;
  FlexScheme get scheme => _scheme;

  NMapThemeMode get mode {
    switch (_themeMode) {
      case ThemeMode.light:
        return NMapThemeMode.light;
      case ThemeMode.dark:
        return NMapThemeMode.dark;
      case ThemeMode.system:
        return NMapThemeMode.unknown;
    }
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }

  set mode(NMapThemeMode value) {
    switch (value) {
      case NMapThemeMode.light:
        _themeMode = ThemeMode.light;
        break;
      case NMapThemeMode.dark:
        _themeMode = ThemeMode.dark;
        break;
      case NMapThemeMode.unknown:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    log.debug('ThemeMode set to $_themeMode');
    notifyListeners();
  }

  void setScheme(FlexScheme scheme) {
    _scheme = scheme;
    log.debug('Scheme set to ${_scheme.name}');
    notifyListeners();
  }

  void toggleMode() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    log.debug('toggleMode: mode is now $_themeMode');
    notifyListeners();
  }

  ThemeData get themeData => isDarkMode ? dark : light;

  ThemeData get light {
    final theme = FlexThemeData.light(
      scheme: _scheme,
      useMaterial3: true,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        useM2StyleDividerInM3: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedBorderIsColored: false,
        alignedDropdown: true,
        tabBarItemSchemeColor: SchemeColor.primary,
        tabBarIndicatorSchemeColor: SchemeColor.primary,
        tabBarIndicatorSize: TabBarIndicatorSize.tab,
        tabBarIndicatorWeight: 3.0,
        tabBarUnselectedItemSchemeColor: SchemeColor.onSurface,
        tabBarUnselectedItemOpacity: 0.7,
      ),
    );
    return theme.copyWith(
      primaryColorLight: Colors.white,
      secondaryHeaderColor: theme.colorScheme.onSurfaceVariant,
    );
  }

  ThemeData get dark {
    final theme = FlexThemeData.dark(
      scheme: _scheme,
      useMaterial3: true,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        useM2StyleDividerInM3: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedBorderIsColored: false,
        alignedDropdown: true,
        tabBarItemSchemeColor: SchemeColor.primary,
        tabBarIndicatorSchemeColor: SchemeColor.primary,
        tabBarIndicatorSize: TabBarIndicatorSize.tab,
        tabBarIndicatorWeight: 3.0,
        tabBarUnselectedItemSchemeColor: SchemeColor.onSurface,
        tabBarUnselectedItemOpacity: 0.7,
      ),
    );
    return theme.copyWith(
      primaryColorLight: Colors.white,
      secondaryHeaderColor: theme.colorScheme.onSurfaceVariant,
    );
  }

  void initialize({required BuildContext rootContext}) {
    this.rootContext = rootContext;
    initialized = true;
  }

  @override
  String toString() {
    return _themeMode.name;
  }
}
