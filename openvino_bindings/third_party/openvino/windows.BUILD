package(
    default_visibility = ["//visibility:public"],
)

filegroup(
    name = "cache",
    srcs = [
         "/lib/intel64/Release/cache.json",
    ],
)

cc_library(
    name = "openvino_old_headers",
    hdrs = glob([
        "include/ie/**/*.*"
    ]),
    strip_include_prefix = "include/ie",
    visibility = ["//visibility:public"],
)

cc_library(
    name = "openvino_new_headers",
    hdrs = glob([
        "include/openvino/**/*.*"
    ]),
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
    deps = [
        ":openvino_old_headers",
    ]
)

cc_library(
    name = "ngraph",
    hdrs = glob([
        "include/ngraph/**/*.*"
    ]),
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)

config_setting(
    name = "opt_build",
    values = {"compilation_mode": "opt"},
)

config_setting(
    name = "dbg_build",
    values = {"compilation_mode": "dbg"},
)

cc_library(
    name = "openvino",
    srcs = select({
        ":opt_build": glob([
            "3rdparty/tbb/lib/tbb12.lib",
            "3rdparty/tbb/bin/tbb12.dll",

            "lib/intel64/Release/*.lib",
            "bin/intel64/Release/*.dll"
        ]),
        ":dbg_build": glob([
            "3rdparty/tbb/lib/tbb12_debug.lib",
            "3rdparty/tbb/bin/tbb12_debug.dll",

            "lib/intel64/Release/*.lib",
            "bin/intel64/Release/*.dll"
        ]),
    }),
    strip_include_prefix = "include/ie",
    visibility = ["//visibility:public"],
    data = [
        ":cache",
    ],
    deps = [
        ":ngraph",
        ":openvino_new_headers",
    ],
)
