import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

bool isImage(String path) {
  final mimeType = lookupMimeType(path);
  if (mimeType == null) {
    return false;
  }
  return mimeType.startsWith('image/');
}


bool pathIsValid(String path) {
  // Directory.exists will return false if the file is not a folder.
  return Directory(path).existsSync();
}

class Progress {
  int current = 0;
  final int total;

  Progress(this.total);

  double percentage() {
    return current.toDouble() / total;
  }
}


class BatchInference extends StatefulWidget {
  const BatchInference({super.key});

  @override
  State<BatchInference> createState() => _BatchInferenceState();
}

class _BatchInferenceState extends State<BatchInference> {

  String sourceFolder = "";
  String destinationFolder = "";
  bool forceStop = false;
  Progress? progress;

  bool get isRunning {
    if (progress == null) {
      return false;
    }

    if (forceStop) {
      return false;
    }

    return progress!.current < progress!.total;
  }

  bool get canProcess =>
      pathIsValid(sourceFolder) && pathIsValid(destinationFolder) &&
      serializationOutput.any();

  SerializationOutput serializationOutput = SerializationOutput(overlay: true);

  void processFolder(BuildContext context, ImageInferenceProvider inference) async {
    final platformContext = Context(style: Style.platform);
    final dir = Directory(sourceFolder);
    final listener = dir.list(recursive: true);

    final list = await listener.toList();
    setState(() {
      progress = Progress(list.where((item) => isImage(item.path)).length);
      forceStop = false;
    });

    List<List<dynamic>> rows = [];
    const encoder = JsonEncoder.withIndent("  ");
    const converter = CsvToListConverter();
    inference.lock();

    for (final file in list) {
      if (forceStop) {
        break;
      }
      if (isImage(file.path)) {
        final outputFilename = platformContext.basename(file.path);
        Uint8List imageData = File(file.path).readAsBytesSync();
        final inferenceResult = await inference.infer(imageData, serializationOutput);
        await Future.delayed(Duration.zero); // For some reason ui does not update even though it's running in Isolate. This gives the UI time to run that code.
        final outputPath = platformContext.join(destinationFolder, outputFilename);
        if (serializationOutput.overlay) {
          final outputFile = File(outputPath);
          final decodedImage = base64Decode(inferenceResult.overlay!);
          outputFile.writeAsBytes(decodedImage);
        }
        if (serializationOutput.csv) {
          var csvOutput = converter.convert(inferenceResult.csv);
          rows.addAll(csvOutput.map((row) {
              row.insert(0, outputFilename);
              return row;
          }));
        }
        if (serializationOutput.json) {
          final outputFile = File(setExtension(outputPath, ".json"));
          outputFile.writeAsString(encoder.convert(inferenceResult.json));
        }
        setState(() {
            progress!.current += 1;
        });
      }
    }
    inference.unlock();

    if (serializationOutput.csv) {
      List<String> columns = ["filename", "label_name", "label_id", "probability", "shape_type", "x", "y", "width", "height", "area", "angle"];
      rows.insert(0, columns);
      const converter = ListToCsvConverter();
      final outputPath = platformContext.join(destinationFolder, "predictions.csv");
      File(outputPath).writeAsStringSync(converter.convert(rows));
    }
  }

  void stop() {
    setState((){
      forceStop = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageInferenceProvider>(
      builder: (context, inference, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FolderRow("Source folder",
                    initialValue: sourceFolder,
                    enabled: !isRunning,
                    onSubmit: (path) {
                      setState(() {
                          sourceFolder = path;
                      });
                    }),
                FolderRow("Destination folder",
                    initialValue: destinationFolder,
                    enabled: !isRunning,
                    onSubmit: (path) {
                      setState(() {
                          destinationFolder = path;
                      });
                    }),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 3.0),
                      child: Text("Outputs"),
                    ),
                    SwitchRow("Overlay image",
                      onChange: (value) {
                        setState(() {
                          serializationOutput.overlay = value;
                        });
                      },
                      initialValue: serializationOutput.overlay,
                    ),
                    SwitchRow("CSV",
                      onChange: (value) {
                        setState(() {
                          serializationOutput.csv = value;
                        });
                      },
                      initialValue: serializationOutput.csv,
                    ),
                    SwitchRow("JSON",
                      onChange: (value) {
                        setState(() {
                          serializationOutput.json = value;
                        });
                      },
                      initialValue: serializationOutput.json,
                    ),
                  ],
                ),
                const DeviceSelector(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: BatchProgressButton(
                    isRunning: isRunning,
                    enabled: canProcess && inference.isReady,
                    onStart: () {
                      processFolder(context, inference);
                    },
                    onStop: () => stop(),
                  ),
                ),

                BatchProgress(progress),
              ],
            ),
          ),
        );
      }
    );
  }
}

