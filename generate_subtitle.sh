#!/bin/bash

WHISPER_CPP="/Users/shiinakin/Documents/Code/Projects/whisper.cpp"
export whisper="${WHISPER_CPP}/build/bin/whisper-cli"

model="large-v3-turbo"
target_lang="Japanese"
sub_format=("txt")  # txt srt json csv lrc

model_path="${WHISPER_CPP}/models/ggml-${model}.bin"

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
mkdir -p "$episode_subtitle_dir"
episode_subtitle_file_without_ext="${episode_subtitle_dir}/${TARGET_EPISODE}"

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
echo "Output Formats: ${sub_format[*]}"
echo "Output Directory: ${episode_subtitle_dir}"
echo "--------------------------"

# Extract audio from video using ffmpeg
audio_file="${episode_subtitle_dir}/${TARGET_EPISODE}.wav"
echo "Extracting audio to: ${audio_file}"
ffmpeg -i "${input_mp4}" -vn -acodec pcm_s16le -ar 16000 -ac 1 "${audio_file}" -y > /dev/null 2>&1

if [ ! -f "${audio_file}" ]; then
  echo "Error: Failed to extract audio from '${input_mp4}'."
  exit 1
fi

output_params=""
for format in "${sub_format[@]}"; do
    case "$format" in
        "txt")
            output_params="$output_params --output-txt"
            ;;
        "srt")
            output_params="$output_params --output-srt"
            ;;
        "json")
            output_params="$output_params --output-json-full"
            ;;
        "csv")
            output_params="$output_params --output-csv"
            ;;
        "lrc")
            output_params="$output_params --output-lrc"
            ;;
        *)
            echo "Warning: Unknown format '$format' ignored."
            ;;
    esac
done

echo "Starting transcription with Whisper..."

$whisper \
  --file "${audio_file}" \
  --model "${model_path}" \
  --language "${target_lang}" \
  $output_params \
  --output-file "${episode_subtitle_file_without_ext}" \
  --no-prints \
  > /dev/null 2>&1

rm -f "${audio_file}"
echo "Temporary audio file removed."

echo "--- Transcription Completed ---"
