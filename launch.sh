#!/bin/sh

BASE=/home/node/app
USERNAME=$(printenv USERNAME)
PASSWORD=$(printenv PASSWORD)
HF_TOKEN=$(printenv HF_TOKEN)
DATASET_ID=$(printenv DATASET_ID)
SYNC_INTERVAL=$(printenv SYNC_INTERVAL)

# 如果没有设置用户名和密码，使用默认值
if [ -z "${USERNAME}" ]; then
  USERNAME="admin"
fi

if [ -z "${PASSWORD}" ]; then
  PASSWORD="password"
fi

echo
echo "用户名: ${USERNAME}"
echo "密码: ${PASSWORD}"
echo

# 确保配置目录存在
mkdir -p "${BASE}/config"

# 如果配置文件不存在，从默认目录复制
if [ ! -e "${BASE}/config/config.yaml" ]; then
  echo "配置文件不存在，从默认目录复制: config.yaml"
  cp -r "${BASE}/default/config.yaml" "${BASE}/config/config.yaml"
fi

# 修改配置文件中的用户名和密码
sed -i "s/username: .*/username: \"${USERNAME}\"/" ${BASE}/config/config.yaml
sed -i "s/password: .*/password: \"${PASSWORD}\"/" ${BASE}/config/config.yaml

# 启用基本认证模式，禁用白名单模式
sed -i "s/whitelistMode: true/whitelistMode: false/" ${BASE}/config/config.yaml
sed -i "s/basicAuthMode: false/basicAuthMode: true/" ${BASE}/config/config.yaml

# 显示配置文件内容以便验证
echo "配置文件内容:"
cat ${BASE}/config/config.yaml

# 启动数据同步服务（如果提供了必要的环境变量）
if [ ! -z "${HF_TOKEN}" ] && [ ! -z "${DATASET_ID}" ]; then
  echo "启动数据同步服务..."
  nohup ${BASE}/sync_data.sh > ${BASE}/sync_data.log 2>&1 &
  echo "数据同步服务已在后台启动"
else
  echo "未提供HF_TOKEN或DATASET_ID，不启动数据同步服务"
fi

# 正常启动服务器
exec node server.js --listen "$@" 