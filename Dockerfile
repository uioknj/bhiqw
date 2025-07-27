FROM node:19.1.0-alpine3.16

# 设置应用目录
ARG APP_HOME=/home/node/app

# 安装系统依赖
RUN apk add --no-cache gcompat tini git python3 py3-pip bash dos2unix findutils tar curl

# 安装HuggingFace Hub
RUN pip3 install --no-cache-dir huggingface_hub

# 确保正确处理内核信号
ENTRYPOINT [ "tini", "--" ]

# 创建应用目录
WORKDIR ${APP_HOME}

# 设置NODE_ENV为production
ENV NODE_ENV=production

# 设置登录凭证环境变量
ENV USERNAME="admin"
ENV PASSWORD="password"

# 克隆官方仓库（最新版本）
RUN git clone https://github.com/uioknj/nviwueivnwoiuenvisd.git .

# 安装依赖
RUN echo "*** 安装npm包 ***" && \
    npm install && npm cache clean --force

# 添加启动脚本和数据同步脚本
COPY launch.sh sync_data.sh ./
RUN chmod +x launch.sh sync_data.sh && \
    dos2unix launch.sh sync_data.sh

# 安装生产依赖
RUN echo "*** 安装生产npm包 ***" && \
    npm i --no-audit --no-fund --loglevel=error --no-progress --omit=dev && npm cache clean --force

# 创建配置目录
RUN mkdir -p "config" || true && \
    rm -f "config.yaml" || true && \
    ln -s "./config/config.yaml" "config.yaml" || true

# 清理不必要的文件
RUN echo "*** 清理 ***" && \
    mv "./docker/docker-entrypoint.sh" "./" && \
    rm -rf "./docker" && \
    echo "*** 使docker-entrypoint.sh可执行 ***" && \
    chmod +x "./docker-entrypoint.sh" && \
    echo "*** 转换行尾为Unix格式 ***" && \
    dos2unix "./docker-entrypoint.sh" || true

# 修改入口脚本，添加自定义启动脚本
RUN sed -i 's/# Start the server/.\/launch.sh/g' docker-entrypoint.sh

# 创建临时备份目录和数据目录
RUN mkdir -p /tmp/sillytavern_backup && \
    mkdir -p ${APP_HOME}/data

# 设置权限
RUN chmod -R 777 ${APP_HOME} && \
    chmod -R 777 /tmp/sillytavern_backup

# 暴露端口
EXPOSE 8000

# 启动命令
CMD [ "./docker-entrypoint.sh" ] 