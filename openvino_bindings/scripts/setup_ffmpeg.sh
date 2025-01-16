#!/bin/bash
export FFMPEG_VERSION=6.1.2

echo "Installing ffmpeg from source"
rm -rf /tmp/build_ffmpeg
mkdir /tmp/build_ffmpeg
cd /tmp/build_ffmpeg
git clone https://git.ffmpeg.org/ffmpeg.git
cd ffmpeg
git checkout n$FFMPEG_VERSION
./configure --prefix=/opt/ffmpeg --disable-autodetect --enable-rpath --enable-shared --disable-swscale --disable-avfilter --disable-static --disable-doc  --install-name-dir=@rpath
make -j8
make install
rm -rf /tmp/build_ffmpeg

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      touch /etc/ld.so.conf.d/ffmpeg.conf
      bash -c  "echo /opt/ffmpeg/lib >> /etc/ld.so.conf.d/ffmpeg.conf"
      ldconfig -v
fi