import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/theme_fluent.dart';

class Badge extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;

  const Badge({
    super.key,
    required this.text,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: cosmos.tertiaryBrushFor(theme.brightness),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(color: darkCosmos),
          ),
          const SizedBox(width: 8.0),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDelete,
              child: Icon(
                FluentIcons.clear,
                size: 12.0,
                color: darkCosmos,
              ),
            ),
          ),
        ],
      ),
    );
  }
}