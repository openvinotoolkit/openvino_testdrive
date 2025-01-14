// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:provider/provider.dart';



class ModelFilter extends StatelessWidget {
  const ModelFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...Option.filterOptions.keys.map((key) {
            return Group(key, Option.filterOptions[key]!);
          }),
        ]
      ),
    );
  }
}

class Group extends StatefulWidget {
  final String name;
  final List<Option> options;

  const Group(this.name, this.options, {super.key});


  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  bool visible = true;


  void toggle() {
    setState(() {
        visible = !visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectFilterProvider>(builder: (context, filter, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggle,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(visible ? FluentIcons.chevron_down : FluentIcons.chevron_right, size: 8),
                    ),
                    Text(widget.name),
                  ],
                ),
              ),
            ),
          ),
          (visible
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.options.map((option) {
                  return FilterOption(
                    name: option.name,
                    enabled: filter.option == option,
                    onTap: () {
                      if (filter.option == option) {
                        filter.option = null;
                      } else {
                        filter.option = option;
                      }
                    },
                  );
                }
              ).toList()
            )
            : Container()
          )
        ]
      );
    });
  }
}

class FilterOption extends StatelessWidget {
  final String name;
  final bool enabled;
  final void Function() onTap;

  const FilterOption({
    required this.name,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: (enabled ? theme.scaffoldBackgroundColor : null),
            child: Padding(
              padding: const EdgeInsets.only(left: 23, right: 0, top: 6, bottom: 6),
              child: Text(name, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ),
      ),
    );
  }
}
