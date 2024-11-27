import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/knowledge_base/providers/knowledge_base_provider.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/theme_fluent.dart';
import 'package:provider/provider.dart';

class DocumentsList extends StatelessWidget {
  const DocumentsList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Consumer<KnowledgeBaseProvider>(
      builder: (context, data, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridContainer(
              color: backgroundColor.of(theme),
              padding: const EdgeInsets.all(16),
              child: Text(data.activeGroup?.name ?? "",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Container(),
          ],
        );
      }
    );
  }
}
