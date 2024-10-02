import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

//Map<int, Color> intelGrayColor = {
//  50: const Color.fromRGBO(0, 149, 202, .1),
//  100: const Color.fromRGBO(0, 149, 202, .2),
//  200: const Color.fromRGBO(0, 149, 202, .3),
//  300: const Color.fromRGBO(0, 149, 202, .4),
//  400: const Color.fromRGBO(0, 149, 202, .5),
//  500: const Color.fromRGBO(0, 149, 202, .6),
//  600: const Color.fromRGBO(0, 149, 202, .7),
//  700: const Color.fromRGBO(0, 149, 202, .8),
//  800: const Color.fromRGBO(0, 149, 202, .9),
//  900: const Color.fromRGBO(0, 149, 202, 1),
//};
//
//MaterialColor intelGrayMaterial = MaterialColor(0x0095CA, intelGrayColor);

MaterialColor getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }

const Color intelBlue = Color.fromRGBO(0, 199, 253, 1);
const Color intelBlueDark = Color.fromRGBO(0, 149, 202, 1);
const Color intelBlueVibrant = Color.fromRGBO(3, 103, 224, 1);
const Color intelBlueLight = Color.fromRGBO(114, 183, 249, 1);
const Color intelGray = Color.fromRGBO(46, 47, 50, 1);
const Color intelGrayVariant = Color.fromRGBO(50, 51, 55, 1);
const Color intelGrayLight = Color.fromRGBO(60, 62, 66, 1);
const Color intelGrayDark = Color.fromRGBO(36, 37, 40, 1);
const Color intelGrayReallyDark = Color.fromRGBO(29, 29, 29, 1);
const Color textColor = Color.fromRGBO(227, 227, 229, 1);
const Color lightGray = Color.fromRGBO(200, 200, 209, 1);
const Color warningPrimary = Color(0xFFE0C23D);
const Color warningSecondary = Color(0xFF32322E);


Color getScoreColor(double score) {
  if (score >= 0.75) {
    return const Color.fromRGBO(139, 174, 70, 1.0);
  } else if (score >= 0.5) {
    return const Color.fromRGBO(254, 201, 27, 1.0);
  }
  return const Color.fromRGBO(255, 86, 98, 1.0);
}

final ThemeData intelTheme = ThemeData(
  fontFamily: 'IntelOne',
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: intelBlue,
    onPrimary: Colors.white,
    secondary: intelBlueDark,
    onSecondary: Colors.white,
    surface: intelGrayDark,
    surfaceContainer: intelGray,
    onSurface: textColor,
    surfaceContainerHighest: intelGray,
    onSurfaceVariant: intelGrayVariant,
    error: intelGray,
    onError: intelBlue,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: const ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(intelBlueVibrant),
      foregroundColor: WidgetStatePropertyAll(Colors.white)
      //backgroundColor: getMaterialColor(intelBlue),
    )
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            width: 2,
          )
      )),
      foregroundColor: const WidgetStatePropertyAll(Colors.white),
      textStyle: const WidgetStatePropertyAll(const TextStyle(
          color: Colors.white,
      ))
    )
  ),
  textTheme: TextTheme(
    bodyMedium: const TextStyle(
      fontSize: 12,
      color: textColor,
    )
  ),
  tabBarTheme: const TabBarTheme(
    unselectedLabelStyle: TextStyle(
      color: textColor,
    ),
    dividerColor: textColor,
  ),
  sliderTheme:  SliderThemeData(
    activeTrackColor: intelGrayLight,
    inactiveTrackColor: intelGrayLight,
    trackShape: const CustomSliderTrackShape(),
    thumbColor: textColor,
    trackHeight: 4,
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.all(8),
    focusColor: Colors.white,
    hintStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      color: textColor,
    ),
    fillColor: intelGrayReallyDark,
    filled: true,
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(
        color: intelGrayLight,
        width: 2,
      )
    ),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(
        color: intelGrayLight,
        width: 2,
      )
    ),
  ),
);

final DateFormat formatter = DateFormat('dd MMMM y | h:mm a');

class CustomSliderTrackShape extends RectangularSliderTrackShape {
  const CustomSliderTrackShape();
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
