// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';

class EmptyModelListWidget extends StatelessWidget {
  final String? searchQuery;
  const EmptyModelListWidget({super.key, this.searchQuery});

  String get header {
    if (searchQuery == null || searchQuery == "") {
      return "No models";
    } else {
      return "No results found";
    }
  }

  String get reason {
    if (searchQuery == null || searchQuery == "") {
      return "Click 'import model' to download a model";
    } else {
      return "We couldn't find a match for \"$searchQuery\"\n Please try another search";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        children: [
          SvgPicture.asset('images/slide_search.svg'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              header,
              style: const TextStyle(fontSize: 20)),
          ),
          Text(reason, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
