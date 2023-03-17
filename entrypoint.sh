#!/bin/sh

if [ "$WSPATH" = "" ]; then
export WSPATH="$1"
fi
#echo "${WSPATH}"

# ${PORT} ${WSPATH}

# 下载 wstool  executable v5.0 release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/erebe/wstunnel/releases/download/v5.0/wstunnel-linux-x64 -o /wstunnel
chmod +x /wstunnel


# 启动 wstool 服务 
/wstunnel --server ws://0.0.0.0:33344 &

# 下载 frp  executable v0.48.0 release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/fatedier/frp/releases/download/v0.48.0/frp_0.48.0_linux_amd64.tar.gz -o /frp_0.48.0_linux_amd64.tar.gz
tar -xzvf /frp_0.48.0_linux_amd64.tar.gz
chmod +x /frp_0.48.0_linux_amd64/frps
# 启动 frp 服务  默认配置 已经知道密码的 就不用特别保证服务安全
/frp_0.48.0_linux_amd64/frps -c ./frp_0.48.0_linux_amd64/frps.ini &

# 根据环境变量 配置nginx 配置
sed -i "s/www_port/${PORT}/g" /etc/nginx/conf.d/default.conf
sed -i "s/www_wspath/${WSPATH}/g" /etc/nginx/conf.d/default.conf
sed -i "s/1024/128/g" /etc/nginx/nginx.conf
# 启动 nginx 服务
nginx -g "daemon off;"
