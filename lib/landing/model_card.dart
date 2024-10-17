import 'package:fluent_ui/fluent_ui.dart';

class ModelCard extends StatelessWidget {
  const ModelCard({super.key});

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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: const Color(0x11000000),
                    ),
                    child: Text("LLM",
                      style: const TextStyle(
                        fontSize: 12,
                      )
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("Phi-3 model",
                  style: const TextStyle(
                    fontSize: 24,
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
