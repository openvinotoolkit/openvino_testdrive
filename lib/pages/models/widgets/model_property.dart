import 'package:fluent_ui/fluent_ui.dart';

class ModelProperty extends StatelessWidget {
  final String name;
  final String value;

  const ModelProperty({
    super.key,
    required this.name,
    required this.value,
  });


  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF242424),
          fontSize: 12,
        ),

        children: <TextSpan>[
          TextSpan(text: "$name: "),
          TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
