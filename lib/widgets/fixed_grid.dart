import 'package:fluent_ui/fluent_ui.dart';

class FixedGrid extends StatelessWidget {
  final double spacing;
  final double tileWidth;
  final int itemCount;
  final bool centered;
  final NullableIndexedWidgetBuilder itemBuilder;

  const FixedGrid({
      required this.tileWidth,
      required this.itemBuilder,
      this.centered = false,
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
          final double padding = (constraints.maxWidth - totalTilesWidth);

          return Padding(
            padding: centered ? EdgeInsets.symmetric(horizontal: padding / 2) : EdgeInsets.only(right: padding),
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
