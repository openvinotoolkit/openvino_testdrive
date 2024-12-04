import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';

class ImportProvider extends ChangeNotifier {
  Future<List<Model>>? allModelsFuture;
  Model? _selectedModel;
  Model? get selectedModel => _selectedModel;
  set selectedModel(Model? model) {
    _selectedModel = model;
    notifyListeners();
  }

  ImportProvider() {
    final importer = ManifestImporter('assets/manifest.json');
    allModelsFuture = importer.loadManifest().then((_) => importer.getAllModels());
    selectedModel = null;
  }

}
