cc_library(
    name = "utils",
    hdrs = [
        "utils.h",
    ],
    srcs = [
        "utils.cc",
    ],
    deps = [
        "//third_party:openvino",
        "//third_party:opencv",
        "//third_party:model_api",
        "//src/utils:errors",
        ":data_structures",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "data_structures",
    hdrs = [
        "data_structures.h",
    ],
    deps = [
        "//third_party:blend2d",
        "//third_party:openvino",
        "//third_party:opencv",
        "//third_party:model_api",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "overlay",
    hdrs = [
        "overlay.h",
    ],
    srcs = [
        "overlay.cc",
    ],
    deps = [
        "//src/utils:errors",
        ":utils",
        ":data_structures",
        "//third_party:blend2d",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "serialization",
    hdrs = [
        "json_serialization.h",
        "csv_serialization.h",
    ],
    deps = [
        ":utils",
        "@nlohmann_json//:json",
        "//third_party:opencv",
        "//third_party/cpp-base64:cpp-base64",

    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "contourer",
    hdrs = [
        "contourer.h",
    ],
    srcs = [
        "contourer.cc",
    ],
    deps = [
        "//third_party:model_api",
        ":data_structures",
    ],
    visibility = ["//visibility:public"],
)
