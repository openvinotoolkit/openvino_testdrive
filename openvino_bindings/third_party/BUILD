package(default_visibility = ["//visibility:public"])

alias(
    name = "openvino",
    actual = select({
        "@bazel_tools//src/conditions:windows": "@openvino_windows//:openvino",
        "@bazel_tools//src/conditions:darwin_arm64": "@openvino_mac//:openvino",
        "//conditions:default": "@openvino_linux//:openvino",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "podofo",
    actual = select({
        "@bazel_tools//src/conditions:windows": "@podofo_windows//:podofo_windows",
        "@bazel_tools//src/conditions:darwin_arm64": "@podofo//:podofo_mac",
    }),
    visibility = ["//visibility:public"],
)


alias(
    name = "model_api_cmake",
    actual = select({
        "@bazel_tools//src/conditions:windows": "@model_api//:model_api_cmake_windows",
        "@bazel_tools//src/conditions:darwin_arm64": "@model_api//:model_api_cmake_mac",
        "//conditions:default": "@model_api//:model_api_cmake_linux",
    }),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "model_api",
    deps = [
        ":opencv",
        ":openvino",
        ":model_api_cmake",
    ],
    visibility = ["//visibility:public"],
)

alias(
    name = "ffmpeg",
    actual = select({
        "@bazel_tools//src/conditions:windows": "@windows_ffmpeg//:ffmpeg",
        "@bazel_tools//src/conditions:darwin_arm64": "@mac_ffmpeg//:ffmpeg",
        "//conditions:default": "@linux_ffmpeg//:ffmpeg",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "opencv",
    actual = select({
        "@bazel_tools//src/conditions:windows": "@opencv_windows//:opencv",
        "@bazel_tools//src/conditions:darwin_arm64": "@opencv_mac//:opencv",
        "//conditions:default": "@opencv_linux//:opencv",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "blend2d",
    actual = select({
        "@bazel_tools//src/conditions:windows": "@blend2d//:blend2d_windows",
        "@bazel_tools//src/conditions:darwin_arm64": "@blend2d//:blend2d_macos",
        "//conditions:default": "@blend2d//:blend2d_linux",
    }),
    visibility = ["//visibility:public"],
)
