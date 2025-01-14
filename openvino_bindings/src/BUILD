load(":windows_dll_library.bzl", "windows_dll_library")

cc_library(
    name = "bindings_deps",
    deps = [
        "@nlohmann_json//:json",
        "//third_party:opencv",
        "//third_party:ffmpeg",
        "//src/utils:status",
        "//src/utils:utils",
        "//src/image:image_inference",
        "//src/llm:llm_inference",
        "//src/audio:speech_to_text",
        "//src/mediapipe:graph_runner",
        "//src/tti:tti_inference",
    ],
)

cc_library(
    name = "bindings",
    hdrs = ["bindings.h"],
    srcs = ["bindings.cc"],
    deps = [
        ":bindings_deps",
        "//src/utils:metrics",
        "//src/utils:tti_metrics",
    ],
    copts = ["-fPIC"],
    alwayslink=1,
    linkopts = ["-Wl,-rpath,$$ORIGIN"],
)

cc_binary(
    name = "macos_bindings",
    deps = [
        ":bindings",
    ],
    linkshared=1,
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "linux_bindings",
    deps = [
        ":bindings",
    ],
    linkshared=1,
    visibility = ["//visibility:public"],
)

cc_test(
    name = "bindings_test",
    srcs = [
        "bindings_test.cc",
    ],
    deps = [
        "@gtest//:gtest_main",
        ":bindings",
    ],
    data = [
        "//data:models",
    ]
)

windows_dll_library(
    name = "windows_bindings",
    hdrs = ["bindings.h"],
    srcs = ["bindings.cc"],
    deps = [
        ":bindings_deps",
    ],
    copts = ["/DCOMPILING_DLL"],
    target_compatible_with = ["@platforms//os:windows"],
    visibility = ["//visibility:public"],
)
