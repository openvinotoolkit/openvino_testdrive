import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/models/widgets/model_card.dart';
import 'package:inference/pages/models/widgets/searchbar.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/widgets/controls/filled_dropdown_button.dart';
import 'package:provider/provider.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  String? filter = "";

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: const EdgeInsets.all(0),
      header: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0x0D000000),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Detection",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      content: Column(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1228),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 65, right: 65, top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SearchBar(onChange: (f) => setState(() => filter = f)),
                        IconButton(icon: const Icon(FluentIcons.sort), onPressed: () {}),
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
                            child: Consumer<ProjectProvider>(builder: (context, provider, child) {

                              var filtered = provider.projects
                                .where((project) =>
                                    project.name.toLowerCase().contains((filter ?? "").toLowerCase())
                                );

                              return GridView.builder(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 240, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 10/13),
                                shrinkWrap: true,
                                itemCount: filtered.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ModelCard(project: filtered.elementAt(index));
                                }
                              );
                            }),
                          ),
                        ]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
