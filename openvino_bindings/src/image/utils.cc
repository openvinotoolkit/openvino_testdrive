#include "utils.h"


namespace geti {

std::vector<geti::Label> get_labels_from_configuration(
    ov::AnyMap configuration) {
  auto labels_iter = configuration.find("labels");
  auto label_ids_iter = configuration.find("label_ids");
  std::vector<geti::Label> labels = {};
  if (labels_iter != configuration.end() &&
      label_ids_iter != configuration.end()) {
    std::vector<std::string> label_ids =
        label_ids_iter->second.as<std::vector<std::string>>();
    std::vector<std::string> label_names =
        labels_iter->second.as<std::vector<std::string>>();
    for (size_t i = 0; i < label_ids.size(); i++) {
      if (label_names.size() > i)
        labels.push_back({label_ids[i], label_names[i]});
      else
        labels.push_back({label_ids[i], ""});
    }
  }
  return labels;
}

BLRgba32 hex_to_color(std::string color) {
  std::stringstream ss;
  color.erase(0, 1);
  unsigned int x = std::stoul("0x" + color, nullptr, 16);
  auto output = BLRgba32(
    x >> 8 | (x & 0x000000FF) << 24
  );

  auto b = output.r();
  output.setR(output.b());
  output.setB(b);
  return output;

}

const ProjectLabel &get_label_by_id(const std::string &id,
                             const std::vector<ProjectLabel> &label_definitions) {
  for (const auto &label : label_definitions) {
    if (label.id == id) {
      return label;
    }
  }
  throw api_error(OverlayLabelNotFound, id);
}


}
