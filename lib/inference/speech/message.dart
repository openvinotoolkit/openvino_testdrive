import 'dart:async';

class Message {
  String message;
  final Duration position;

  Message(this.message, this.position);

  List<String> get sentences {
    return message.split(". ");
  }

  static List<Message> rework(Map<int, FutureOr<String>> transcriptions, int indexDuration) {
    final indices = transcriptions.keys.toList()..sort();
    if (indices.isEmpty) {
      return [];
    }

    //final pattern = RegExp("\\. ");

    List<Message> output = [];

    var previousIndex = indices.first;
    for (int i in indices) {
      if (transcriptions[i] is Future) {
        continue;
      }

      String text = transcriptions[i] as String;

      //print("---");
      //print(transcriptions[i]);
      if (previousIndex + 1 == i) {
        //print("following...");
        if (text[0] == " " || text[0] == text[0].toUpperCase()) {
          final subsentences = text.split(". ");

          output.last.message += subsentences.first;
          output.add(Message(subsentences.sublist(1).join(". "),Duration(seconds: i * indexDuration)));
          //for (final subsentence in subsentences.sublist(1)) {
          //  output.add(Message(subsentence,Duration(seconds: i * indexDuration)));
          //}
          previousIndex = i;
          continue;
        }
      }
      output.add(Message(text, Duration(seconds: i * indexDuration)));
      //final subMessages = (transcriptions[i] as String).split(pattern);
      //for (final subMessage in subMessages) {
      //  //if (subMessage.isNotEmpty) {
      //    //print("$subMessage.");
      //  //}
      //}
      previousIndex = i;
    }
    //for (final p in output) {
    //  print(p.message);
    //}
    return output;
  }
}
