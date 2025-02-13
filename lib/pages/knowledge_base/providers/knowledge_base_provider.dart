// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';

class KnowledgeBaseProvider extends ChangeNotifier {
  Box<KnowledgeGroup> groupBox;

  int? _activeGroup;
  int? get activeGroup => _activeGroup;

  void deleteGroup(KnowledgeGroup group) {
    final documentsBox = ObjectBox.instance.store.box<KnowledgeDocument>();
    final sectionBox = ObjectBox.instance.store.box<EmbeddingEntity>();
    for (final document in group.documents) {
      sectionBox.removeMany(document.sections.map((i) => i.internalId).toList());
    }
    documentsBox.removeMany(group.documents.map((i) => i.internalId).toList());
    groupBox.remove(group.internalId);

    if (_activeGroup == group.internalId) {
      final query = groupBox.query().build();
      setActiveGroup(query.findFirst());
    }
  }

  void addGroup() {
    final newGroup = KnowledgeGroup("new knowledge base");
    _activeGroup = groupBox.put(newGroup);
    notifyListeners();
  }

  void setActiveGroup(KnowledgeGroup? group) {
    _activeGroup = group?.internalId;
    notifyListeners();
  }

  KnowledgeBaseProvider({required this.groupBox}) {
    final query = groupBox.query().build();
    setActiveGroup(query.findFirst());
  }
}
