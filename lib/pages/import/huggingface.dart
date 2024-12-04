import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/pages/import/widgets/badge.dart';
import 'package:inference/pages/import/widgets/model_card.dart';
import 'package:inference/widgets/controls/dropdown_multiple_select.dart';
import 'package:inference/widgets/controls/search_bar.dart';
import 'package:inference/widgets/fixed_grid.dart';

class Huggingface extends StatefulWidget {
  const Huggingface({super.key});

  @override
  State<Huggingface> createState() => _HuggingfaceState();
}

class _HuggingfaceState extends State<Huggingface> {
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
    return SingleChildScrollView(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1228),
        child: Padding(
          padding: const EdgeInsets.only(left: 133, right: 80, top: 36),
          child: Column(
            children: [
              Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Semantics(
                      label: 'Find a model',
                      child: SearchBar(onChange: (value) { setState(() {
                        searchValue = value;
                      }); }, placeholder: 'Find a model',),
                    ),
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
      ),
    );
  }
}
