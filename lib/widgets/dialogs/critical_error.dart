import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/utils.dart';

void showCriticalErrorDialog(dynamic e, StackTrace trace) {
  showGlobalDialog((context) => ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 756,
        maxHeight: 500,
      ),
      title: const Text("An error occured."),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(e.toString(), overflow: TextOverflow.ellipsis),
            ),
          ),
          Expander(
            header: const Text("Details"),
            content: SizedBox(
              height: 180,
              child: SingleChildScrollView(
                child: SelectableText("$e\n$trace")),
            )
          ),
        ],
      ),
      actions: <Widget>[
        Button(
          onPressed: () {
            Navigator.pop(context, true);
            //windowManager.close();
          },
          child: const Text('Close'),
        ),
      ]
    )
  );
}
