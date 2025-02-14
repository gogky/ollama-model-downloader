#!/bin/bash

# 定义帮助信息
function show_help() {
    echo "Usage: $0 <command> <model-name> [-x <threads>]"
    echo "Commands:"
    echo "  get      - Get manifest and blob URLs"
    echo "  download - Download manifest and blobs"
    echo "Options:"
    echo "  -x <threads> - Specify the number of threads for aria2c (default is 4)"
    echo "Environment Variables:"
    echo "  OLLAMA_MODELS - Path to store the downloaded models (must be set before running the script)"
    echo "                  Example: export OLLAMA_MODELS=~/.ollama/models"
    echo "Examples:"
    echo "  $0 get model_name:tag"
    echo "  $0 download model_name:tag"
    echo "  $0 download model_name:tag -x 10"
    echo "After model download is complete, you can directly run: ollama run <model-name>"
}

# 检查帮助选项
if [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

# 检查参数数量
if [ $# -lt 2 ]; then
    echo "Error: Invalid number of arguments."
    show_help
    exit 1
fi

# 解析命令行参数
COMMAND=$1
MODEL_NAME=$2
THREADS=4  # 默认线程数为 4

# 解析 -x 参数
shift 2  # 移除前两个参数，剩下的参数用于解析 -x
while [[ $# -gt 0 ]]; do
    case $1 in
        -x)
            THREADS=$2
            shift 2  # 移除 -x 和其对应的值
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# 其他变量定义
REGISTRY="registry.ollama.ai"
BASE_URL="https://$REGISTRY/v2"

# 解析模型名称和标签
if [[ $MODEL_NAME == *":"* ]]; then
    MODEL_BASE=${MODEL_NAME%:*}
    TAG=${MODEL_NAME#*:}
else
    MODEL_BASE=$MODEL_NAME
    TAG="latest"
fi

# 构造 manifest URL
MANIFEST_URL="$BASE_URL/library/$MODEL_BASE/manifests/$TAG"

# 添加在脚本开头部分，show_help 函数之前
# 定义清理函数
cleanup() {
    # 终止所有子进程
    pkill -P $$
    echo -e "\nDownload interrupted. "
    exit 1
}

# 注册信号处理
trap cleanup SIGINT SIGTERM

case $COMMAND in
    "get")
        echo "Manifest URL: $MANIFEST_URL"
        
        # 获取 manifest 内容并解析
        MANIFEST=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" $MANIFEST_URL)
        
        echo -e "\nBlob URLs:"
        echo "$MANIFEST" | grep -o '"digest":"[^"]*"' | cut -d'"' -f4 | while read digest; do
            echo "$BASE_URL/library/$MODEL_BASE/blobs/$digest"
        done
        ;;
        
    "download")
        # 检查是否安装了 aria2c
        if ! command -v aria2c &> /dev/null; then
            echo "aria2c is not installed. Please install it first."
            exit 1
        fi
        
        # 检查 OLLAMA_MODELS 环境变量是否已设置
        if [ -z "$OLLAMA_MODELS" ]; then
            echo "Error: OLLAMA_MODELS environment variable is not set."
            echo "Please set the OLLAMA_MODELS environment variable before running the script."
            echo "Example: export OLLAMA_MODELS=~/.ollama/models"
            exit 1
        fi
        
        # 创建必要的目录
        MANIFEST_DIR="$OLLAMA_MODELS/manifests/$REGISTRY/library/$MODEL_BASE"
        BLOBS_DIR="$OLLAMA_MODELS/blobs"
        mkdir -p "$MANIFEST_DIR"
        mkdir -p "$BLOBS_DIR"
        
        # 获取 manifest 内容
        echo "Fetching manifest information..."
        MANIFEST=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "$MANIFEST_URL")
        
        # 提取并下载所有 blobs
        echo "Downloading blobs to: $BLOBS_DIR"
        DIGESTS=($(echo "$MANIFEST" | grep -o '"digest":"[^"]*"' | cut -d'"' -f4))
        
        # 依次下载所有blobs，实际上只有第一个gguf文件体积大
        for digest in "${DIGESTS[@]}"; do
            blob_url="$BASE_URL/library/$MODEL_BASE/blobs/$digest"
            blob_filename="${digest//:/-}"
            echo "Downloading: $blob_filename"
            aria2c -d "$BLOBS_DIR" \
                   -o "$blob_filename" \
                   -x "$THREADS" \
                   -s "$THREADS" \
                   --auto-file-renaming=false \
                   --continue=true \
                   "$blob_url" || {
                echo "Download failed or interrupted"
                exit 1
            }
        done

        #下载 manifest，因为manifest很小，使用curl下载，避免断点续传等带来的问题
        echo "Downloading manifest to: $MANIFEST_DIR/$TAG"
        curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
             "$MANIFEST_URL" > "$MANIFEST_DIR/$TAG"
        
        echo "Download completed!"
        echo "You can now run: ollama run $MODEL_NAME"
        ;;
        
    *)
        echo "Unknown command: $COMMAND"
        echo "Available commands: get, download"
        show_help
        exit 1
        ;;
esac
