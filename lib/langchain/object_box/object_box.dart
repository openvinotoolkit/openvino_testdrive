import 'package:inference/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store store;
  static ObjectBox? _instance;
  static ObjectBox get instance {
    return _instance!;
  }

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationSupportDirectory();
    print(docsDir);
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "database"), macosApplicationGroup: "7JAX88H864.demo");
    ObjectBox._instance = ObjectBox._create(store);
    return ObjectBox.instance;
  }
}
