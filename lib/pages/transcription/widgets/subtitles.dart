import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

class Subtitles extends StatelessWidget {
  const Subtitles({
    super.key,
    required this.transcription,
    required this.subtitleIndex,
  });

  final Map<int, FutureOr<String>>? transcription;
  final int subtitleIndex;

  static const double fontSize = 18;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 60),
      child: SizedBox(
        height: 100,
        child: Builder(
          builder: (context) {
            if (transcription == null ) {
              return Container();
            }
            if (transcription![subtitleIndex] is String) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Text(
                    transcription![subtitleIndex] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.black,
                    )
                  ),
                  Text(
                    transcription![subtitleIndex] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: fontSize
                    )
                  )
                ],
              );
            }
            return Container();
          }
        ),
      ),
    );
  }
}
