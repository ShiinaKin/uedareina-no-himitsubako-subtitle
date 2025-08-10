#!/bin/bash

#--------------------------
# 环境配置
#--------------------------
model="turbo"
target_lang="Japanese"
sub_format="txt"

#--------------------------
# 任务配置 (自动化)
#--------------------------
# 1. 自动查找当前目录下的MP4文件
#    注意：此脚本假设目录下只有一个MP4文件
input_mp4=$(find . -maxdepth 1 -name "*.mp4" -print -quit)

# 2. 检查是否找到了MP4文件
if [ -z "$input_mp4" ]; then
    echo "错误：在当前目录下未找到MP4文件。"
    exit 1
fi

# 3. 从文件名中自动提取期数 (例如：...274...)
if [[ "$input_mp4" =~ ([0-9]+) ]]; then
    episode_num="${BASH_REMATCH}"
else
    echo "错误：无法从文件名 '${input_mp4}' 中提取期数。"
    echo "文件名应包含 '数字+期' 的格式, 例如 '...274期...'"
    exit 1
fi

# 4. 设置输出目录
output_dir="./subtitle/${episode_num}"

#--------------------------
# 执行
#--------------------------
echo "--- 开始执行转录任务 ---"
echo "文件: ${input_mp4}"
echo "期数: ${episode_num}"
echo "  - 使用模型: ${model}"
echo "  - 目标语言: ${target_lang}"
echo "  - 输出格式: ${sub_format}"
echo "  - 输出目录: ${output_dir}"
echo "--------------------------"

# 执行转录
whisper "${input_mp4}" \
  --model "${model}" \
  --language "${target_lang}" \
  --output_format "${sub_format}" \
  --output_dir "${output_dir}" \
#   waiting for https://github.com/openai/whisper/pull/382
#   --device mps

echo "--- 转录任务完成 ---"

#--------------------------
# 清理和归档
#--------------------------
# 确保video目录存在
target_video_dir="./video/${episode_num}"
mkdir -p "${target_video_dir}"

# 将处理过的MP4文件移动到video目录中
mv "${input_mp4}" "${target_video_dir}"
mv *.jpg "${target_video_dir}"

echo "视频文件已归档至 ${target_video_dir} 目录。"
echo "--- 任务全部完成 ---"
