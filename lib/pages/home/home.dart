import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/pages/home/widgets/model_card.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/pages/home/widgets/project_card.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/widgets/controls/filled_dropdown_button.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Model>> popularModelsFuture;

  @override
  void initState() {
    super.initState();
    final importer = ManifestImporter('assets/manifest.json');
    popularModelsFuture = importer.loadManifest().then((_) => importer.getPopularModels());
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      padding: const EdgeInsets.all(0),
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Image.asset("images/banner.png", fit: BoxFit.cover, width: double.infinity, height: 400,),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset("images/openvino_logo.svg", width: 81),
                              const Text("TestDrive",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Model>>(
              future: popularModelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ProgressRing();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No popular models available');
                } else {
                  final popularModels = snapshot.data!;
                  return HorizontalScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                      child: Row(
                        children: popularModels.map((model) => Padding(
                          padding: EdgeInsets.only(
                          right: popularModels.indexOf(model) == popularModels.length - 1 ? 0 : 32,
                          ),
                          child: ModelCard(model: model),
                      )).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, top: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1228),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My models',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(icon: const Icon(FluentIcons.filter), onPressed: () {}),
                          IconButton(icon: const Icon(FluentIcons.sort_down), onPressed: () {}),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 24),
                            child: const Divider(direction: Axis.vertical,style: DividerThemeData(
                              verticalMargin: EdgeInsets.symmetric(horizontal: 8),
                            ),),
                          ),
                          FilledDropDownButton(
                            title: const Text('Import model'),
                            items: [
                              MenuFlyoutItem(text: const Text('Hugging Face'), onPressed: () {}),
                              MenuFlyoutItem(text: const Text('Local disk'), onPressed: () {}),
                            ]
                          )
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Consumer<ProjectProvider>(builder: (context, value, child) {
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320, crossAxisSpacing: 32, mainAxisSpacing: 32, childAspectRatio: 6/8),
                        shrinkWrap: true,
                        itemCount: value.projects.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ProjectCard(project: value.projects.elementAt(index));
                        }
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
