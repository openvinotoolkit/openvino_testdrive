#!/bin/bash
export OPENCV_VERSION=4.10.0

echo "Installing OpenCV from source"
rm -rf /tmp/build_opencv
mkdir /tmp/build_opencv
cd /tmp/build_opencv
#git clone https://github.com/opencv/opencv_contrib.git
git clone https://github.com/opencv/opencv.git
mkdir opencv/release
#cd opencv_contrib
#git checkout tags/$OPENCV_VERSION
cd opencv
git checkout tags/$OPENCV_VERSION

# Remove requiring ORBEC_SDK for macOS
# It should be fixed with update to OpenCV 4.11.0
sed -i '/if(APPLE)/,/endif()/d' modules/videoio/cmake/detect_obsensor.cmake

cd release
# -DOPENCV_EXTRA_MODULES_PATH=/tmp/build_opencv/opencv_contrib/modules \
cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DBUILD_LIST=core,improc,imgcodecs,calib3d,features2d,highgui,imgproc,video,videoio,optflow \
      -DBUILD_TESTS=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DBUILD_opencv_ts=OFF \
      -DBUILD_opencv_aruco=OFF \
      -DBUILD_opencv_bgsegm=OFF \
      -DBUILD_opencv_bioinspired=OFF \
      -DBUILD_opencv_ccalib=OFF \
      -DBUILD_opencv_datasets=OFF \
      -DBUILD_opencv_dnn=OFF \
      -DBUILD_opencv_dnn_objdetect=OFF \
      -DBUILD_opencv_dpm=OFF \
      -DBUILD_opencv_face=OFF \
      -DBUILD_opencv_fuzzy=OFF \
      -DBUILD_opencv_hfs=OFF \
      -DBUILD_opencv_img_hash=OFF \
      -DBUILD_opencv_js=OFF \
      -DBUILD_opencv_line_descriptor=OFF \
      -DBUILD_opencv_phase_unwrapping=OFF \
      -DBUILD_opencv_plot=OFF \
      -DBUILD_opencv_quality=OFF \
      -DBUILD_opencv_reg=OFF \
      -DBUILD_opencv_rgbd=OFF \
      -DBUILD_opencv_saliency=OFF \
      -DBUILD_opencv_shape=OFF \
      -DBUILD_opencv_structured_light=OFF \
      -DBUILD_opencv_surface_matching=OFF \
      -DBUILD_opencv_world=OFF \
      -DBUILD_opencv_xobjdetect=OFF \
      -DBUILD_opencv_xphoto=OFF \
      -DCV_ENABLE_INTRINSICS=ON \
      -DWITH_EIGEN=ON \
      -DWITH_PTHREADS=ON \
      -DWITH_PTHREADS_PF=ON \
      -DWITH_JPEG=ON \
      -DWITH_PNG=ON \
      -DWITH_TIFF=ON \
      -DOBSENSOR_USE_ORBBEC_SDK=OFF
make -j `nproc`
make install
rm -rf /tmp/build_opencv
echo "OpenCV has been built. You can find the header files and libraries in /usr/local/include/opencv2/ and /usr/local/lib"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # https://github.com/cggos/dip_cvqt/issues/1#issuecomment-284103343
      touch /etc/ld.so.conf.d/mp_opencv.conf
      bash -c  "echo /usr/local/lib >> /etc/ld.so.conf.d/mp_opencv.conf"
      ldconfig -v
fi
