import 'package:fluent_ui/fluent_ui.dart';

class FilledDropDownButton extends DropDownButton {
  FilledDropDownButton({
    super.key,
    required super.items,
    super.leading,
    super.title,
    Widget super.trailing,
    super.verticalOffset,
    super.closeAfterClick,
    super.disabled,
    super.focusNode,
    super.autofocus,
    super.placement,
    super.menuShape,
    super.menuColor,
    super.onOpen,
    super.onClose,
    super.transitionBuilder,
  }) : super(
          buttonBuilder: (context, onOpen) => _kDefaultButtonBuilder(context, onOpen, disabled, autofocus, focusNode, leading, title, trailing),
        );
}

List<Widget> _space(
    Iterable<Widget> children, {
    Widget spacer = const SizedBox(width: 8.0),
  }) {
  return children
      .expand((child) sync* {
        yield spacer;
        yield child;
      })
      .skip(1)
      .toList();
}

Widget _kDefaultButtonBuilder(
  BuildContext context,
  void Function()? onOpen,
  bool disabled,
  bool autofocus,
  FocusNode? focusNode,
  Widget? leading,
  Widget? title,
  Widget? trailing,
) {
  final theme = FluentTheme.of(context);
  return FilledButton(
    onPressed: disabled ? null : onOpen,
    autofocus: autofocus,
    focusNode: focusNode,
    child: Builder(
      builder: (context) {
        final state = HoverButton.of(context).states;
        return IconTheme.merge(
          data: const IconThemeData(size: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _space(<Widget>[
              if (leading != null) leading,
              if (title != null) title,
              if (trailing != null)
                IconTheme.merge(
                  data: IconThemeData(
                    color: state.isDisabled
                        ? theme.resources.textOnAccentFillColorDisabled
                        : state.isPressed
                            ? theme.resources.textOnAccentFillColorSecondary
                            : theme.resources.textOnAccentFillColorPrimary,
                  ),
                  child: AnimatedSlide(
                    duration: theme.fastAnimationDuration,
                    curve: Curves.easeInCirc,
                    offset: state.isPressed
                        ? const Offset(0, 0.1)
                        : Offset.zero,
                    child: trailing,
                  ),
                ),
            ]),
          ),
        );
      }
    ),
  );
}
