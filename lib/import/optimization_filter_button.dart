import 'package:flutter/material.dart';
import 'package:inference/providers/project_filter_provider.dart';

class OptimizationFilterButton extends StatelessWidget {

  final String name;
  final ProjectFilterProvider filter;
  const OptimizationFilterButton(this.name, this.filter, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Row(
          children: [
            Checkbox(value: filter.optimizations.contains(name), onChanged: (val) {
                if (val ?? false)  {
                  filter.addOptimization(name);
                } else {
                  filter.removeOptimization(name);
                }
            }),
            Text(name),
          ],
        ),
      ),
    );
  }
}
