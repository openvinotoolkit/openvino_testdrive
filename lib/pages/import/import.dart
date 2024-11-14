import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/import/widgets/badge.dart';
import 'package:inference/pages/import/widgets/model_card.dart';
import 'package:inference/widgets/controls/search_bar.dart';
import 'package:inference/widgets/controls/dropdown_multiple_select.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/widgets/fixed_grid.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  List<String> selectedOptimizations = [];
  String? searchValue;
  late Future<List<Model>> allModelsFuture;
  late Model? selectedModel;

  @override
  void initState() {
    super.initState();
    final importer = ManifestImporter('assets/manifest.json');
    allModelsFuture = importer.loadManifest().then((_) => importer.getAllModels());
    selectedModel = null;
  }

  List<Model> filterModels(List<Model> models) {
    var filteredModels = models;
    if (searchValue != null && searchValue!.isNotEmpty) {
      filteredModels = filteredModels.where((model) => model.name.toLowerCase().contains(searchValue!.toLowerCase())).toList();
    }
    if (selectedOptimizations.isNotEmpty) {
      filteredModels = filteredModels.where((model) => selectedOptimizations.contains(model.optimizationPrecision)).toList();
    }
    return filteredModels;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return ScaffoldPage.scrollable(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
      header: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: theme.resources.controlStrokeColorDefault,
                    width: 1.0
                )
            )
          ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 18),
                child: Text('Import model',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],),
            Row(
              children: [
                FilledButton(onPressed: selectedModel == null ? (null) : () {
                  GoRouter.of(context).go('/models/download', extra: selectedModel);
                 }, child: const Text('Import selected model'),),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Button(child: const Text('Close'), onPressed: () { GoRouter.of(context).pop(); }),
                )
              ],
             )
          ],
        ),
      ),
      children:
        [
          Center(
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1228),
              child: Column(
                children: [
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: SearchBar(onChange: (value) { setState(() {
                          searchValue = value;
                        }); }, placeholder: 'Find a model',),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 184),
                          child: DropdownMultipleSelect(
                            items: const ['int4', 'int8', 'fp16'],
                            selectedItems: selectedOptimizations,
                            onChanged: (value) {
                              if (!value.contains(selectedModel?.optimizationPrecision)) {
                                selectedModel = null;
                              }
                              setState(() {
                                selectedOptimizations = value;
                              });
                            },
                            placeholder: 'Select optimizations',
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    child: SizedBox(
                      height: 28,
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          children: selectedOptimizations.map((opt) {
                            return Badge(text: opt, onDelete: () {
                              if (opt == selectedModel?.optimizationPrecision && selectedOptimizations.length > 1) {
                                selectedModel = null;
                              }
                              setState(() {
                                selectedOptimizations.remove(opt);
                              });
                            });
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  FutureBuilder<List<Model>>(
                    future: allModelsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ProgressRing();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No models available');
                      } else {
                        var allModels = filterModels(snapshot.data!);
                        return FixedGrid(
                          tileWidth: 226,
                          spacing: 24,
                          centered: true,
                          itemCount: allModels.length,
                          itemBuilder: (context, index) => ModelCard(
                            model: allModels[index],
                            checked: selectedModel == allModels[index],
                            onChecked: (value) {
                              setState(() {
                                selectedModel = value ? allModels[index] : null;
                              });
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        ]
    );
  }
}