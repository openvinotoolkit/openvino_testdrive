cc_library(
    name = "calculators",
    deps = [
        "@com_github_glog_glog//:glog",
        "//src/mediapipe/utils:utils",
        "//src/mediapipe/inference:inference_calculators",
        "//src/mediapipe/serialization:calculators",
    ],
)

cc_library(
    name = "graph_runner",
    hdrs = [
        "graph_runner.h",
    ],
    srcs = [
        "graph_runner.cc",
    ],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/framework/port:parse_text_proto",
        "//src/utils:errors",
        ":calculators"
    ],
    visibility = ["//visibility:public"],
)
