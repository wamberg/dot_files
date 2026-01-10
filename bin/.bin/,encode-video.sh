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
    echo '       [subtitle file path]: (Optional) Path to external subtitle file (overrides auto-detection)'
    echo ''
    echo 'Subtitles: English text subtitles are automatically detected and copied from the input.'
    echo '           Bitmap subtitles (PGS, VobSub) are not supported in MP4 and will be skipped.'
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

# Subtitle detection (only if no external subtitle file provided)
sub_stream_index=""
sub_map_args=""
sub_codec_args=""

if [[ -z "$subtitle_path" ]]; then
  # Probe for subtitle streams: index, codec, language
  subtitle_info=$(ffprobe -v error -select_streams s \
    -show_entries stream=index,codec_name:stream_tags=language \
    -of csv=p=0 "$input_path" 2>/dev/null || true)

  # Text-based subtitle codecs (compatible with MP4/mov_text)
  text_codecs="subrip|ass|ssa|mov_text|webvtt|srt"
  # Bitmap subtitle codecs (incompatible with MP4)
  bitmap_codecs="hdmv_pgs_subtitle|dvd_subtitle|dvb_subtitle|pgssub"

  found_bitmap=false

  while IFS=',' read -r idx codec lang; do
    [[ -z "$idx" ]] && continue

    # Check if English (eng, en, or empty/undefined which we'll treat as potentially English)
    if [[ "$lang" == "eng" || "$lang" == "en" || -z "$lang" ]]; then
      if [[ "$codec" =~ ^($text_codecs)$ ]]; then
        # Found a text-based English subtitle
        sub_stream_index="$idx"
        echo "Found English text subtitle (stream $idx, codec: $codec)"
        break
      elif [[ "$codec" =~ ^($bitmap_codecs)$ ]]; then
        found_bitmap=true
      fi
    fi
  done <<< "$subtitle_info"

  if [[ -n "$sub_stream_index" ]]; then
    # Use absolute stream index (0:INDEX) not subtitle-relative (0:s:INDEX)
    sub_map_args="-map 0:${sub_stream_index}"
    sub_codec_args="-c:s mov_text -metadata:s:s:0 language=eng"
  elif [[ "$found_bitmap" == true ]]; then
    echo "Warning: Found bitmap subtitles (PGS/VobSub) but these are incompatible with MP4."
    echo "         Subtitles will be skipped. Use MKV or burn-in for bitmap subtitles."
  fi
fi

# Build the ffmpeg command
if [[ "$use_gpu" == true ]]; then
  # GPU encoding using VAAPI (AMD)
  cmd="ffmpeg -vaapi_device /dev/dri/renderD128 -i \"${input_path}\""

  if [[ -n "$subtitle_path" ]]; then
    # External subtitle file provided
    cmd+=" -i \"${subtitle_path}\""
    cmd+=" -map 0:v:0 -map 0:a:0 -map 1:s:0"
    cmd+=" -c:s mov_text -metadata:s:s:0 language=eng"
  elif [[ -n "$sub_stream_index" ]]; then
    # Embedded subtitle detected
    cmd+=" -map 0:v:0 -map 0:a:0 ${sub_map_args}"
    cmd+=" ${sub_codec_args}"
  else
    # No subtitles
    cmd+=" -map 0:v:0 -map 0:a:0"
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
    # External subtitle file provided
    cmd+=" -i \"${subtitle_path}\""
    cmd+=" -map 0:v:0 -map 0:a:0 -map 1:s:0"
    cmd+=" -c:s mov_text -metadata:s:s:0 language=eng"
  elif [[ -n "$sub_stream_index" ]]; then
    # Embedded subtitle detected
    cmd+=" -map 0:v:0 -map 0:a:0 ${sub_map_args}"
    cmd+=" ${sub_codec_args}"
  else
    # No subtitles
    cmd+=" -map 0:v:0 -map 0:a:0"
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
