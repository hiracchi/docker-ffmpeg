FROM ubuntu:16.04 as builder
MAINTAINER Toshiyuki HIRANO <hiracchi@gmail.com>

ARG FFMPEG_VER=n3.4.1
ARG FFMPEG_PREFIX=/opt/ffmpeg

RUN set -x \
  && apt-get update \
  && apt-get -y install \
    autoconf \
    automake \
    build-essential \
    cmake \
    git \
    mercurial \
    pkg-config \
    texinfo \
    wget \
    nasm \
    yasm \
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
    zlib1g-dev \
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
  && wget "https://github.com/FFmpeg/FFmpeg/archive/${FFMPEG_VER}.tar.gz" \
  && tar xzvf ${FFMPEG_VER}.tar.gz \
  && cd FFmpeg-${FFMPEG_VER} \
  && PATH="${FFMPEG_PREFIX}/bin:$PATH" PKG_CONFIG_PATH="${FFMPEG_PREFIX}/lib/pkgconfig" ./configure \
    --prefix="${FFMPEG_PREFIX}" \
    --enable-static --disable-shared --disable-debug \
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
  && PATH="${FFMPEG_PREFIX}/bin:$PATH" make \
  && make install \
  && make clean


# ==============================================================================
# Runtime image
# ==============================================================================
FROM ubuntu:16.04

RUN set -x \
  && apt-get update \
  && apt-get -y install \
    vainfo i965-va-driver \
    libass5 \
    libfreetype6 \
    libsdl2-2.0-0 \
    libtheora0 \
    libva1 libva-drm1 libva-x11-1 \
    libvdpau1 \
    libvorbis0a libvorbisenc2 libvorbisfile3 \
    libxcb1 libxcb-shape0 libxcb-shm0 libxcb-xfixes0 \
    zlib1g \
    libx264-148 \
    libx265-79 \
    libvpx3 \
    libfdk-aac0 \
    libmp3lame0 \
    libopus0 \
    libxv1 \
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

COPY  --from=builder /opt/ffmpeg /opt/ffmpeg

# ref. https://www.jifu-labo.net/2017/02/h264_encode/
COPY files/ts2mp4_hwenc.sh /usr/local/bin/
COPY files/ts2enc.ffpreset /usr/local/etc/
RUN set -x \
  && chmod +x /usr/local/bin/ts2mp4_hwenc.sh \
  && rm -rf /tmp/*

# ENTRYPOINT ["/docker-entrypoint.sh"]
