import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

void errorDialog(BuildContext context, String title, String content) {
  showDialog(context: context, builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('Close'),
        ),
      ]
    )
  );
}

void exceptionDialog(BuildContext context, String content) {
  showDialog(context: context, builder: (BuildContext context) => AlertDialog(
      title: const Text("An exception occured."),
      content: Text(content),
      actions: <Widget>[
        TextButton(
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
