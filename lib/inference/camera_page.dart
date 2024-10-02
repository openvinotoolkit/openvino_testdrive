import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:provider/provider.dart';

Future<ui.Image> createImage(Uint8List bytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes,
    (ui.Image img) {
      completer.complete(img);
    },
  );
  return completer.future;
}
class CameraPage extends StatefulWidget {
  final ImageInferenceProvider inferenceProvider;

  const CameraPage(this.inferenceProvider, {super.key});
  @override
  State<CameraPage> createState() => _CameraPageState();
}


class _CameraPageState extends State<CameraPage> {
  ui.Image? image;

  ImageInferenceProvider get inferenceProvider => widget.inferenceProvider;

  void openCamera() {
    inferenceProvider.openCamera(0);
    inferenceProvider.setListener((output) {
        print(output);
        createImage(base64Decode(output.overlay!)).then((frame) {
          if (mounted) {
            setState(() {
              image = frame;
            });
          }
        });
    });
  }


  @override
  void initState() {
    super.initState();
    openCamera();
  }

  @override
  void dispose() {
    inferenceProvider.closeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
            builder: (context, constraints) {
              if (image == null) {
                return Container();
              }


              return SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: ImagePainter(image!),
                  size: Size(100, 200),
                  child: Container(),
                )
,
              );
            }
          ),
      ),
    );
  }

}
class ImagePainter extends CustomPainter {
  final ui.Image image;
  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: image,
    );
    //canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return true;
  }
  @override
  bool shouldRebuildSemantics(ImagePainter oldDelegate) => false;
}
