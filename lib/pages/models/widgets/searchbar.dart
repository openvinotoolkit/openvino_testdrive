import 'package:fluent_ui/fluent_ui.dart';

class SearchBar extends StatefulWidget {
  static const escape = 4294967323;

  final Function(String) onChange;
  const SearchBar({
      super.key,
      required this.onChange,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();

  void onChange(String value) {
    widget.onChange(value);
  }

  void handleKey(KeyEvent keyEvent) {
    if (keyEvent.logicalKey.keyId == SearchBar.escape) {
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
      height: 30,
      width: 278,
      child: TextBox(
        placeholder: "Find model",
        suffix: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(FluentIcons.search),
        ),
        onChanged: onChange
      ),
    );
  }
}
