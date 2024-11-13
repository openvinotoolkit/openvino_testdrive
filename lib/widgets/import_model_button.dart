import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/widgets/controls/filled_dropdown_button.dart';

class ImportModelButton extends StatelessWidget {
  const ImportModelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledDropDownButton(
      title: const Text('Import model'),
      items: [
        MenuFlyoutItem(text: const Text('Hugging Face'), onPressed: () { GoRouter.of(context).push('/models/import'); }),
        MenuFlyoutItem(text: const Text('Local disk'), onPressed: () {}),
      ]
    );
  }
}
