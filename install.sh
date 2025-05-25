#!/bin/bash

# 设置错误时退出
set -e

# 检查conda是否安装
if ! command -v conda &> /dev/null; then
    echo "错误: 请先安装conda"
    exit 1
fi

# 检查是否已存在MinerU环境
if conda info --envs | grep -q "^MinerU "; then
    echo "检测到已存在MinerU环境，将重新创建..."
    conda env remove -n MinerU -y
fi

# 创建并激活conda环境
echo "正在创建conda环境..."
conda create -n MinerU python=3.10 -y

# 获取conda根目录并激活环境
CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"
conda activate MinerU || { echo "错误: conda环境激活失败"; exit 1; }

# 验证环境激活
if [[ "$(which python)" != *"MinerU"* ]]; then
    echo "错误: Python环境未正确切换到MinerU"
    exit 1
fi

# 安装依赖
echo "正在安装依赖..."
pip install -U "magic-pdf[full]" --extra-index-url https://wheels.myhloli.com -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install -r requirements.txt

# 检查models目录是否存在
if [ ! -d "models" ]; then
    mkdir -p models
fi

# 复制配置文件模板
cp doc/magic-pdf.template.json ~/magic-pdf.json

# 修改配置文件中的models-dir路径
MODELS_DIR="$(pwd)/models"
sed -i.bak "s|\"models-dir\": \"/tmp/models\"|\"models-dir\": \"$MODELS_DIR\"|" ~/magic-pdf.json

echo "=== 环境配置完成 ==="
echo "请确保已下载模型文件并放置在 $MODELS_DIR 目录下"
echo "运行 'python webui.py' 启动服务"