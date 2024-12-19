// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/widgets/elevation.dart';

class FeaturedCard extends StatelessWidget {
  final Model model;
  final void Function(Model) onDownload;
  final void Function(Model) onOpen;
  final bool downloaded;

  const FeaturedCard(
      {required this.model,
      required this.onDownload,
      required this.onOpen,
      required this.downloaded,
      super.key});

  void modelClick(BuildContext context) {
    if (!context.mounted) return;

    !downloaded ? onDownload(model) : onOpen(model);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Elevation(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 4.0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: SizedBox(
          width: 220,
          height: 248,
          child: GestureDetector(
            // Make the entire MouseRegion clickable
            onTap: () => modelClick(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: model.thumbnail,
                        ),
                        IntrinsicWidth(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: Color(0x11000000),
                            ),
                            constraints: const BoxConstraints(
                              maxWidth:
                                  130, // Set a maximum width for the text to wrap
                            ),
                            child: Text(
                              model.kind.toUpperCase().replaceAll(" ", "\n"),
                              // I don't like this, but when automatically wrapping applies line break, the padding is not correct.
                              softWrap: true,
                              textAlign: TextAlign.end,
                              // Adjust alignment as needed
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              maxLines:
                                  null, // Allow unlimited lines for wrapping
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 12),
                                  child: Text(model.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(model.description,
                                      style: const TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, left: 10),
                                child: Icon(
                                    downloaded
                                        ? FluentIcons.pop_expand
                                        : FluentIcons.cloud_download,
                                    size: 14),
                              ),
                            )
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
