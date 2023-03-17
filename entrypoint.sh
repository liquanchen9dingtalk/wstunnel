#!/bin/sh

if [ "$WSPATH" = "" ]; then
export WSPATH="$1"
fi
#echo "${WSPATH}"

# ${PORT} ${WSPATH}

# 下载 wstool  executable release
sudo curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/erebe/wstunnel/releases/download/v5.0/wstunnel-linux-x64 -o /wstunnel
sudo chmod +x /wstunnel

# 启动 wstool 服务 
sudo /wstunnel --server ws://0.0.0.0:33344 &

# 根据环境变量 配置nginx 配置
sudo sed -i "s/www_port/${PORT}/g" /etc/nginx/conf.d/default.conf
sudo sed -i "s/www_wspath/${WSPATH}/g" /etc/nginx/conf.d/default.conf

# 启动 nginx 服务
nginx 
