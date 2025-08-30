#!/bin/bash

model="turbo"
target_lang="Japanese"
sub_format="txt"

if [ $# -eq 0 ]; then
    echo "Error: No episode number provided."
    echo "Usage: $0 <episode_number>"
    echo "Example: $0 01"
    exit 1
fi

readonly TARGET_EPISODE="$1"

if ! command -v ffmpeg &> /dev/null; then
    echo "Could not find 'ffmpeg' command."
    exit 1
fi

BASE_DIR=$(pwd)
VIDEO_DIR="$BASE_DIR/video"
SUBTITLE_DIR="$BASE_DIR/subtitle"

episode_video_dir="$VIDEO_DIR/$TARGET_EPISODE"
episode_subtitle_dir="$SUBTITLE_DIR/$TARGET_EPISODE"

input_mp4=$(find $episode_video_dir -maxdepth 1 -name "*.mp4" -print -quit)

if [ -z "$input_mp4" ]; then
    echo "Error: No MP4 file found in '$episode_video_dir'."
    exit 1
fi

if [[ "$input_mp4" =~ ([0-9]+) ]]; then
    episode_num="${BASH_REMATCH}"
else
    echo "Error: Could not extract episode number from filename '${input_mp4}'."
    echo "Filename should contain the format 'number+episode', e.g. '...274...'"
    exit 1
fi

echo "--- Transcription ---"
echo "File: ${input_mp4}"
echo "Episode: ${episode_num}"
echo "Model: ${model}"
echo "Target Language: ${target_lang}"
echo "Output Format: ${sub_format}"
echo "Output Directory: ${episode_subtitle_dir}"
echo "--------------------------"

whisper "${input_mp4}" \
  --model "${model}" \
  --language "${target_lang}" \
  --output_format "${sub_format}" \
  --output_dir "${episode_subtitle_dir}" \
#   waiting for https://github.com/openai/whisper/pull/382
#   --device mps

echo "--- Transcription Completed ---"