class BatchProgressButton extends StatelessWidget {
  final bool isRunning;
  final bool enabled;
  final void Function() onStart;
  final void Function() onStop;

  const BatchProgressButton({required this.onStart, required this.onStop, this.isRunning = false, this.enabled = true, super.key});

  @override
  Widget build(BuildContext context) {
    if (isRunning) {
      return ElevatedButton(
        onPressed: onStop,
        child: const Text("Stop"));
    }

    if (!enabled) {
      return ElevatedButton(
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(intelGrayLight),
          elevation: MaterialStatePropertyAll(0),
        ),
        onPressed: () {},
        child: const Text("Start"));
    }

    return ElevatedButton(
      onPressed: onStart,
      child: const Text("Start"));
  }

}

class BatchProgress extends StatelessWidget {
  final Progress? progress;
  const BatchProgress(this.progress, {super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (progress == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: 300,
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Inference progress"),
                    Text("${progress!.current}/${progress!.total}"),
                  ]),
            ),
            LinearProgressIndicator(
              value: progress!.percentage(),
              color: intelBlueLight,
              backgroundColor: intelGrayLight,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            )
          ]
          )
        );
      }
    );
  }
}

class SwitchRow extends StatefulWidget {
  final String label;
  final void Function(bool) onChange;
  final bool initialValue;
  const SwitchRow(this.label, {required this.onChange, this.initialValue = false, super.key});

  @override
  State<SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<SwitchRow> {
  bool switchState = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    switchState = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 20,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch.adaptive(
                value: switchState,
                activeColor: intelGrayReallyDark,
                activeTrackColor: lightGray,
                onChanged: (value) {
                  setState(() { switchState = value; });
                  widget.onChange(value);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(widget.label),
          ),
        ],
      ),
    );
  }
}

class FolderRow extends StatefulWidget {
  final String label;
  final bool enabled;
  final String initialValue;
  final void Function(String) onSubmit;
  const FolderRow(this.label,
      {required this.onSubmit, this.initialValue = "", this.enabled = true, super.key});

  @override
  State<FolderRow> createState() => _FolderRowState();
}

class _FolderRowState extends State<FolderRow> {
  bool _showReleaseMessage = false;
  bool pathSet = false;
  bool isValid = false;

  final controller = TextEditingController();
  final platformContext = Context(style: Style.platform);

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialValue;
    isValid = pathIsValid(controller.text);
  }

  void showReleaseMessage() {
    setState(() => _showReleaseMessage = true);
  }

  void hideReleaseMessage() {
    setState(() => _showReleaseMessage = false);
  }

  void handleDrop(DropDoneDetails details) {
    if (details.files.isNotEmpty) {
      setPath(details.files[0].path);
    }
  }

  void setPath(String path) {
    if (pathIsValid(path)) {
      controller.text = path;
      widget.onSubmit(path);
      setState(() {
        pathSet = true;
        isValid = true;
      });
    } else {
      //TODO show user error that a folder must be selected
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropTarget(
        onDragDone: (details) => handleDrop(details),
        onDragExited: (_) => hideReleaseMessage(),
        onDragEntered: (_) => showReleaseMessage(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Text(widget.label),
            ),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  height: 30,
                  child: TextField(
                    onChanged: (path) {
                      setState(() {
                        isValid = pathIsValid(path);
                        //Submit regardless. Path can be invalid, but that's less confusing to the user.
                        widget.onSubmit(path);
                        pathSet = isValid;
                      });
                    },
                    enabled: widget.enabled,
                    controller: controller,
                    textAlign: TextAlign.start,
                    style: const TextStyle (
                      color: textColor,
                      fontSize: 10,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 10, bottom: 0),
                      hintText: (_showReleaseMessage
                          ? "Release..."
                          : "Drop ${widget.label.toLowerCase()} in"),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: (isValid ? Colors.green : Colors.red),
                      )),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: FolderButton(
                    enabled: widget.enabled,
                    text: (pathSet ? "Change" : "Select"),
                    onSelect: setPath,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FolderButton extends StatelessWidget {
  final String text;
  final void Function(String) onSelect;
  final bool enabled;
  const FolderButton({required this.onSelect, required this.text, this.enabled = true,  super.key});

  void showUploadMenu() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      onSelect(result.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.folder),
        onPressed: () {},
        style: const ButtonStyle(
          elevation: MaterialStatePropertyAll(0),
          backgroundColor: MaterialStatePropertyAll(intelGrayLight),
        ),
        label: Text(text),
      );
    }

    return OutlinedButton.icon(
      icon: const Icon(Icons.folder),
      onPressed: () => showUploadMenu(),
      label: Text(text),
    );
  }
}
