
#!/usr/bin/env bash
BUNDLE_FRAMEWORK_LIBS_SOURCE_DIR='../bindings'
BUNDLE_FRAMEWORK_LIBS_TARGET_DIR="${TARGET_BUILD_DIR}/${PRODUCT_NAME}.app/Contents/Frameworks"
BUNDLE_FRAMEWORK_LIBS=(
    "libopenvino_paddle_frontend.2460.dylib"
    "libswresample.4.dylib"
    "libopenvino_hetero_plugin.so"
    "libavutil.58.dylib"
    "libopenvino.2460.dylib"
    "libopenvino_onnx_frontend.2460.dylib"
    "libopenvino_auto_batch_plugin.so"
    "libopenvino_auto_plugin.so"
    "libblend2d.dylib"
    "libavdevice.60.dylib"
    "libopencv_core.410.dylib"
    "libopenvino_genai.2460.dylib"
    "libopenvino_arm_cpu_plugin.so"
    "libavformat.60.dylib"
    "libopencv_videoio.410.dylib"
    "libopencv_features2d.410.dylib"
    "libopenvino_pytorch_frontend.2460.dylib"
    "libopenvino_tensorflow_lite_frontend.2460.dylib"
    "libopencv_calib3d.410.dylib"
    "libopencv_flann.410.dylib"
    "libopencv_highgui.410.dylib"
    "libopenvino_tokenizers.dylib"
    "libopencv_optflow.410.dylib"
    "libopencv_imgproc.410.dylib"
    "libopencv_video.410.dylib"
    "libopencv_ximgproc.410.dylib"
    "libmacos_bindings.dylib"
    "libavcodec.60.dylib"
    "libopenvino_tensorflow_frontend.2460.dylib"
    "libtbb.12.dylib"
    "libopencv_imgcodecs.410.dylib"
    "libcore_tokenizers.dylib"
    "libopenvino_c.2460.dylib"
    "libopenvino_ir_frontend.2460.dylib"
)
BUNDLE_FRAMEWORK_LIBS_TO_SIGN=(
    "libopenvino_hetero_plugin.so"
    "libopenvino_auto_batch_plugin.so"
    "libopenvino_auto_plugin.so"
    "libblend2d.dylib"
    "libopencv_core.410.dylib"
    "libopenvino_arm_cpu_plugin.so"
    "libopencv_videoio.410.dylib"
    "libopencv_features2d.410.dylib"
    "libopencv_calib3d.410.dylib"
    "libopencv_flann.410.dylib"
    "libopencv_highgui.410.dylib"
    "libopencv_optflow.410.dylib"
    "libopencv_imgproc.410.dylib"
    "libopencv_video.410.dylib"
    "libopencv_ximgproc.410.dylib"
    "libmacos_bindings.dylib"
    "libtbb.12.dylib"
    "libopencv_imgcodecs.410.dylib"
    "libcore_tokenizers.dylib"
)

# Copy the libraries to the app bundle
if [ -z "${FLUTTER_NOT_BUNDLE_LIBRARIES}" ]; then
    for lib in "${BUNDLE_FRAMEWORK_LIBS[@]}"; do
        rsync -av "${BUNDLE_FRAMEWORK_LIBS_SOURCE_DIR}/${lib}" "${BUNDLE_FRAMEWORK_LIBS_TARGET_DIR}"
    done
fi

# Sign the libraries
if [[ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" ]]; then
    for lib in "${BUNDLE_FRAMEWORK_LIBS_TO_SIGN[@]}"; do
        codesign --force --verbose --sign "${EXPANDED_CODE_SIGN_IDENTITY}" -- "${BUNDLE_FRAMEWORK_LIBS_TARGET_DIR}/${lib}"
    done
fi
