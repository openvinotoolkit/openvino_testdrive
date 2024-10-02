#include "overlay.h"
#include "src/utils/errors.h"
#include "utils.h"


namespace geti {

double draw_label(BLContext &ctx, const BLFont& font, const BLRgba32& color, const std::string label_text, BLPoint bl) {
    //std::string label_text = label_info.name + " " + std::to_string((int) round(label.probability * 100)) + "%";
    BLGlyphBuffer buffer;
    BLFontMetrics fontMetrics = font.metrics();
    buffer.setUtf8Text(label_text.c_str(), SIZE_MAX);
    font.shape(buffer);

    BLTextMetrics metrics;
    {
      auto result = font.getTextMetrics(buffer, metrics);

      if (result != BL_SUCCESS) {
        std::string error_message = "Blend2d error: ";
        error_message += std::to_string(result);
        throw api_error(OverlayUnableToLoadFont, error_message);
      }
    }


    float padding = 4.0f;
    float height = fontMetrics.ascent + fontMetrics.descent + padding * 2;
    float width = metrics.boundingBox.x1 - metrics.boundingBox.x0 + padding * 2 ;

    if (bl.y - height < 0) {
      bl.y = height;
    }


    BLRect textArea{ bl.x - 1, bl.y - height, width , height}; //1 for border?


    ctx.setFillStyle(color);
    ctx.fillRect(textArea);

    float luminance = (0.299f*color.r() + 0.587f*color.g() + 0.114f*color.b());
    if (luminance < 128) {
      ctx.setFillStyle(BLRgba32(0xFFFFFFFF));
    } else {
      ctx.setFillStyle(BLRgba32(0xFF000000));
    }
    ctx.fillUtf8Text(BLPoint(bl.x + padding - 1, bl.y - padding - fontMetrics.descent), font, label_text.c_str());

    return textArea.w;
}

void draw_rect_prediction(BLContext &ctx, const BLFont& font, const geti::RectanglePrediction &prediction,
                     const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions) {

  BLRect rect{(double)prediction.shape.x, (double)prediction.shape.y, (double)prediction.shape.width,
              (double)prediction.shape.height};
  bool fullImageRect = ctx.targetWidth() == rect.w && ctx.targetHeight() == rect.h;
  if (fullImageRect) {
    return;
  }

  double offset = 0.0;
  const auto &label_info = get_label_by_id(prediction.labels[0].label.label_id, label_definitions);

  auto fill_color = label_info.color;
  fill_color.setA(255 * drawOptions.opacity);
  ctx.setFillStyle(fill_color);
  ctx.fillRect(rect);
  auto border_color = label_info.color;
  ctx.setStrokeStyle(label_info.color);
  ctx.strokeRect(rect);
}

void draw_rect_prediction_labels(BLContext &ctx, const BLFont& font, const geti::RectanglePrediction &prediction,
                     const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions) {

  BLRect rect{(double)prediction.shape.x, (double)prediction.shape.y, (double)prediction.shape.width,
              (double)prediction.shape.height};
  double offset = 0.0;
  for (auto &label : prediction.labels) {
    const auto &label_info = get_label_by_id(label.label.label_id, label_definitions);
    std::string label_text = label_info.name + " " + std::to_string((int) round(label.probability * 100)) + "%";
    offset += draw_label(ctx, font, label_info.color, label_text, BLPoint(rect.x + offset, rect.y));
  }
}

void draw_polygon_prediction(BLContext &ctx, const BLFont& font, const geti::PolygonPrediction &prediction,
                     const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions) {
  const auto &label_info = get_label_by_id(prediction.labels[0].label.label_id, label_definitions);

  BLArrayView<BLPointI> points;
  BLPath path;
  points.reset((BLPointI*)(prediction.shape.data()), prediction.shape.size());
  path.addPolygon(points);

  auto fill_color = label_info.color;
  fill_color.setA(255 * drawOptions.opacity);
  ctx.setFillStyle(fill_color);
  ctx.setStrokeStyle(label_info.color);
  ctx.fillPath(path);
  ctx.strokePath(path);
}

void draw_polygon_prediction_labels(BLContext &ctx, const BLFont& font, const geti::PolygonPrediction &prediction,
                     const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions) {
  bool shapeDrawn = false;
  BLBox box;
  BLArrayView<BLPointI> points;
  BLPath path;
  points.reset((BLPointI*)(prediction.shape.data()), prediction.shape.size());
  path.addPolygon(points);
  path.getBoundingBox(&box);

  for (const auto& label: prediction.labels) {
    const auto &label_info = get_label_by_id(label.label.label_id, label_definitions);
    BLPoint center(box.x0 + (box.x1 - box.x0) / 2, box.y0 + (box.y1 - box.y0) / 2);
    BLPoint centerTop(center.x, box.y0 - 30);
    ctx.strokeLine(center, centerTop);

    std::string label_text = label_info.name + " " + std::to_string((int) round(label.probability * 100)) + "%";
    draw_label(ctx, font, label_info.color, label_text, centerTop);
  }
}

void draw_rotated_rect_prediction(BLContext &ctx, const BLFont& font, const geti::RotatedRectanglePrediction &prediction,
                     const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions) {
  const auto &label_info = get_label_by_id(prediction.labels[0].label.label_id, label_definitions);

  BLArrayView<BLPointI> points;
  BLPath path;
  cv::Point2f vertices[4];
  prediction.shape.points(vertices);
  path.moveTo(vertices[0].x, vertices[0].y);
  for (size_t i = 1; i < 4; i++) {
    path.lineTo(vertices[i].x, vertices[i].y);
  }

  auto fill_color = label_info.color;
  fill_color.setA(255 * drawOptions.opacity);
  ctx.setFillStyle(fill_color);
  ctx.setStrokeStyle(label_info.color);
  ctx.fillPath(path);
  ctx.strokePath(path);
}

void draw_rotated_rect_prediction_labels(BLContext &ctx, const BLFont& font, const geti::RotatedRectanglePrediction &prediction,
                     const std::vector<geti::ProjectLabel> &label_definitions, const DrawOptions &drawOptions) {
  bool shapeDrawn = false;
  BLBox box;
  BLArrayView<BLPointI> points;
  BLPath path;
  cv::Point2f vertices[4];
  prediction.shape.points(vertices);
  path.moveTo(vertices[0].x, vertices[0].y);
  for (size_t i = 1; i < 4; i++) {
    path.lineTo(vertices[i].x, vertices[i].y);
  }
  path.getBoundingBox(&box);

  for (const auto& label: prediction.labels) {
    const auto &label_info = get_label_by_id(label.label.label_id, label_definitions);
    BLPoint center(box.x0 + (box.x1 - box.x0) / 2, box.y0 + (box.y1 - box.y0) / 2);
    BLPoint centerTop(center.x, box.y0 - 30);
    ctx.strokeLine(center, centerTop);

    std::string label_text = label_info.name + " " + std::to_string((int) round(label.probability * 100)) + "%";
    draw_label(ctx, font, label_info.color, label_text, centerTop);
  }
}

cv::Mat draw_overlay(cv::Mat input_image, const geti::InferenceResult& inference_result, const DrawOptions& options, const std::vector<geti::ProjectLabel>& label_definitions, const BLFontFace& face) {
  cv::Mat cv_image;
  cv::cvtColor(input_image, cv_image, cv::COLOR_RGB2BGRA);

  BLImage img;
  img.createFromData(cv_image.cols, cv_image.rows, BLFormat::BL_FORMAT_XRGB32, cv_image.data, cv_image.step);
  BLContext ctx(img);
  ctx.setStrokeWidth(options.strokeWidth);
  BLFont font;
  int longest_side = std::max(cv_image.cols, cv_image.rows);
  font.createFromFace(face, longest_side * 0.01 * options.fontSize);

  for (auto &detection : inference_result.rectangles) {
    draw_rect_prediction(ctx, font, detection, label_definitions, options);
  }

  for (auto &polygon : inference_result.polygons) {
    draw_polygon_prediction(ctx, font, polygon, label_definitions, options);
  }

  for (auto &rotated_rect : inference_result.rotated_rectangles) {
    draw_rotated_rect_prediction(ctx, font, rotated_rect, label_definitions, options);
  }

  for (auto &polygon : inference_result.polygons) {
    draw_polygon_prediction_labels(ctx, font, polygon, label_definitions, options);
  }

  for (auto &rotated_rect : inference_result.rotated_rectangles) {
    draw_rotated_rect_prediction_labels(ctx, font, rotated_rect, label_definitions, options);
  }

  for (auto &detection : inference_result.rectangles) {
    draw_rect_prediction_labels(ctx, font, detection, label_definitions, options);
  }

  ctx.end();
  return cv_image;
}

}
