// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/pages/transcription/utils/message.dart';
import 'package:inference/pages/transcription/utils/section.dart';
import 'package:inference/pages/transcription/widgets/paragraph.dart';
import 'package:inference/widgets/controls/search_bar.dart';


class Transcription extends StatefulWidget {
  final DynamicRangeLoading<FutureOr<TranscriptionModelResponse>>? transcription;
  final Function(Duration)? onSeek;
  final List<Message> messages;
  const Transcription({super.key, this.onSeek, this.transcription, required this.messages});

  @override
  State<Transcription> createState() => _TranscriptionState();
}

class _TranscriptionState extends State<Transcription> {
  final List<GlobalKey> _paragraphKeys = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey scrollKey = GlobalKey();
  String? searchText;

  void saveTranscript() async {
    final file = await FilePicker.platform.saveFile(
      dialogTitle: "Please select an output file:",
      fileName: "transcription.txt",
    );
    if (file == null){
      return;
    }

    String contents = "";
    final indices = widget.transcription!.data.keys.toList()..sort();
    for (int i in indices) {
      final part = widget.transcription!.data[i] as TranscriptionModelResponse;
      for (final chunk in part.chunks) {
        contents += chunk.text;
      }
    }

    await File(file).writeAsString(contents);
  }

  void search(String text) {
     setState(() {
         searchText = text;
     });

    final pattern = RegExp(text, caseSensitive: false);
    int? index;
    for (int i = 0; i < widget.messages.length; i++) {
      if (widget.messages[i].message.contains(pattern)) {
        index = i;
        break;
      }

    }
    if (index != null){
      final context = _paragraphKeys[index].currentContext;

      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero, ancestor: scrollKey.currentContext?.findRenderObject());
          final offset = _scrollController.offset + position.dy;
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 14),
          child: Row(
            children: [
              SearchBar(onChange: search, placeholder: "Search in transcript",),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Tooltip(
                  message: widget.transcription!.complete
                    ? "Download transcript"
                    : "Transcribing...",
                  child: Button(
                    onPressed: widget.transcription?.complete ?? false
                      ? () => saveTranscript()
                      : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Icon(FluentIcons.download),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            key: scrollKey,
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.messages.length, (index) {
                    // Adjusting state in render is ugly. But works.
                    // This is done because we need a global key but the paragraphs are added as you go.
                    if (_paragraphKeys.length <= index) {
                      _paragraphKeys.add(GlobalKey());
                    }

                    return Paragraph(
                      key: _paragraphKeys[index],
                      message: widget.messages[index],
                      highlightedText: searchText,
                      onSeek: widget.onSeek,
                    );

                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
