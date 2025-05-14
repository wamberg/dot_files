#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Display help
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./encode-video.sh <input video path> [output dir] [subtitle file path]'
    echo '       <input video path>: Path to the source video file'
    echo '       [output dir]: (Optional) Directory for the encoded output video'
    echo '       [subtitle file path]: (Optional) Path to the subtitle .srt file'
    exit
fi

# Check required argument
if [[ $# -lt 1 ]]; then
  echo "Error: Input video path is required."
  echo 'Usage: ./encode-video.sh <input video path> [output dir] [subtitle file path]'
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
cmd="ffmpeg -i \"${input_path}\"" # Specify the input video file path

if [[ -n "$subtitle_path" ]]; then
  cmd+=" -i \"${subtitle_path}\"" # Add the subtitle file as an input
  cmd+=" -c:s mov_text -metadata:s:s:0 language=eng" # Specify subtitle codec and metadata
fi

cmd+=" -c:v libx265 -preset fast -crf 23 -profile:v main10 -level 5.1 -pix_fmt yuv420p10le"
cmd+=" -c:a eac3 -b:a 640k"
cmd+=" -f mp4 \"${output_path}\"" # Force the output container to MP4 and set the output path

# Running the command
echo "Encoding the video with the following command:"
echo "$cmd"
eval "$cmd"

echo "Encoding completed: ${output_path}"
