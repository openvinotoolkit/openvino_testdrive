import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

class ToolbarTextInput extends StatefulWidget {
  final String labelText;
  final String suffix;
  final int marginLeft;
  final int initialValue;
  final bool? roundPowerOfTwo;
  final void Function(int)? onChanged;

  const ToolbarTextInput({
    super.key,
    required this.labelText,
    required this.suffix,
    required this.marginLeft,
    required this.initialValue,
    this.roundPowerOfTwo,
    this.onChanged,
  });

  @override
  State<ToolbarTextInput> createState() => _ToolbarTextInputState();
}

class _ToolbarTextInputState extends State<ToolbarTextInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue.toString(); // Set the initial text
    if (widget.roundPowerOfTwo ?? false) {
      _focusNode.addListener(_onFocusChange); // Listen for focus changes
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // When the TextBox loses focus, round and update
      final inputValue = int.tryParse(_controller.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final rounded = _nearestPowerOfTwo(inputValue);

      _controller.text = rounded.toString();
      widget.onChanged!(rounded);

    }
  }

  /// Calculate the nearest power of 2 for a given number
  int _nearestPowerOfTwo(int value) {
    if (value <= 0) return 1; // Smallest power of 2 is 1
    int lowerPower = pow(2, (log(value) / log(2)).floor()).toInt();
    int higherPower = pow(2, (log(value) / log(2)).ceil()).toInt();
    return (value - lowerPower < higherPower - value) ? lowerPower : higherPower;
  }


  void _onTextChanged(String value) {
    // Keep only digits in the input
    final newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value != newValue) {
      // Update the controller text and cursor position
      _controller.text = newValue;
      _controller.selection = TextSelection.collapsed(offset: newValue.length);
    }

    if (widget.onChanged != null) {
      if (newValue.isNotEmpty) {
        // Parse the integer and call the callback
        widget.onChanged!(int.parse(newValue));
      } else {
        // Optionally handle empty input
        widget.onChanged!(0); // You can choose to pass null or handle differently
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10 + widget.marginLeft.toDouble(), right: 10),
          child: Text(
            widget.labelText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SizedBox(
          width: 85,
          height: 30,
          child: TextBox(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 1,
            keyboardType: TextInputType.number, // Ensure numeric keyboard
            suffix: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(widget.suffix),
            ),
            onChanged: _onTextChanged, // Custom handler for integer validation
          ),
        ),
      ],
    );
  }
}
