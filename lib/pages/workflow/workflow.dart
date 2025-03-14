// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0


import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/grid_container.dart';

class WorkflowPage extends StatelessWidget {
  const WorkflowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridContainer(
          color: backgroundColor.of(theme),
          padding: const EdgeInsets.all(16),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Workflows",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),

              FilledButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  router.go('/workflows/editor');
                },
                child: const Text("Create new workflow"),
              )
            ],
          ),
        ),
        Expanded(
          child: GridContainer(
          )
        )
      ],
    );
  }

}
