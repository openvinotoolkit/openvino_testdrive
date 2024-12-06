#!/bin/bash
export FFMPEG_VERSION=6.1.2

echo "Installing ffmpeg from source"
rm -rf /tmp/build_ffmpeg
mkdir /tmp/build_ffmpeg
cd /tmp/build_ffmpeg
curl -L https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.xz --output ffmpeg.tar.xz
tar -xJf ffmpeg.tar.xz
cd ./ffmpeg-$FFMPEG_VERSION
./configure --enable-shared --prefix=/usr
make -j8
make install
rm -rf /tmp/build_ffmpeg