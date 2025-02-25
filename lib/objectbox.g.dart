// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'langchain/object_box/embedding_entity.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 8469457490244584725),
      name: 'EmbeddingEntity',
      lastPropertyId: const obx_int.IdUid(7, 2731511462795359349),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 8552784326737027156),
            name: 'id',
            type: 9,
            flags: 34848,
            indexId: const obx_int.IdUid(3, 7103919789416799183)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 4363650642507274422),
            name: 'embeddings',
            type: 28,
            flags: 8,
            indexId: const obx_int.IdUid(2, 2607198788107676613),
            hnswParams: obx_int.ModelHnswParams(
              dimensions: 384,
            )),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 6705992507435302097),
            name: 'internalId',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 8848806766523546386),
            name: 'content',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 4114370827988696345),
            name: 'metadata',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 2731511462795359349),
            name: 'documentId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(4, 7520582694797071486),
            relationTarget: 'KnowledgeDocument')
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(3, 4515540626544244263),
      name: 'KnowledgeDocument',
      lastPropertyId: const obx_int.IdUid(3, 2595692897839311317),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 3359176619692738751),
            name: 'internalId',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 8242121426427390174),
            name: 'source',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 2595692897839311317),
            name: 'groupId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(5, 7690804999658925272),
            relationTarget: 'KnowledgeGroup')
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[
        obx_int.ModelBacklink(
            name: 'sections', srcEntity: 'EmbeddingEntity', srcField: '')
      ]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(4, 2067005318326451866),
      name: 'KnowledgeGroup',
      lastPropertyId: const obx_int.IdUid(2, 8019835935012061452),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 2982807804799822186),
            name: 'internalId',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 8019835935012061452),
            name: 'name',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[
        obx_int.ModelBacklink(
            name: 'documents', srcEntity: 'KnowledgeDocument', srcField: '')
      ])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(4, 2067005318326451866),
      lastIndexId: const obx_int.IdUid(5, 7690804999658925272),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [4278071176035141580],
      retiredIndexUids: const [],
      retiredPropertyUids: const [
        6051128229014880387,
        4630118823022604903,
        7469255254719781803,
        5554893440072006430
      ],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    EmbeddingEntity: obx_int.EntityDefinition<EmbeddingEntity>(
        model: _entities[0],
        toOneRelations: (EmbeddingEntity object) => [object.document],
        toManyRelations: (EmbeddingEntity object) => {},
        getId: (EmbeddingEntity object) => object.internalId,
        setId: (EmbeddingEntity object, int id) {
          object.internalId = id;
        },
        objectToFB: (EmbeddingEntity object, fb.Builder fbb) {
          final idOffset = fbb.writeString(object.id);
          final embeddingsOffset = fbb.writeListFloat32(object.embeddings);
          final contentOffset = fbb.writeString(object.content);
          final metadataOffset = fbb.writeString(object.metadata);
          fbb.startTable(8);
          fbb.addOffset(0, idOffset);
          fbb.addOffset(2, embeddingsOffset);
          fbb.addInt64(3, object.internalId);
          fbb.addOffset(4, contentOffset);
          fbb.addOffset(5, metadataOffset);
          fbb.addInt64(6, object.document.targetId);
          fbb.finish(fbb.endTable());
          return object.internalId;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 4, '');
          final contentParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 12, '');
          final metadataParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final embeddingsParam =
              const fb.ListReader<double>(fb.Float32Reader(), lazy: false)
                  .vTableGet(buffer, rootOffset, 8, []);
          final object = EmbeddingEntity(
              idParam, contentParam, metadataParam, embeddingsParam)
            ..internalId =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0);
          object.document.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0);
          object.document.attach(store);
          return object;
        }),
    KnowledgeDocument: obx_int.EntityDefinition<KnowledgeDocument>(
        model: _entities[1],
        toOneRelations: (KnowledgeDocument object) => [object.group],
        toManyRelations: (KnowledgeDocument object) => {
              obx_int.RelInfo<EmbeddingEntity>.toOneBacklink(
                      7,
                      object.internalId,
                      (EmbeddingEntity srcObject) => srcObject.document):
                  object.sections
            },
        getId: (KnowledgeDocument object) => object.internalId,
        setId: (KnowledgeDocument object, int id) {
          object.internalId = id;
        },
        objectToFB: (KnowledgeDocument object, fb.Builder fbb) {
          final sourceOffset = fbb.writeString(object.source);
          fbb.startTable(4);
          fbb.addInt64(0, object.internalId);
          fbb.addOffset(1, sourceOffset);
          fbb.addInt64(2, object.group.targetId);
          fbb.finish(fbb.endTable());
          return object.internalId;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final sourceParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final object = KnowledgeDocument(sourceParam)
            ..internalId =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          object.group.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0);
          object.group.attach(store);
          obx_int.InternalToManyAccess.setRelInfo<KnowledgeDocument>(
              object.sections,
              store,
              obx_int.RelInfo<EmbeddingEntity>.toOneBacklink(
                  7,
                  object.internalId,
                  (EmbeddingEntity srcObject) => srcObject.document));
          return object;
        }),
    KnowledgeGroup: obx_int.EntityDefinition<KnowledgeGroup>(
        model: _entities[2],
        toOneRelations: (KnowledgeGroup object) => [],
        toManyRelations: (KnowledgeGroup object) => {
              obx_int.RelInfo<KnowledgeDocument>.toOneBacklink(
                      3,
                      object.internalId,
                      (KnowledgeDocument srcObject) => srcObject.group):
                  object.documents
            },
        getId: (KnowledgeGroup object) => object.internalId,
        setId: (KnowledgeGroup object, int id) {
          object.internalId = id;
        },
        objectToFB: (KnowledgeGroup object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          fbb.startTable(3);
          fbb.addInt64(0, object.internalId);
          fbb.addOffset(1, nameOffset);
          fbb.finish(fbb.endTable());
          return object.internalId;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final object = KnowledgeGroup(nameParam)
            ..internalId =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          obx_int.InternalToManyAccess.setRelInfo<KnowledgeGroup>(
              object.documents,
              store,
              obx_int.RelInfo<KnowledgeDocument>.toOneBacklink(
                  3,
                  object.internalId,
                  (KnowledgeDocument srcObject) => srcObject.group));
          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [EmbeddingEntity] entity fields to define ObjectBox queries.
class EmbeddingEntity_ {
  /// See [EmbeddingEntity.id].
  static final id =
      obx.QueryStringProperty<EmbeddingEntity>(_entities[0].properties[0]);

  /// See [EmbeddingEntity.embeddings].
  static final embeddings =
      obx.QueryHnswProperty<EmbeddingEntity>(_entities[0].properties[1]);

  /// See [EmbeddingEntity.internalId].
  static final internalId =
      obx.QueryIntegerProperty<EmbeddingEntity>(_entities[0].properties[2]);

  /// See [EmbeddingEntity.content].
  static final content =
      obx.QueryStringProperty<EmbeddingEntity>(_entities[0].properties[3]);

  /// See [EmbeddingEntity.metadata].
  static final metadata =
      obx.QueryStringProperty<EmbeddingEntity>(_entities[0].properties[4]);

  /// See [EmbeddingEntity.document].
  static final document =
      obx.QueryRelationToOne<EmbeddingEntity, KnowledgeDocument>(
          _entities[0].properties[5]);
}

/// [KnowledgeDocument] entity fields to define ObjectBox queries.
class KnowledgeDocument_ {
  /// See [KnowledgeDocument.internalId].
  static final internalId =
      obx.QueryIntegerProperty<KnowledgeDocument>(_entities[1].properties[0]);

  /// See [KnowledgeDocument.source].
  static final source =
      obx.QueryStringProperty<KnowledgeDocument>(_entities[1].properties[1]);

  /// See [KnowledgeDocument.group].
  static final group =
      obx.QueryRelationToOne<KnowledgeDocument, KnowledgeGroup>(
          _entities[1].properties[2]);

  /// see [KnowledgeDocument.sections]
  static final sections =
      obx.QueryBacklinkToMany<EmbeddingEntity, KnowledgeDocument>(
          EmbeddingEntity_.document);
}

/// [KnowledgeGroup] entity fields to define ObjectBox queries.
class KnowledgeGroup_ {
  /// See [KnowledgeGroup.internalId].
  static final internalId =
      obx.QueryIntegerProperty<KnowledgeGroup>(_entities[2].properties[0]);

  /// See [KnowledgeGroup.name].
  static final name =
      obx.QueryStringProperty<KnowledgeGroup>(_entities[2].properties[1]);

  /// see [KnowledgeGroup.documents]
  static final documents =
      obx.QueryBacklinkToMany<KnowledgeDocument, KnowledgeGroup>(
          KnowledgeDocument_.group);
}
