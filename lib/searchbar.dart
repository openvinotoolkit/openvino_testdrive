import 'package:flutter/material.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/theme.dart';
import 'package:provider/provider.dart';

class GetiSearchBar extends StatefulWidget {
  final Function(String) onChange;
  const GetiSearchBar({required this.onChange, super.key});

  static const escape = 4294967323;

  @override
  State<GetiSearchBar> createState() => _GetiSearchBarState();
}

class _GetiSearchBarState extends State<GetiSearchBar> {
  final controller = TextEditingController();

  bool isEmpty = true;

  void onChange(String value) {
    setState(() => isEmpty = value.isEmpty);
    widget.onChange(value);
  }

  void handleKey(KeyEvent keyEvent) {
    if (keyEvent.logicalKey.keyId == GetiSearchBar.escape) {
      onChange("");
      controller.text = "";
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      height: 40,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: handleKey,
        child: TextField(
          onChanged: (value) => onChange(value),
          controller: controller,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: textColor,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            hintText: "Search by name",
            suffixIcon: IconButton(
              icon: (isEmpty
                ? const Icon(Icons.search, color: Colors.white)
                : const Icon(Icons.clear, color: Colors.white)
              ),
              onPressed: () {
                controller.clear();
                onChange("");
              },
            ),
            enabledBorder: (controller.text.isNotEmpty
              ? const OutlineInputBorder(borderSide: BorderSide(color: intelBlue, width: 2.0))
              : null
            )
          ),
        ),
      )
    );
  }
}
