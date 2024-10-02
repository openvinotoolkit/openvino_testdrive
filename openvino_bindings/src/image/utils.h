#ifndef UTILS_H_
#define UTILS_H_

#include "src/utils/errors.h"
#include "data_structures.h"
#include <blend2d.h>

namespace geti {

std::vector<geti::Label> get_labels_from_configuration(ov::AnyMap configuration);

BLRgba32 hex_to_color(std::string color);

const ProjectLabel &get_label_by_id(const std::string &id, const std::vector<ProjectLabel> &label_definitions);

}

#endif // UTILS_H_
