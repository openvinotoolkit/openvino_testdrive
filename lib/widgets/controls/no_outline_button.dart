import 'package:fluent_ui/fluent_ui.dart';

class NoOutlineButton extends BaseButton {
  const NoOutlineButton({
    super.key,
    required super.child,
    required super.onPressed,
    super.onLongPress,
    super.onTapDown,
    super.onTapUp,
    super.focusNode,
    super.autofocus = false,
    super.style,
    super.focusable = true,
  });


  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ButtonStyle(
      padding: const WidgetStatePropertyAll(kDefaultButtonPadding),
      foregroundColor: WidgetStatePropertyAll(theme.inactiveColor),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.isDisabled) {
          return theme.resources.controlFillColorDisabled.withOpacity(0.30);
        } else if (states.isPressed) {
          return theme.inactiveColor.withOpacity(0.10);
        } else if (states.isHovered) {
          return theme.inactiveColor.withOpacity(0.10);
        } else {
          return Colors.transparent;
        }
      }),
      textStyle: const WidgetStatePropertyAll(TextStyle(
        fontSize: 13.0,
        letterSpacing: 0.5,
      )),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    return ButtonTheme.of(context).outlinedButtonStyle;
  }

}
