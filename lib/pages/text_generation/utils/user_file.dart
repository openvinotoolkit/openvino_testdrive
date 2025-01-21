import 'package:langchain/langchain.dart';
import 'package:path/path.dart';

class UserFile {
  final String path;
  final String kind;
  List<Document> documents = [];
  String? error;

  UserFile({required this.path, required this.kind});

  String get filename => basename(path);

  factory UserFile.fromPath(String path) {
    return UserFile(path: path, kind: extension(path).substring(1).toUpperCase());
  }
}
