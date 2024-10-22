import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';

class ModelCard extends StatelessWidget {
  final Model model;
  const ModelCard({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 2,
          ),
        ],
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
                child: Image.asset("images/model_thumbnails/notus.png", fit: BoxFit.cover)
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
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(model.name,
                style: const TextStyle(
                fontSize: 24,
                )
              ),
              ),
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(model.description),
              ),
              Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: IconButton(icon: const Icon(FluentIcons.pop_expand), onPressed: () {}),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
