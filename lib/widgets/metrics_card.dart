// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';

class MetricsCard extends StatelessWidget {
  final String header;
  final String value;
  final String unit;

  const MetricsCard(
      {super.key,
      required this.header,
      required this.value,
      required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    const lightGradient = LinearGradient(
      begin: Alignment(-0.2, -1.0),
      end: Alignment(1.0, 1.0),
      colors: [
        Color(0xFFF6F2FC),
        Color(0xFFF3F8FF),
        Color(0xFFF3FDFB),
      ],
      stops: [0.0, 0.5, 1.0], // Matching the 0%, 50%, 100% stops
    );

    const darkGradient = LinearGradient(
      begin: Alignment(-0.36, -1.0),
      end: Alignment(1.0, 1.0),
      colors: [
        Color(0xFF373639),
        Color(0xFF2D2C2D),
        Color(0xFF323033),
        Color(0xFF363538),
      ],
      stops: [
        0.0,
        0.2941,
        0.5881,
        0.8911,
      ],
    );

    final gradient = theme.brightness.isDark ? darkGradient : lightGradient;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
          width: 268.0,
          height: 200.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            gradient: gradient,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 2,
                offset: Offset(0, 0), // CSS's offset-x and offset-y
              ),
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 4,
                offset: Offset(0, 2), // CSS's offset-x and offset-y
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                header,
                style: const TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                height: 10,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ]),
            ],
          )),
    );
  }
}
