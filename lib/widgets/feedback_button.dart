import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/elevation.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://github.com/openvinotoolkit/openvino_testdrive/issues/new');


class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Elevation(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: IconButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(electricCoral.normal),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(16.0)),
          ),
          icon: const Icon(FluentIcons.megaphone, size: 16,),
          onPressed: () async {
            if (await canLaunchUrl(_url)) {
              await launchUrl(_url);
            } else {
              throw 'Could not launch $_url';
            }
          },
        ),
      ),
    );
  }
}
