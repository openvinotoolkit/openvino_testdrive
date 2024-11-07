import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/pages/models/widgets/model_card.dart';
import 'package:inference/pages/models/widgets/searchbar.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:provider/provider.dart';

class ModelList extends StatelessWidget {
  const ModelList({super.key});
  final String? filter = null;

  @override
  Widget build(BuildContext context) {
    return GridContainer(
      color: Colors.white,
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
                  IconButton(icon: const Icon(FluentIcons.sort), onPressed: () => filter.order = !filter.order),
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

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 240, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 10/13),
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ModelCard(project: filtered[index]);
                          }
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
