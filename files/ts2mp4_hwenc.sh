#!/bin/bash

FFMPEG=/opt/ffmpeg/bin/ffmpeg

INPUT_FILE=${1}
OUTPUT_FILE=${2}
if [ x${OUTPUT_FILE} = x ]; then
    BASE_NAME=${INPUT_FILE%%*/}
    EXT=${INPUT_FILE##*.}
    BASE_NAME=`basename ${INPUT_FILE} ${EXT}`
    OUTPUT_FILE=${BASE_NAME}mp4
fi

A_BITRATE="192k"
#A_CODEC="copy"
A_CODEC="libfdk_aac -ac 2 -ar 48000 -ab ${A_BITRATE}"

${FFMPEG} \
    -vaapi_device /dev/dri/renderD128 \
    -hwaccel vaapi -hwaccel_output_format vaapi \
    -i "${INPUT_FILE}" \
    -vf 'format=nv12|vaapi,hwupload,scale_vaapi=w=1280:h=720' \
    -c:v h264_vaapi -profile 100 -level 40 -qp 23 -aspect 16:9 \
    -c:a ${A_CODEC} \
    "${OUTPUT_FILE}"
