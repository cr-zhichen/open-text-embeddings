# 基于 Python 3.12.4 镜像
FROM python:3.12.4

# 设置工作目录
WORKDIR /app

# 将当前路径下的所有文件复制到容器的工作目录下
COPY . .

# 安装 git 和 git-lfs
RUN apt-get update && apt-get install -y git git-lfs

# 强制更新 git-lfs 钩子配置
RUN git lfs update --force

# 更新 pip 和 setuptools
RUN pip install --upgrade pip setuptools

# 安装所需的 Python 包
RUN pip install --no-cache-dir open-text-embeddings[server] sentence-transformers langchain-community

# 设置环境变量
ENV MODEL=lier007/xiaobu-embedding-v2
ENV DEVICE=cpu

# 赋予执行权限
RUN chmod +x download.sh

# 下载模型文件
RUN bash ./download.sh $MODEL

# 暴露端口 8000
EXPOSE 8000

# 启动服务
CMD ["python", "-m", "open.text.embeddings.server"]
