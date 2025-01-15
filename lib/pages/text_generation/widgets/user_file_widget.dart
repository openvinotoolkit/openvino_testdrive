import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/text_generation/utils/user_file.dart';
import 'package:inference/widgets/elevation.dart';

class UserFileWidget extends StatelessWidget {
  final Function? onDelete;
  final UserFile file;
  const UserFileWidget({super.key, required this.file, this.onDelete});

  final double iconSize = 30.0;

  @override
  Widget build(BuildContext context) {
    if (file.error == null) {
      return buildWidget(context);
    } else {
      return Tooltip(
        message: file.error,
        style: const TooltipThemeData(
          waitDuration: Duration(),
        ),
        child: buildWidget(context),
      );
    }
  }

  Widget buildWidget(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: file.error == null
            ? theme.activeColor
            : Colors.red
        ),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: theme.accentColor,
                //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              padding: const EdgeInsets.all(8.0),
              child: file.loading
                ? SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: ProgressRing(
                    activeColor: theme.activeColor,
                    backgroundColor: theme.accentColor,
                  ),
                )
                : icon(theme.activeColor)
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.filename),
                  Text(file.kind, style: TextStyle(
                      color: theme.inactiveColor.withAlpha(100),
                  )),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(FluentIcons.clear, size: 8),
              onPressed: () => onDelete?.call(),
            )
          ],
        ),
      )
    );
  }

  Icon icon(Color color) {
    return switch(file.kind) {
      "PDF" => Icon(FluentIcons.pdf, size: iconSize, color: color),
      _ => Icon(FluentIcons.document, size: iconSize, color: color),
    };
  }
}
