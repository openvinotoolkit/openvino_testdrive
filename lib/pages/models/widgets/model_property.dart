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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: const Color(0xFFF5F5F5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: RichText(
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
          ),
        ),
      ),
    );
  }
}
