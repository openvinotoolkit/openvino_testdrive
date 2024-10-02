import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:inference/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

final archiveContext = Context(style: Style.posix); // ZipDecoder uses posix format


Future<String> fontPath() async {
  final directory = await getApplicationSupportDirectory();
  final platformContext = Context(style: Style.platform);
  return platformContext.join(directory.path, "font.ttf");
}

Future<void> ensureFontIsStored() async {
  final file = File(await fontPath());
  if (file.existsSync()) {
    return;
  }
  final data = await rootBundle.load("fonts/intelone-text-regular.ttf");
  List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await file.writeAsBytes(bytes);
}

Future<List<Project>> loadProjectsFromStorage() async {
  final directory = await getApplicationSupportDirectory();

  return List.from(directory.listSync()
    .map((projectFolder) {
      if (!Directory(projectFolder.path).existsSync()) {
        return null;
      }
      final platformContext = Context(style: Style.platform);
      try {
        final content = File(platformContext.join(projectFolder.path, "project.json")).readAsStringSync();
        final project = Project.fromJson(jsonDecode(content), projectFolder.path);
        //if (!project.verify()) {
        //  throw Exception("project not valid. removing");
        //}
        project.loaded.complete();
        return project;
      } catch (exception) {
        print(exception);
        //Directory(projectFolder.path).deleteSync(recursive: true);
        return null;
      }
    })
    .where((project) => project != null)
  );
}

Future<void> deleteProjectData(Project project) async {
  Directory(project.storagePath).deleteSync(recursive: true);
}

