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
        "bin/avcodec-61.dll",
        "bin/avutil-59.dll",
        "bin/avformat-61.dll",
        "bin/avfilter-10.dll",
        "bin/swscale-8.dll",
        "bin/swresample-5.dll",
        "lib/*.lib",
    ]),
    includes = [
        "lib",
    ],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
