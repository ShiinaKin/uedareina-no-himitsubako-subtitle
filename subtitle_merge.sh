#!/bin/bash

readonly BASE_DIR=$(pwd)
readonly VIDEO_DIR="$BASE_DIR/video"
readonly SUBTITLE_DIR="$BASE_DIR/subtitle"
readonly OUTPUT_DIR="$BASE_DIR/output"

if [ $# -eq 0 ]; then
    echo "Error: No episode number provided."
    echo "Usage: $0 <episode_number> [--soft]"
    echo "Example: $0 01"
    echo "Example: $0 01 --soft"
    exit 1
fi

readonly TARGET_EPISODE="$1"
soft_sub=false
output_ext="mp4"
subtitle_mode="hard"

if [[ "$2" == "--soft" ]]; then
    soft_sub=true
    output_ext="mkv"
    subtitle_mode="soft"
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "Could not find 'ffmpeg' command."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

episode_video_dir="$VIDEO_DIR/$TARGET_EPISODE"
episode_subtitle_dir="$SUBTITLE_DIR/$TARGET_EPISODE"
episode_output_dir="$OUTPUT_DIR/$TARGET_EPISODE"

if [ ! -d "$episode_video_dir" ]; then
    echo "Error: Video directory '$episode_video_dir' not found."
    exit 1
fi

if [ ! -d "$episode_subtitle_dir" ]; then
    echo "Error: Subtitle directory '$episode_subtitle_dir' not found."
    exit 1
fi

episode_num="$TARGET_EPISODE"

echo "Processing episode: $episode_num"
echo "Subtitle mode: $subtitle_mode"

    video_file=$(find "$episode_video_dir" -maxdepth 1 -type f -iname "*.mp4" -print -quit)
    subtitle_file=$(find "$episode_subtitle_dir" -maxdepth 1 -type f \( -iname "*.ass" -o -iname "*.ssa" \) -print -quit)
  
    # --- File validation ---
    if [[ -z "$video_file" ]]; then
        echo "Warning: No video file (.mp4) found in '$episode_video_dir' directory."
        exit 1
    fi

    if [[ -z "$subtitle_file" ]]; then
        echo "Warning: No subtitle file (.ass or .ssa) found in '$episode_subtitle_dir' directory."
        exit 1
    fi

    mkdir -p "$episode_output_dir"
    output_file="$episode_output_dir/${episode_num}_output.$output_ext"

    echo "Video file: $video_file"
    echo "Subtitle file: $subtitle_file"
    echo "Output file: $output_file"
    echo ""

    # --- Execute FFmpeg command ---
    if [ "$soft_sub" = true ]; then
        # Soft subtitles (MKV output)
        # -y: Overwrite output file if it exists
        # -i "$video_file": Input video file
        # -i "$subtitle_file": Input subtitle file
        # -map 0: Map all streams from the first input (video)
        # -map 1: Map all streams from the second input (subtitle)
        # -c copy: Copy all streams without re-encoding (fast, no quality loss)
        echo "Running FFmpeg for soft subtitles..."
        echo ""
        ffmpeg -y -i "$video_file" -i "$subtitle_file" -map 0 -map 1 -c copy "$output_file"
    else
        # Hard subtitles (MP4 output)
        # -y: Overwrite output file if it exists
        # -i "$video_file": Input video file
        # -vf "subtitles='$subtitle_file'": Video filter to burn subtitles into the video.
        # This requires re-encoding the video stream.
        echo "Running FFmpeg for hard subtitles..."
        echo ""
        ffmpeg -y -i "$video_file" -vf "subtitles='$subtitle_file'" "$output_file"
    fi

    echo ""
    if [ $? -eq 0 ]; then
        echo "Success: Episode $episode_num processed successfully!"
    else
        echo "Error: FFmpeg encountered an error while processing episode $episode_num."
        exit 1
    fi
