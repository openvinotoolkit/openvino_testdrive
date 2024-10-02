import 'package:flutter_test/flutter_test.dart';
import 'package:inference/importers/geti_deployment.dart';
import 'package:inference/importers/importer.dart';
import 'package:inference/importers/project_zip.dart';
import 'package:inference/importers/xml_importer.dart';

void main() {
  group('zip', () {
    test("import of geti deployment zip", () {
      const path = "/data/deployments/Deployment-Cattle detection.zip";
      expect(selectMatchingImporter(path) is GetiDeploymentProcessor, true);
    });

    test("import of project zip", () {
      const path = "/data/project_zips/cattle_detection_project.zip";
      expect(selectMatchingImporter(path) is ProjectZipImporter, true);
    });

    test("import fault zip", () {
      const path = "/data/project_zips/faulty.zip";
      expect(selectMatchingImporter(path), null);
    });

    test("import unknown file", () {
      const path = "/data/project_zips/faulty.txt";
      expect(selectMatchingImporter(path), null);
    });
  });
  group("xml", () {
    test("import faulty xml file", () {
      const path = "/data/project_zips/faulty.xml";
      expect(selectMatchingImporter(path), null);
    });

    test("import xml file", () {
      const path =
          "/data/public/efficientnet-b0-pytorch/FP16/efficientnet-b0-pytorch.xml";
      expect(selectMatchingImporter(path) is XMLImporter, true);
    });
  });
}
