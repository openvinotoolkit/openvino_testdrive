/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef OVERLAY_H_
#define OVERLAY_H_

#include "data_structures.h"
#include <blend2d.h>

namespace geti {

struct DrawOptions {
  double strokeWidth;
  double opacity;
  double fontSize;
};


double draw_label(BLContext &ctx, const BLFont& font, const BLRgba32& color, const std::string label_text, BLPoint bl);

void draw_rect_prediction(BLContext &ctx, const BLFont& font, const geti::RectanglePrediction &prediction,
            const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions);
void draw_rect_prediction_labels(BLContext &ctx, const BLFont& font, const geti::RectanglePrediction &prediction,
            const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions);
void draw_polygon_prediction(BLContext &ctx, const BLFont& font, const geti::PolygonPrediction &prediction,
            const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions);
void draw_polygon_prediction_labels(BLContext &ctx, const BLFont& font, const geti::PolygonPrediction &prediction,
            const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions);
void draw_rotated_rect_prediction(BLContext &ctx, const BLFont& font, const geti::RotatedRectanglePrediction &prediction,
            const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions);
void draw_rotated_rect_prediction_labels(BLContext &ctx, const BLFont& font, const geti::RotatedRectanglePrediction &prediction,
            const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions);

cv::Mat draw_overlay(cv::Mat input_image, const geti::InferenceResult& inference_result, const DrawOptions& options, const std::vector<geti::ProjectLabel>& label_definitions, const BLFontFace& face);

}
#endif // OVERLAY_H_
