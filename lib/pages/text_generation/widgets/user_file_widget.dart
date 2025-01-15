import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/text_generation/utils/user_file.dart';
import 'package:inference/widgets/elevation.dart';

class UserFileWidget extends StatelessWidget {
  final Function? onDelete;
  final UserFile file;
  const UserFileWidget({super.key, required this.file, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: theme.activeColor,
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
              child: icon(theme.activeColor)
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
    const size = 30.0;
    return switch(file.kind) {
      "PDF" => Icon(FluentIcons.pdf, size: size, color: color),
      _ => Icon(FluentIcons.document, size: size, color: color),
    };
  }
}
