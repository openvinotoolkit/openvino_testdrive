# Description:
#   OpenCV libraries for video/image processing on MacOS

licenses(["notice"])  # BSD license

exports_files(["LICENSE"])

cc_library(
    name = "opencv",
    srcs = glob(
        [
            "lib/libopencv_*.so",
        ],
    ),
    hdrs = glob(["include/opencv4/opencv2/**/*.h*"]),
    includes = ["include/opencv4"],
    strip_include_prefix = "include/opencv4",
    linkstatic = 1,
    visibility = ["//visibility:public"],
)
