import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/widgets/elevation.dart';

class FeaturedCard extends StatelessWidget {
  final Model model;
  const FeaturedCard({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Elevation(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 4.0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: SizedBox(
          width: 220,
          height: 248,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                    width: 80,
                    height: 80,
                    child: model.thumbnail,
                    ),
                    Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: Color(0x11000000),
                    ),
                    child: Text(model.kind.toUpperCase(),
                      style: const TextStyle(
                      fontSize: 12,
                      )
                    ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                            child: Text(model.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(model.description, style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: IconButton(icon: const Icon(FluentIcons.pop_expand, size: 14), onPressed: () {}),
                      ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
