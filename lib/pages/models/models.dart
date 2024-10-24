import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/pages/models/widgets/model_filter.dart';
import 'package:inference/pages/models/widgets/model_list.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/widgets/controls/filled_dropdown_button.dart';
import 'package:provider/provider.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectFilterProvider(),
      child: ScaffoldPage(
        padding: const EdgeInsets.all(0),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridContainer(
                    padding: const EdgeInsets.all(16),
                    child: Text("My Models",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: const GridContainer(
                      padding: EdgeInsets.all(13),
                      child: ModelFilter()
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridContainer(
                    color: Colors.white,
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<ProjectFilterProvider>(builder: (context, projectProvider, child) {
                          return Text(projectProvider.option?.name ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                        FilledDropDownButton(
                          title: const Text('Import model'),
                          items: [
                            MenuFlyoutItem(text: const Text('Hugging Face'), onPressed: () {}),
                            MenuFlyoutItem(text: const Text('Local disk'), onPressed: () {}),
                          ]
                        )
                      ],
                    ),
                  ),
                  const ModelList(),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
