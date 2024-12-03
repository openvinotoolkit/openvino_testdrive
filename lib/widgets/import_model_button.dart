import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/widgets/controls/filled_dropdown_button.dart';
import 'package:provider/provider.dart';

import '../importers/importer.dart';
import '../providers/project_provider.dart';

class ImportModelButton extends StatelessWidget {
  const ImportModelButton({super.key});


  void addProject(BuildContext context) async {

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      for (final file in result.files) {
        final importer = selectMatchingImporter(file.path!);
        if (importer == null) {
          print("unable to process file");
          return;
        }
        if (context.mounted) {
          if (!await importer.askUser(context)) {
            print("cancelling due to user input");
            return;
          }
        }
        importer.generateProject().then((project) async {
          await importer.setupFiles();
          project.loaded.future.then((_) {
            if (context.mounted) {
              Provider.of<ProjectProvider>(context, listen: false)
                  .completeLoading(project);
            }
          });
          if (context.mounted) {
            final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
            projectsProvider.addProject(project);
          }
        });
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledDropDownButton(
      title: const Text('Import model'),
      items: [
        MenuFlyoutItem(text: const Text('Hugging Face'), onPressed: () { GoRouter.of(context).go('/models/import'); }),
        MenuFlyoutItem(text: const Text('Local disk'), onPressed: () { addProject(context); }),
      ]
    );
  }
}
