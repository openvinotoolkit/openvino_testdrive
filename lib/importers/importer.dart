import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/geti_deployment.dart';
import 'package:inference/importers/project_zip.dart';

import 'package:archive/archive_io.dart';
import 'package:inference/project.dart';
import 'package:mime/mime.dart';


abstract class Importer {

  bool match();
  Future<Project> generateProject();
  Future<void> setupFiles();
  Future<bool> askUser(BuildContext context);
}



Importer? selectMatchingImporter(String file) {
  // if file is xml do some other check first.
  //
  //
  // if file is  zip archive
  // check geti processor
  // check project zip
  // check if zip contains image model
  // check if zip contains text model

  //{
  //  final importer = ProjectDirImporter(file);
  //  if (importer.match()) {
  //    return importer;
  //  }
  //}

  final mimeType = lookupMimeType(file);
  //if (mimeType == "application/xml"){
  //  {
  //    final importer = XMLImporter(file);
  //    if (importer.match()) {
  //      return importer;
  //    }
  //  }
  //}

  if (mimeType == "application/zip") {
    final inputStream = InputFileStream(file);
    final archive = ZipDecoder().decodeBuffer(inputStream);

    {
      final projectZipImporter = ProjectZipImporter(file, archive);
      if (projectZipImporter.match()) {
        return projectZipImporter;
      }
    }
    {
      final getiDeploymentImporter = GetiDeploymentProcessor(file, archive);
      if (getiDeploymentImporter.match()) {
        return getiDeploymentImporter;
      }
    }
  }

  return null;
}
