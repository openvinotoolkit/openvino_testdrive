/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef STATUS_H_
#define STATUS_H_

enum StatusEnum {
  OkStatus = 0,
  ErrorStatus = -1,
  OpenVINOError = -2,

  ModelTypeNotSupplied = -10,
  ModelTypeNotSupported = -11,
  TaskTypeNotSupported = -12,

  OverlayUnableToLoadFont = -20,
  OverlayLabelNotFound = -21,
  OverlayNoOutputSelected = -22,

  FontLoadError = -30,

  InferenceAnomalyLabelsIncorrect = -40,

  CameraNotOpenend = -50,

  MediapipeNextPackageFailure = -61,
  MediapipeGraphError = -62,

  LLMNoMetricsYet = -71,

  SpeechToTextError = -80,
  SpeechToTextFileNotOpened = -81,
  SpeechToTextChunkHasNoData = -82,
  SpeechToTextChunkOutOfBounds = -83,
};

#endif // STATUS_H_
