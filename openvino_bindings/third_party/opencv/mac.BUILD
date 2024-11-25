# Description:
#   OpenCV libraries for video/image processing on MacOS

licenses(["notice"])  # BSD license

exports_files(["LICENSE"])

cc_library(
    name = "opencv",
    srcs = glob(
        [
            "lib/libopencv_calib3d.410*.dylib",
            "lib/libopencv_ximgproc.410*.dylib",
            "lib/libopencv_features2d.410*.dylib",
            "lib/libopencv_imgproc.410*.dylib",
            "lib/libopencv_imgcodecs.410*.dylib",
            "lib/libopencv_core.410*.dylib",
            "lib/libopencv_flann.410*.dylib",
            "lib/libopencv_optflow.410*.dylib",
            "lib/libopencv_videoio.410*.dylib",
            "lib/libopencv_video.410*.dylib",
            "lib/libopencv_core.410*.dylib",
            "lib/libopencv_highgui.410*.dylib",
        ],
    ),
    hdrs = glob(["include/opencv4/opencv2/**/*.h*"]),
    includes = ["include/opencv4"],
    strip_include_prefix = "include/opencv4",
    linkstatic = 1,
    visibility = ["//visibility:public"],
)
