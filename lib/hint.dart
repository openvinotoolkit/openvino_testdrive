import 'package:flutter/material.dart';
import 'package:inference/config.dart';
import 'package:inference/theme.dart';

class Hint extends StatefulWidget {
  final HintsEnum hint;

  const Hint({super.key, required this.hint});

  @override
  State<Hint> createState() => _HintState();
}

class _HintState extends State<Hint> {
  bool get showHint => Config.hints.hints[widget.hint]!;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (!showHint) {
          return Container();
        }
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: warningSecondary
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: warningPrimary, size: 16),
              const Padding(
                padding: EdgeInsets.only(left: 4.0, right: 8),
                child: Text("We recommend opting for Intel Core Ulta Processor (Series 2) for optimal performance when running LLM models",
                  style: TextStyle(
                    color: warningPrimary,
                  )
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: textColor, size: 14),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: (() {
                  setState(() {
                      Config.hints.hints[widget.hint] = false;
                  });
                })
              )
            ],
          ),
        );
      }
    );
  }
}
