#!/bin/bash

# 自动查找当前目录下的 mp4 和 m4a 文件
# 假设目录下只有一个 mp4 和一个 m4a 文件
input_mp4=$(find . -maxdepth 1 -name "*.mp4" -print -quit)
input_m4a=$(find . -maxdepth 1 -name "*.m4a" -print -quit)

# 检查文件是否存在
if [ -z "$input_mp4" ] || [ -z "$input_m4a" ]; then
  echo "错误：未找到所需的 .mp4 或 .m4a 文件。"
  echo "请确保当前目录下包含一个视频文件和一个音频文件。"
  exit 1
fi

# 从mp4文件名生成输出文件名 (例如: original.mp4 -> original_mixed.mp4)
output_file="${input_mp4%.mp4}_mixed.mp4"

echo "--- 开始合并文件 ---"
echo "视频文件: ${input_mp4}"
echo "音频文件: ${input_m4a}"
echo "输出文件: ${output_file}"
echo "--------------------"

# 使用ffmpeg进行合并，-c copy 表示不重新编码，直接复制流，速度快且无损
ffmpeg -i "$input_mp4" -i "$input_m4a" -c copy -map 0:v:0 -map 1:a:0 "$output_file" && \

echo "--- 合并成功 ---" && \
echo "正在删除源文件: ${input_mp4} 和 ${input_m4a}" && \
rm "$input_mp4" "$input_m4a" && \
echo "--- 清理完成 ---"

# 检查上一个命令的退出状态码
if [ $? -ne 0 ]; then
    echo ""
    echo "错误：ffmpeg 合并失败，原始文件已保留。"
fi
