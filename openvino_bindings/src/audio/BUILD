cc_library(
    name = "speech_to_text",
    hdrs = [
         "speech_to_text.h",
    ],
    srcs = [
         "speech_to_text.cc",
    ],
    deps = [
        "//third_party:openvino",
        "//src/utils:errors",
        ":audio_grabber",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "audio_grabber",
    hdrs = [
         "audio_grabber.h",
    ],
    srcs = [
         "audio_grabber.cc",
    ],
    deps = [
        "//third_party:ffmpeg",
    ],
    visibility = ["//visibility:public"],
)
