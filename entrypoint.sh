#!/bin/sh

if [ "$WSPATH" = "" ]; then
export WSPATH="$1"
fi
#echo "${WSPATH}"

# ${PORT} ${WSPATH}

sed 


# 下载 wstool  executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/erebe/wstunnel/releases/download/v5.0/wstunnel-linux-x64 -o /wstunnel
chmod +x /wstunnel

# 启动 wstool 服务 
/wstunnel --server ws://0.0.0.0:33344 &

# 根据环境变量 配置nginx 配置
sed -i "s/www_port/${PORT}/g" /etc/nginx/conf.d/default.conf
sed -i "s/www_wspath/${WSPATH}/g" /etc/nginx/conf.d/default.conf

# 启动 nginx 服务
nginx 
