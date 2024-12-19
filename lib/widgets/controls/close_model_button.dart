// Copyright (c) 2024 Intel Corporation

// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

class CloseModelButton extends StatelessWidget {
  const CloseModelButton({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: OutlinedButton(
        style: ButtonStyle(
          shape:WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side:  const BorderSide(color: Color(0XFF545454)),
          )),
        ),
        child: const Text("Close"),
        onPressed: () => router.canPop() ? router.pop() : router.go("/home"),
      ),
    );
  }

}
