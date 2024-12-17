/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef CSV_SERIALIZATION_H_
#define CSV_SERIALIZATION_H_

#include "data_structures.h"
#include <clocale>
#include <string>
#include <vector>

#include <clocale>
#include <string>
#include <vector>

namespace geti {

inline std::string join(const std::vector<std::string>& list, const std::string delim = ",") {
    if (list.size() == 0){
        return "";
    }
    std::string result = list[0];
    for (size_t i = 1; i < list.size(); i++) {
        result += delim + list[i];
    }
    return result;
}

inline std::vector<std::string> to_csv(const RectanglePrediction& prediction) {
    std::vector<std::string> rows = {};

    for (auto& label: prediction.labels) {
        std::stringstream ss;
        ss << label.label.label << ","
           << label.label.label_id << ","
           << label.probability << ","
           << "rectangle" << ","
           << prediction.shape.x << ","
           << prediction.shape.y << ","
           << prediction.shape.width << ","
           << prediction.shape.height << ","
           << prediction.shape.area() << ","
           << "0";
        rows.push_back(ss.str());
    }

    return rows;
}

inline std::vector<std::string> to_csv(const RotatedRectanglePrediction& prediction) {
    std::vector<std::string> rows = {};

    for (auto& label: prediction.labels) {
        std::stringstream ss;
        ss << label.label.label << ","
           << label.label.label_id << ","
           << label.probability << ","
           << "rotated_rectangle" << ","
           << (int)prediction.shape.center.x << ","
           << (int)prediction.shape.center.y << ","
           << (int)prediction.shape.size.width << ","
           << (int)prediction.shape.size.height << ","
           << (int)prediction.shape.size.area() << ","
           << (int)prediction.shape.angle;
        rows.push_back(ss.str());
    }

    return rows;
}

inline std::vector<std::string> to_csv(const PolygonPrediction& prediction) {
    std::vector<std::string> rows = {};

    for (auto& label: prediction.labels) {
        std::stringstream ss;
        ss << label.label.label << ","
           << label.label.label_id << ","
           << label.probability << ","
           << "polygon" << ","
           << prediction.boundingBox.x << ","
           << prediction.boundingBox.y << ","
           << prediction.boundingBox.width << ","
           << prediction.boundingBox.height << ","
           << (int)prediction.area << ","
           << "0";

        rows.push_back(ss.str());
    }

    return rows;
}

inline std::string csv_serialize(const InferenceResult& inferenceResult) {
    std::vector<std::string> rows = {};

    for (auto& rectangle: inferenceResult.rectangles ){
        auto output = to_csv(rectangle);
        rows.insert(rows.end(), output.begin(), output.end());
    }

    for (auto& rectangle: inferenceResult.rotated_rectangles ){
        auto output = to_csv(rectangle);
        rows.insert(rows.end(), output.begin(), output.end());
    }

    for (auto& polygons: inferenceResult.polygons ){
        auto output = to_csv(polygons);
        rows.insert(rows.end(), output.begin(), output.end());
    }

    return join(rows, "\r\n");
}

}

#endif // CSV_SERIALIZATION_H_
