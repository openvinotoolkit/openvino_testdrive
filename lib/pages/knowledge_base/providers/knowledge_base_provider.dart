import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';

class KnowledgeBaseProvider extends ChangeNotifier {
  Box<KnowledgeGroup> groupBox;

  List<KnowledgeGroup> _groups = [];
  List<KnowledgeGroup> get groups => _groups;
  set groups(List<KnowledgeGroup> value) {
    _groups = value;
    notifyListeners();
  }

  KnowledgeGroup? _activeGroup;
  KnowledgeGroup? get activeGroup => _activeGroup;
  set activeGroup(KnowledgeGroup? value) {
    _activeGroup = value;
    notifyListeners();
  }

  int? _isEditingId;
  int? get isEditingId => _isEditingId;
  set isEditingId(int? value) {
    _isEditingId = value;
    notifyListeners();
  }

  void renameGroup(KnowledgeGroup group, String value) {
    groupBox.put(group..name = value);
    isEditingId = null;
  }

  void deleteGroup(KnowledgeGroup group) {
    final documentsBox = ObjectBox.instance.store.box<KnowledgeDocument>();
    final sectionBox = ObjectBox.instance.store.box<EmbeddingEntity>();
    for (final document in group.documents) {
      sectionBox.removeMany(document.sections.map((i) => i.internalId).toList());
    }
    documentsBox.removeMany(group.documents.map((i) => i.internalId).toList());
    groupBox.remove(group.internalId);
    groups.remove(group);
    notifyListeners();
  }

  void addGroup() {
    isEditingId = groupBox.put(KnowledgeGroup("New group"));
    groups = groupBox.getAll();
  }

  void setActiveGroup(KnowledgeGroup group) {
    activeGroup = group;
  }

  KnowledgeBaseProvider({required this.groupBox}) {
    groupBox.getAllAsync().then((value) {
        groups = value;
        activeGroup = groups.firstOrNull;
    });
  }
}
