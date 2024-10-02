import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/theme.dart';
import 'package:provider/provider.dart';

class ModelInfo extends StatelessWidget {
  final List<Widget> children;
  final Project project;
  const ModelInfo(this.project, {this.children = const [], super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(builder: (context, projects, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PropertyItem(
                name: "Model name",
                child: PropertyValue(project.name)
              ),
              PropertyItem(
                name: "Task",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: project.tasks.map((task) => PropertyValue(task.name)).toList()
                )
              ),
              PropertyItem(
                name: "Architecture",
                enabled: project.tasks.firstWhereOrNull((t) => t.architecture.isNotEmpty) != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: project.tasks.map((task) => PropertyValue(task.architecture)).toList()
                )
              ),
              PropertyItem(
                name: "Optimization",
                enabled: project.tasks.firstWhereOrNull((t) => t.optimization.isNotEmpty) != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: project.tasks.map((task) => PropertyValue(task.optimization)).toList()
                )
              ),
              ...children
            ],
          ),
        );
    });
  }
}

class PropertyItem extends StatelessWidget {
  final String name;
  final Widget child;
  final bool enabled;
  const PropertyItem({required this.name, required this.child, this.enabled = true, super.key});

  @override
  Widget build(BuildContext context) {
    if (!enabled)  {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PropertyHeader(name),
          ),
          child
        ]
      ),
    );
  }
}

class PropertyHeader extends StatelessWidget {
  final String text;
  const PropertyHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
    ));
  }

}

class PropertyValue  extends StatelessWidget {
  final String text;
  const PropertyValue(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: textColor),
          borderRadius: BorderRadius.circular(4.0),
          color: intelGrayReallyDark,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          child: Text(text, style: const TextStyle(
              fontSize: 12,
          )),
        )
      ),
    );
  }
}
