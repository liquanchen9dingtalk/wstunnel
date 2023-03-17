# Build Cache image
#FROM fpco/stack-build-small:lts-19.2 as builder-cache

#COPY stack.yaml /mnt
#COPY *.cabal /mnt
#WORKDIR /mnt
#RUN rm -rf ~/.stack &&  \
#    stack config set system-ghc --global true && \
#    stack setup && \
#    stack install --ghc-options="-fPIC" --only-dependencies



# Build phase
#FROM builder-cache as builder
# FROM ghcr.io/erebe/wstunnel:build-cache as builder
#COPY . /mnt

#RUN echo '  ld-options: -static' >> wstunnel.cabal ; \
#    stack install --ghc-options="-fPIC"
#RUN upx /root/.local/bin/wstunnel


# Final Image 

# FROM alpine:latest as runner
# 修改为基于nginx 镜像 启动；
FROM nginx:latest

LABEL org.opencontainers.image.source https://github.com/liquanchen9dingtalk/wstunnel

# 复制配置模板 
COPY nginx.conf /etc/nginx/conf.d/default.conf
# COPY --from=builder /root/.local/bin/wstunnel /
ADD entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

WORKDIR /
User nginx

CMD ["/opt/entrypoint.sh"]

