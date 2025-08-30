#!/bin/bash

# 自动查找当前目录下的 mp4 和 m4a 文件
# 假设目录下只有一个 mp4 和一个 m4a 文件
input_mp4=$(find . -maxdepth 1 -name "*.mp4" -print -quit)
input_m4a=$(find . -maxdepth 1 -name "*.m4a" -print -quit)

BASE_DIR=$(pwd)
VIDEO_DIR="$BASE_DIR/video"

if [ -z "$input_mp4" ] || [ -z "$input_m4a" ]; then
  echo "Could not find required .mp4 or .m4a files."
  exit 1
fi

if [[ "$input_mp4" =~ ([0-9]+) ]]; then
    episode_num="${BASH_REMATCH}"
else
    echo "Error: Could not extract episode number from filename '${input_mp4}'."
    echo "Filename should contain the format 'number+episode', e.g. '...274...'"
    exit 1
fi

output_dir="$VIDEO_DIR/$episode_num"
mkdir -p "$output_dir"
output_file="$output_dir/${episode_num}.mp4"

echo "Video: ${input_mp4}"
echo "Audio: ${input_m4a}"
echo "Output: ${output_file}"

# 使用ffmpeg进行合并，-c copy 表示不重新编码，直接复制流，速度快且无损
ffmpeg -i "$input_mp4" -i "$input_m4a" -c copy -map 0:v:0 -map 1:a:0 "$output_file" && \

echo "Removing: ${input_mp4} and ${input_m4a}" && \
rm "$input_mp4" "$input_m4a" && \

# 检查上一个命令的退出状态码
if [ $? -ne 0 ]; then
    echo ""
    echo "Error: ffmpeg merge failed, original files have been retained."
fi
