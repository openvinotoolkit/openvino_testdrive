load(":windows_dll_library.bzl", "windows_dll_library")

cc_library(
    name = "bindings_deps",
    deps = [
        "//src/audio:speech_to_text",
        "//src/image:image_inference",
        "//src/llm:llm_inference",
        "//src/mediapipe:graph_runner",
        "//src/tti:tti_inference",
        "//src/utils",
        "//src/utils:status",
        "//third_party:opencv",
        "@nlohmann_json//:json",
    ],
)

cc_library(
    name = "bindings",
    srcs = ["bindings.cc"],
    hdrs = ["bindings.h"],
    copts = ["-fPIC"],
    linkopts = ["-Wl,-rpath,$$ORIGIN"],
    deps = [
        ":bindings_deps",
        "//src/utils:metrics",
        "//src/utils:tti_metrics",
    ],
    alwayslink = 1,
)

cc_binary(
    name = "macos_bindings",
    linkshared = 1,
    visibility = ["//visibility:public"],
    deps = [
        ":bindings",
    ],
)

cc_binary(
    name = "linux_bindings",
    linkshared = 1,
    visibility = ["//visibility:public"],
    deps = [
        ":bindings",
    ],
)

cc_test(
    name = "bindings_test",
    srcs = [
        "bindings_test.cc",
    ],
    data = [
        "//data:models",
    ],
    deps = [
        ":bindings",
        "@gtest//:gtest_main",
    ],
)

windows_dll_library(
    name = "windows_bindings",
    srcs = ["bindings.cc"],
    hdrs = ["bindings.h"],
    copts = ["/DCOMPILING_DLL"],
    target_compatible_with = ["@platforms//os:windows"],
    visibility = ["//visibility:public"],
    deps = [
        ":bindings_deps",
    ],
)
