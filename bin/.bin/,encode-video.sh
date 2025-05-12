#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Display help
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./encode-video.sh <input video path> [subtitle file path] [output file path]'
    echo '       <input video path>: Path to the source video file'
    echo '       [subtitle file path]: (Optional) Path to the subtitle .srt file'
    echo '       [output file path]: (Optional) Desired path for the encoded output video'
    exit
fi

# Check required argument
if [[ $# -lt 1 ]]; then
  echo "Error: Input video path is required."
  echo 'Usage: ./encode-video.sh <input video path> [subtitle file path] [output file path]'
  exit 1
fi

input_path="$1"
subtitle_path="${2-}"
output_path="${3-}"

# Determine the output file path
if [[ -z "$output_path" ]]; then
  output_dir=$(dirname "$input_path")
  output_path="${output_dir}/$(basename "$input_path" | sed 's/\.[^.]*$//')-encoded.mp4"
elif [[ "$output_path" == "$input_path" ]]; then
  output_path="$(dirname "$input_path")/$(basename "$input_path" | sed 's/\.[^.]*$/-encoded.mp4/')"
fi

# Build the ffmpeg command
cmd="ffmpeg -i \"$input_path\"" # Specify the input video file path

if [[ -n "$subtitle_path" ]]; then
  cmd+=" -i \"$subtitle_path\"" # Add the subtitle file as an input
  cmd+=" -c:s mov_text -metadata:s:s:0 language=eng" # Specify subtitle codec and metadata
fi

# Video codec options
cmd+=" -c:v libx265 -preset fast -crf 23 -profile:v main10 -level 5.1 -pix_fmt yuv420p10le"
# -c:v libx265: Use the x265 encoder (HEVC)
# -preset fast: Fast processing with a reasonable output file size
# -crf 23: Constant rate factor, a balance between quality and file size
# -profile:v main10: Main 10 profile for 10-bit color depth
# -level 5.1: Specifies encoder level to support higher resolutions and frame rates
# -pix_fmt yuv420p10le: Pixel format offering 10-bit color depth and chroma subsampling

# Audio encoding options
cmd+=" -c:a eac3 -b:a 640k" # Encode audio using EAC3 codec with 640 kbps bitrate

# Output file format settings
cmd+=" -f mp4 \"$output_path\"" # Force the output container to MP4 and set the output path

# Running the command
echo "Encoding the video with the following command:"
echo $cmd
eval $cmd

echo "Encoding completed: ${output_path}"
