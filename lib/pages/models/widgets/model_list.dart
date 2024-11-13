import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/pages/models/widgets/model_card.dart';
import 'package:inference/pages/models/widgets/searchbar.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/widgets/fixed_grid.dart';
import 'package:provider/provider.dart';

class ModelList extends StatelessWidget {
  const ModelList({super.key});
  final String? filter = null;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GridContainer(
      color: theme.scaffoldBackgroundColor,
      child: Consumer<ProjectFilterProvider>(builder: (context, filter, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 65, right: 65, top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SearchBar(onChange: (f) => filter.name = f),
                  IconButton(icon: Icon(filter.order ? FluentIcons.ascending : FluentIcons.descending), onPressed: () => filter.order = !filter.order),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 2),
                      child: Consumer<ProjectProvider>(builder: (context, projectProvider, child) {
                        final filtered = filter.applyFilter(projectProvider.projects);
                        return FixedGrid(
                          tileWidth: 240,
                          spacing: 24,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return ModelCard(project: filtered[index]);
                          },
                        );
                      }),
                    ),
                  ]
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
