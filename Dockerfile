FROM ubuntu:16.04
MAINTAINER Toshiyuki HIRANO <hiracchi@gmail.com>
RUN set -x \
  && apt-get update \
  && apt-get -y install \
    autoconf \
    automake \
    build-essential \
    cmake \
    git \
    libass-dev \
    libfreetype6-dev \
    libsdl2-dev \
    libtheora-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    mercurial \
    pkg-config \
    texinfo \
    wget \
    zlib1g-dev \
    yasm \
    libx264-dev \
    libx265-dev \
    libvpx-dev \
    libfdk-aac-dev \
    libmp3lame-dev \
    libopus-dev \
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p ~/ffmpeg_sources ~/bin

RUN set -x \
  && cd ~/ffmpeg_sources \
  && wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.bz2 \
  && tar xjvf nasm-2.13.01.tar.bz2 \
  && cd nasm-2.13.01 \
  && ./autogen.sh \
  && PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" \
  && make \
  && make install \
  && make clean

RUN set -x \
  && cd ~/ffmpeg_sources \
  && if cd x265 2> /dev/null; then hg pull && hg update; else hg clone https://bitbucket.org/multicoreware/x265; fi \
  && cd x265/build/linux \
  && PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source \
  && PATH="$HOME/bin:$PATH" make \
  && make install \
  && make clean

RUN set -x \
  && cd ~/ffmpeg_sources \
  && wget -O ffmpeg-snapshot.tar.bz2 http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 \
  && tar xjvf ffmpeg-snapshot.tar.bz2 \
  && cd ffmpeg \
  && PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --extra-libs="-lpthread -lm" \
    --bindir="$HOME/bin" \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
  && PATH="$HOME/bin:$PATH" make \
  && make install \
  && make clean
