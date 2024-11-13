import 'package:fluent_ui/fluent_ui.dart';

class FixedGrid extends StatelessWidget {
  final double spacing;
  final double tileWidth;
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  const FixedGrid({
      required this.tileWidth,
      required this.itemBuilder,
      this.spacing = 0,
      this.itemCount = 0,
      super.key,
  });

  @override
  Widget build(BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final int columns = ((constraints.maxWidth + spacing) / (tileWidth + spacing)).floor();
          final double totalTilesWidth = columns * tileWidth + (columns - 1) * spacing;
          final double sidePadding = (constraints.maxWidth - totalTilesWidth);

          return Padding(
            padding: EdgeInsets.only(right: sidePadding),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 10/13
              ),
              shrinkWrap: true,
              itemCount: itemCount,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: itemBuilder,
            ),
          );
        }
      );
  }

}
