package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "ffmpeg",
    hdrs = glob([
        "include/libavcodec/*.h",
        "include/libavutil/*.h",
        "include/libavformat/*.h",
        "include/libavfilter/*.h",
        "include/libswscale/*.h",
        "include/libswresample/*.h",
    ]),
    srcs = glob([
        "bin/avcodec-60.dll",
        "bin/avutil-58.dll",
        "bin/avformat-60.dll",
        "bin/avfilter-9.dll",
        "bin/swscale-7.dll",
        "bin/swresample-4.dll",
        "lib/*.lib",
    ]),
    includes = [
        "lib",
    ],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
