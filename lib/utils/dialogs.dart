import 'package:go_router/go_router.dart';
import 'package:fluent_ui/fluent_ui.dart';

void errorDialog(BuildContext context, String title, String content) {
  showDialog(context: context, builder: (BuildContext context) => ContentDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        Button(
          onPressed: () => context.go('/'),
          child: const Text('Close'),
        ),
      ]
    )
  );
}

void exceptionDialog(BuildContext context, String content) {
  showDialog(context: context, builder: (BuildContext context) => ContentDialog(
      title: const Text("An exception occured."),
      content: Text(content),
      actions: <Widget>[
        Button(
          onPressed: () => context.go('/'),
          child: const Text('Close'),
        ),
      ]
    )
  );
}

Function onExceptionDialog(BuildContext context) {
  return (dynamic content) {
    if (context.mounted) {
      exceptionDialog(context, content);
    }
  };
}
