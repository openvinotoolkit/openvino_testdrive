// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/theme_fluent.dart';

class GroupItem extends StatefulWidget {
  final KnowledgeGroup group;
  final bool isActive;
  final Function()? onActivate;
  final Function()? onDelete;

  const GroupItem({
      super.key,
      required this.group,
      this.onActivate,
      this.isActive = false,
      this.onDelete,
  });

  @override
  State<GroupItem> createState() => _GroupItemState();
}

class _GroupItemState extends State<GroupItem> {
  final controller = TextEditingController();
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    controller.text = widget.group.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onActivate?.call();
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() => isHovering = false),
        child: Container(
          padding: const EdgeInsets.only(left: 8, right: 3),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            color: widget.isActive ? highlightColor.of(theme) : null,
          ),
          height: 32,
          child: Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.group.name),
                    if (isHovering) IconButton(icon: const Icon(FluentIcons.delete, size: 10), onPressed: () {
                        widget.onDelete?.call();
                    }),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
