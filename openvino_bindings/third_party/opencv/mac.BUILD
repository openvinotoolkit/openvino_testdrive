# Description:
#   OpenCV libraries for video/image processing on MacOS

licenses(["notice"])  # BSD license

exports_files(["LICENSE"])

cc_library(
    name = "opencv",
    srcs = glob(
        [
            "lib/libopencv_calib3d.407*.dylib",
            "lib/libopencv_ximgproc.407*.dylib",
            "lib/libopencv_features2d.407*.dylib",
            "lib/libopencv_imgproc.407*.dylib",
            "lib/libopencv_imgcodecs.407*.dylib",
            "lib/libopencv_core.407*.dylib",
            "lib/libopencv_flann.407*.dylib",
            "lib/libopencv_optflow.407*.dylib",
            "lib/libopencv_videoio.407*.dylib",
            "lib/libopencv_video.407*.dylib",
            "lib/libopencv_core.407*.dylib",
            "lib/libopencv_highgui.407*.dylib",
        ],
    ),
    hdrs = glob(["include/opencv4/opencv2/**/*.h*"]),
    includes = ["include/opencv4"],
    strip_include_prefix = "include/opencv4",
    linkstatic = 1,
    visibility = ["//visibility:public"],
)
