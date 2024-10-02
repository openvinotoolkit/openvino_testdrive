import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void setupErrors() async {
    final directory = await getApplicationSupportDirectory();
    final platformContext = Context(style: Style.platform);

    final errorPath = platformContext.join(directory.path, "errors.log");

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      final contents = """
${details.exception.toString()}
${details.stack.toString()}

""";
    File(errorPath).writeAsStringSync(contents, mode: FileMode.append);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      print("PlatformDispatcher error ");

      final contents = """
${error.toString()}
${stack.toString()}

""";
      print(contents);
      File(errorPath).writeAsStringSync(contents, mode: FileMode.append);
      return true;
    };
}
