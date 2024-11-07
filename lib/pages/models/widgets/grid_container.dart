import 'package:fluent_ui/fluent_ui.dart';

class GridContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final Color? color;
  const GridContainer({super.key, this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? const Color(0x80FFFFFF),
        border: const Border(
          top: BorderSide(
            color: Color(0x0D000000),
            width: 1,
          ),
          left: BorderSide(
            color: Color(0x0D000000),
            width: 1,
          ),
        )
      ),
      child: child
    );
  }

}
