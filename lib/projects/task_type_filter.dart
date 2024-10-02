import 'package:flutter/material.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/theme.dart';
import 'package:provider/provider.dart';

class TaskTypeFilter extends StatelessWidget {
  const TaskTypeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 50.0),
      child: SizedBox(
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...Option.filterOptions.keys.map((key) {
              return Group(key, Option.filterOptions[key]!);

            }), //options.map((e) {
          ]
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkResponse(
            onTap: toggle,
            splashFactory: NoSplash.splashFactory,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.name),
                  (visible
                    ? const Icon(Icons.expand_less, color: textColor,)
                    : const Icon(Icons.expand_more, color: textColor,)
                  )
                ],
              ),
            ),
          ),
          (visible
            ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        color: (enabled ? intelGray : null),
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(name),
          ),
        ),
      ),
    );
  }
}
