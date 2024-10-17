import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/landing/model_card.dart';


class LandingPage extends StatelessWidget {
  const LandingPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: Colors.blue,
                    child: Stack(
                      alignment: Alignment.topLeft,
                      //fit: StackFit.expand,
                      children: [
                        Image.asset("images/banner.png", fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset("images/openvino_logo.svg", width: 81),
                              Text("TestDrive",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const ModelCard(),
                const ModelCard(),
                const ModelCard(),
                const ModelCard(),
                const ModelCard(),
              ],
            ),

          ],
        ),
        Text("rest of page"),
      ],
    );
  }

}
