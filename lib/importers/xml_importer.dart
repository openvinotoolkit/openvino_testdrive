import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:inference/importers/importer.dart';
import 'package:inference/inference.dart';
import 'package:inference/project.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

class XMLImporter extends Importer {
  final String path;
  XmlDocument? document;
  Project? project;

  XMLImporter(this.path);


  XmlDocument readFile() {
    return XmlDocument.parse(File(path).readAsStringSync());
  }

  @override
  bool match() {
    try {
      document = readFile();
      final rtInfo = document!.xpath('/net/rt_info');
    } on XmlParserException catch(e) {
      print(e);
      return false;
    }
    return true;
  }

  @override
  Future<Project> generateProject() async {
    document??= readFile();

    final id = const Uuid().v4().toString();
    final modelId = const Uuid().v4().toString();
    final name = basenameWithoutExtension(path);
    final creationTime = DateTime.now().toIso8601String();
    print(creationTime);
    final projectType = ProjectType.image; // assume image for now.
    final directory = await getApplicationSupportDirectory();
    final storagePath = platformContext.join(directory.path, const Uuid().v4().toString());

    project = GetiProject(id, modelId, currentApplicationVersion, name, creationTime, projectType, storagePath);
    project!.hasSample = File(platformContext.join(dirname(path), "sample.jpg")).existsSync();

    final modelType = document!.xpath('/net/rt_info/model_info/model_type/@value').first.value!;
    final taskType = modelTypeToTaskType(modelType);
    final labelNames = document!.xpath('/net/rt_info/model_info/labels/@value').first.value!;
    //final labelIds = document!.xpath('/net/rt_info/model_info/labels/@value').first.value!;
    // TODO: implement label ids zip for geti projects..
    final labels = buildLabels(labelNames, taskType);
    const architecture = "placeholder";
    const optimization = "placeholder";
    project!.tasks.add(
      Task(const Uuid().v4().toString(), taskType, taskType, ["serialized.xml"], null, labels, architecture, optimization)
    );

    return project!;
  }

  @override
  Future<void> setupFiles() async {
    String folder = project!.storagePath;
    Directory(folder).createSync();

    const encoder = JsonEncoder.withIndent("  ");
    File(platformContext.join(folder, "project.json"))
        .writeAsString(encoder.convert(project!.toMap()));


    final binFilePath = File(setExtension(path, ".bin"));

    final String modelXmlPath = platformContext.join(folder, "model.xml");
    final binPath = platformContext.join(folder, "model.bin");
    File(path).copySync(modelXmlPath);
    binFilePath.copySync(binPath);

    final String serializedModelXmlPath =
        platformContext.join(folder, "serialized.xml");

    final String taskType = project!.tasks[0].taskType;
    await Isolate.run(() {
      SerializeModel(
          modelXmlPath.toNativeUtf8(),
          taskType.toNativeUtf8(),
          serializedModelXmlPath.toNativeUtf8());
    });

    final thumbnailPath = platformContext.join(project!.storagePath, "thumbnail.jpg");
    final data = await rootBundle.load("images/openvino.jpg");
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(thumbnailPath).writeAsBytes(bytes);

    project!.loaded.complete();
    return;
  }

  String modelTypeToTaskType(String modelType) {
    return switch(modelType) {
      "SSD" => "detection",
      "Classification" => "classification",
      "Segmentation" => "segmentation",
      _ => throw UnimplementedError("Model type $modelType is not implemented"),
    };
  }

  List<Label> buildLabels(String spaceSeparatedLabels, String taskType) {
    List<String> labelNames = spaceSeparatedLabels.split(" ");

    switch(taskType) {
      case "segmentation":
        // geti segmentation expects background.
        labelNames.removeAt(0);
        break;
      case "detection":
        // geti detection does not expect background.
        labelNames.insert(0, "background");
        break;
    }
    return labelNames.mapIndexed<Label>((index, name) {
        return Label(index.toString(), name, generateRandomHexColor(), false, "");
    }).toList();
  }

  @override
  Future<bool> askUser(BuildContext context) async {
    return true;
  }
}

Random random = Random();

String generateRandomHexColor(){
    int length = 6;
    String chars = '0123456789ABCDEF';
    String hex = '#';
    while(length-- > 0) {
      hex += chars[(random.nextInt(16)) | 0];
    }
    return "${hex}FF";
}
