#!/bin/bash

# 获取当前脚本的所在目录
SCRIPT_DIR=$(dirname "$(realpath "$0")")

cd "$SCRIPT_DIR" || exit 1

# 设置默认值
DEFAULT_SSH_ALIAS="m920x.d"
DEFAULT_REMOTE_DIR="/mnt/4.860.ssd/time-counter"
DEFAULT_LOCAL_DIR="."

# 检查参数，如果未提供则使用默认值
SSH_ALIAS="${1:-$DEFAULT_SSH_ALIAS}"       
REMOTE_DIR="${2:-$DEFAULT_REMOTE_DIR}"     
LOCAL_DIR="${3:-$DEFAULT_LOCAL_DIR}" 

# 检查本地目录是否存在
if [ ! -d "$LOCAL_DIR" ]; then
  echo "Error: Local config directory '$LOCAL_DIR' not found."
  exit 1
fi

upload (){
  #上传文件（静默模式 + 错误输出）
  curl -s -f --request POST \
    --url "http://127.0.0.1:36677/upload?picbed=tcyun&configName=COS-Blog-Static" \
    --header 'content-type: multipart/form-data' \
    --form file=@"$FILE" > /dev/null
}

cd "$SCRIPT_DIR/dist" || exit 1
npm run build
FILE="counter.js"
upload $FILE ${CONFIG_NAME}

cd "$SCRIPT_DIR" || exit 1

ssh -t "$SSH_ALIAS" <<EOF
    mkdir -p "$DEFAULT_REMOTE_DIR"
    mkdir -p "$DEFAULT_REMOTE_DIR/dist"
EOF

rsync -avz --progress \
  --exclude '.DS_Store' \
  --exclude '._*' \
  --exclude '__MACOSX' \
  --exclude "deploy.sh" \
  --exclude "venv/" \
  --exclude "logs/" \
  --exclude "__pycache__/" \
  "$LOCAL_DIR/app/" "$SSH_ALIAS:$REMOTE_DIR/app"

rsync -avz --progress \
  --exclude '.DS_Store' \
  --exclude '._*' \
  --exclude '__MACOSX' \
  --exclude "deploy.sh" \
  --exclude "venv/" \
  --exclude "logs/" \
  --exclude "__pycache__/" \
  "$LOCAL_DIR/config/" "$SSH_ALIAS:$REMOTE_DIR/config"

rsync -avz --progress \
  --exclude '.DS_Store' \
  --exclude '._*' \
  --exclude '__MACOSX' \
  --exclude "deploy.sh" \
  --exclude "venv/" \
  --exclude "logs/" \
  --exclude "__pycache__/" \
  "$LOCAL_DIR/global/" "$SSH_ALIAS:$REMOTE_DIR/global/"

rsync -avz --progress \
  --exclude '.DS_Store' \
  --exclude '._*' \
  --exclude '__MACOSX' \
  --exclude "deploy.sh" \
  --exclude "venv/" \
  --exclude "logs/" \
  --exclude "__pycache__/" \
  "$LOCAL_DIR/process/" "$SSH_ALIAS:$REMOTE_DIR/process/"

rsync -avz --progress \
  --exclude '.DS_Store' \
  --exclude '._*' \
  --exclude '__MACOSX' \
  --exclude "deploy.sh" \
  --exclude "venv/" \
  --exclude "logs/" \
  --exclude "__pycache__/" \
  "$LOCAL_DIR/utils/" "$SSH_ALIAS:$REMOTE_DIR/utils/"

rsync -avz --progress \
  "$LOCAL_DIR/dist/counter.js" "$SSH_ALIAS:$REMOTE_DIR/dist/counter.js"

rsync -avz --progress \
  "$LOCAL_DIR/dist/index.html" "$SSH_ALIAS:$REMOTE_DIR/dist/index.html"

rsync -avz --progress \
  "$LOCAL_DIR/dist/room.html" "$SSH_ALIAS:$REMOTE_DIR/dist/room.html"

rsync -avz --progress \
  "$LOCAL_DIR/config.yaml" "$SSH_ALIAS:$REMOTE_DIR/config.yaml"

rsync -avz --progress \
  "$LOCAL_DIR/go.mod" "$SSH_ALIAS:$REMOTE_DIR/go.mod"
rsync -avz --progress \
  "$LOCAL_DIR/go.sum" "$SSH_ALIAS:$REMOTE_DIR/go.sum"
rsync -avz --progress \
  "$LOCAL_DIR/main.go" "$SSH_ALIAS:$REMOTE_DIR/main.go"

rsync -avz --progress \
  "$LOCAL_DIR/ecosystem.config.js" "$SSH_ALIAS:$REMOTE_DIR/ecosystem.config.js"
# 上传完成
echo "Upload complete."

ssh -t "$SSH_ALIAS" <<EOF
    cd $DEFAULT_REMOTE_DIR && go build -o counter main.go
EOF

ssh "$SSH_ALIAS" "source ~/.nvm/nvm.sh && pm2 start $DEFAULT_REMOTE_DIR/ecosystem.config.js"
if [ $? -ne 0 ]; then
  echo "Error: Failed to reload audioServer on server '$SSH_ALIAS'."
  exit 1
fi

echo "Server configuration successfully updated and reloaded on '$SSH_ALIAS'."