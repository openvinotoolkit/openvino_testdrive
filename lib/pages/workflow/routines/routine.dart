
import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/workflow_state.dart';

enum RoutineEventType { mouseUp, mouseDown, mouseMove }

class RoutineEvent {
  final RoutineEventType eventType;
  final Offset position;
  final WorkflowState state;
  final Function repaint;
  final Function(WorkflowState) updateState;

  const RoutineEvent({
      required this.eventType,
      required this.position,
      required this.repaint,
      required this.updateState,
      required this.state,
  });
}

class Routine {
  late final StreamController<RoutineEvent> eventStream;
  Routine() {
    eventStream = StreamController<RoutineEvent>();
    handle();
  }

  void sendEvent(RoutineEvent event) {
    //print("sent event: $event");
    eventStream.add(event);
  }

  void paint(Canvas canvas, Size size) {}

  void handle() async {
    throw Exception("Unimplement routine");
  }

  void stop() {
    eventStream.close();
  }
}
