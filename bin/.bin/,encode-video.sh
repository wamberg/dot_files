#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Display help
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./encode-video.sh [--gpu] <input video path> [output dir] [subtitle file path]'
    echo '       --gpu: (Optional) Use AMD GPU hardware encoding (faster, lower quality-per-bit)'
    echo '       <input video path>: Path to the source video file'
    echo '       [output dir]: (Optional) Directory for the encoded output video'
    echo '       [subtitle file path]: (Optional) Path to the subtitle .srt file'
    exit
fi

# Check for --gpu flag
use_gpu=false
if [[ "${1-}" == "--gpu" ]]; then
  use_gpu=true
  shift
fi

# Check required argument
if [[ $# -lt 1 ]]; then
  echo "Error: Input video path is required."
  echo 'Usage: ./encode-video.sh [--gpu] <input video path> [output dir] [subtitle file path]'
  exit 1
fi

input_path="$1"
output_dir="${2-}"
subtitle_path="${3-}"

base_filename=$(basename -- "$input_path")
filename_without_ext="${base_filename%.*}"
new_filename="${filename_without_ext}.mp4"

# Determine the output file path
if [[ -z "$output_dir" ]]; then
  output_dir=$(dirname "$input_path")
fi

output_path="${output_dir}/${new_filename}"

if [[ -f "$output_path" ]]; then
  output_path="${output_dir}/${filename_without_ext}-encoded.mp4"
fi

# Build the ffmpeg command
if [[ "$use_gpu" == true ]]; then
  # GPU encoding using VAAPI (AMD)
  cmd="ffmpeg -vaapi_device /dev/dri/renderD128 -i \"${input_path}\""

  if [[ -n "$subtitle_path" ]]; then
    cmd+=" -i \"${subtitle_path}\""
    cmd+=" -c:s mov_text -metadata:s:s:0 language=eng"
  fi

  cmd+=" -vf 'format=nv12,hwupload'"
  cmd+=" -c:v hevc_vaapi -qp 25"
  cmd+=" -c:a eac3 -b:a 448k"
  cmd+=" -movflags +faststart -map_metadata -1"
  cmd+=" -f mp4 \"${output_path}\""
else
  # CPU encoding using libx265 (higher quality, slower)
  cmd="ffmpeg -i \"${input_path}\""

  if [[ -n "$subtitle_path" ]]; then
    cmd+=" -i \"${subtitle_path}\""
    cmd+=" -c:s mov_text -metadata:s:s:0 language=eng"
  fi

  cmd+=" -c:v libx265 -preset medium -crf 25 -profile:v main10 -level 5.1 -pix_fmt yuv420p10le"
  cmd+=" -x265-params 'aq-mode=3:psy-rd=1.0:rc-lookahead=32'"
  cmd+=" -c:a eac3 -b:a 448k"
  cmd+=" -movflags +faststart -map_metadata -1"
  cmd+=" -f mp4 \"${output_path}\""
fi

# Running the command
echo "Encoding the video with the following command:"
echo "$cmd"
eval "$cmd"

echo "Encoding completed: ${output_path}"
