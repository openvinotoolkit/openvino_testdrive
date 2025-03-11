import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart' show Archive, ArchiveFile;
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/importers/geti_deployment.dart';
import 'package:inference/interop/utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../utils.dart';
import 'geti_example_project_json.dart';

class InteropUtilsMock extends Mock implements InteropUtils {}

class ArchiveMock extends Mock implements Archive {}
class ArchiveFileMock extends Mock implements ArchiveFile {

  static ArchiveFileMock withContent(String fileContent) {
    final mock = ArchiveFileMock();
    when(() => mock.content).thenReturn(fileContent);
    return mock;
  }
}

ArchiveMock buildArchiveMock(Map<String, dynamic> projectJson, Map<String, dynamic> modelJson) {
    final archive = ArchiveMock();
    final deploymentFile = ArchiveFileMock();
    when(() => deploymentFile.content).thenReturn(jsonEncode(projectJson).codeUnits);
    when(() => archive.findFile("deployment/project.json")).thenReturn(deploymentFile);

    final modelFile = ArchiveFileMock();
    when(() => modelFile.content).thenReturn(jsonEncode(modelJson).codeUnits);
    when(() => archive.findFile("deployment/Detection/model.json")).thenReturn(modelFile);
    return archive;
}

void main() {
  late FakePathProviderPlatform fakePathProvider;
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    fakePathProvider = FakePathProviderPlatform();
    PathProviderPlatform.instance = fakePathProvider;
  });

  tearDown(() {
    fakePathProvider.deleteAppDir();
  });

  test('generates project from deployment', () async {
    final archive = buildArchiveMock(cattleDetectionDeploymentJson, cattleDetectionModelJson);
    final processor = GetiDeploymentProcessor("some_zip_path", archive);
    final project = await processor.generateProject();

    expect(project.name, cattleDetectionDeploymentJson["name"]);
    expect(project.tasks.first.name, "Detection");
    expect(project.tasks.first.architecture, "MobileNetV2-ATSS");
  });

  test('writes project to storage directory from deployment', () async {

    final archive = buildArchiveMock(cattleDetectionDeploymentJson, cattleDetectionModelJson);
    final processor = GetiDeploymentProcessor("some_zip_path", archive);
    final project = await processor.generateProject();

    final binFile = ArchiveFileMock();
    when(() => binFile.content).thenReturn("binary_content".codeUnits);
    when(() => archive.findFile("deployment/Detection/model/model.bin")).thenReturn(binFile);

    final xmlFile = ArchiveFileMock();
    when(() => xmlFile.content).thenReturn("xml_content".codeUnits);
    when(() => archive.findFile("deployment/Detection/model/model.xml")).thenReturn(xmlFile);

    processor.interopUtils = InteropUtilsMock();
    when(() => processor.interopUtils.serialize(any(), any())).thenAnswer((m) async {
       final input = m.positionalArguments[0];
       final output = m.positionalArguments[1];

       File(output).writeAsBytesSync(File(input).readAsBytesSync());
       return true;
    });
    final platformContext = Context(style: Style.platform);
    final modelXmlPath = platformContext.join(project.storagePath, "${project.tasks.first.id}.xml");
    await processor.processTask(project.tasks.first);
    verify(() => processor.interopUtils.serialize(any(), any())).called(1);

    expect(File(modelXmlPath).readAsStringSync(), "xml_content");
  });
}
