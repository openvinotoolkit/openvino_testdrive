package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "ffmpeg",
    hdrs = glob([
        "include/**/*.h",
    ]),
    srcs = glob([
        "bin/*.dll",
        "lib/*.lib",
    ]),
    includes = [
        "lib",
    ],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
