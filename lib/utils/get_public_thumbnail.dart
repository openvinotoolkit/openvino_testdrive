// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';

Image getThumbnail(String id) {
  final name = id.toLowerCase();

  if (name.contains("llama")) {
    return Image.asset('images/model_thumbnails/llama.jpg');
  }

  if (name.contains('mistral') || name.contains('mixstral')) {
    return Image.asset('images/model_thumbnails/mistral.png');
  }

  if (name.contains('phi')) {
    return Image.asset('images/model_thumbnails/microsoft.png');
  }

  if (name.contains('redpajama')) {
    return Image.asset('images/model_thumbnails/redpajama.png');
  }

  if (name.contains('codegen')) {
    return Image.asset('images/model_thumbnails/codegen.png');
  }

  if (name.contains('gpt') || name.contains('pythia')) { // might be too loose of a fit
    return Image.asset('images/model_thumbnails/eleuthera.jpg');
  }

  if (name.contains('starcoder2')) {
    return Image.asset('images/model_thumbnails/starcoder2.png');
  }

  if (name.contains('zephyr-7b')) {
    return Image.asset('images/model_thumbnails/zephyr7b.png');
  }

  if (name.contains('persimmon')) {
    return Image.asset('images/model_thumbnails/adeptai.png');
  }

  if (name.contains('notus')) {
    return Image.asset('images/model_thumbnails/notus.png');
  }

  if (name.contains('dolly')) {
    return Image.asset('images/model_thumbnails/dolly.png');
  }

  return Image.asset('images/model_thumbnails/generic.jpg');
}
