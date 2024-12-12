import 'package:fluent_ui/fluent_ui.dart';

class PerformanceTile extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final bool tall;
  final Decoration? decoration;

  const PerformanceTile({
      super.key,
      required this.title,
      required this.value,
      required this.unit,
      this.tall = false,
      this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Acrylic(
        elevation: 5,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder (
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          decoration: decoration,
          child: SizedBox(
            width: 268,
            height: tall ? 200 : 124,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: theme.inactiveColor,
                      ),
                      children: [
                        TextSpan(text: value,
                          style: const TextStyle(
                            fontSize: 30,
                          )
                        ),
                        TextSpan(text: " $unit"),
                      ]
                    )
                  ),
                ],
              )
            )
          ),
        ),
      ),
    );
  }

}
