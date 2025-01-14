import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/widgets/controls/drop_area.dart';

class ImageGrid extends StatefulWidget {
  final List<String> initialGalleryData;
  final void Function(List<String>) onFileListChange;

  const ImageGrid({
    super.key,
    required this.initialGalleryData,
    required this.onFileListChange,
  });

  @override
  _ImageGridState createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  late List<String> galleryData;
  Map<int, bool> hoverStates = {};

  @override
  void initState() {
    super.initState();
    galleryData = List<String>.from(widget.initialGalleryData);
  }

  void onDrop(String path) {
    if (!galleryData.contains(path)) {
      setState(() {
        galleryData.add(path);
      });
      widget.onFileListChange(galleryData);
    }
  }

  void removeImage(int index) {
    setState(() {
      hoverStates.remove(index);
      galleryData.removeAt(index);

      widget.onFileListChange(galleryData);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return DropArea(
      showChild: galleryData.isNotEmpty,
      onUpload: onDrop,
      type: "image",
      extensions: const ["jpg", "jpeg", "bmp", "png", "tif", "tiff"],
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 7,
        children: List.generate(galleryData.length, (index) {
          String path = galleryData[index];
          bool isLocalFile = File(path).existsSync(); // Check if the file exists locally

          bool isHovered = hoverStates[index] ?? false; // Get hover state
          return MouseRegion(
            onEnter: (_) {
              setState(() {
                hoverStates[index] = true;
              });
            },
            onHover: (_) {
              setState(() {
                hoverStates[index] = true;
              });
            },
            onExit: (_) {
              setState(() {
                hoverStates[index] = false;
              });
            },
            child: Stack(
              children: [
                Container(
                  width: width * 0.3,
                  height: height * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    image: DecorationImage(
                      image: isLocalFile
                          ? FileImage(File(path)) // Load local file
                          : NetworkImage(path) as ImageProvider, // Load from network
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isHovered)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FluentIcons.cancel,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}