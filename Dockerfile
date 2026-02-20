FROM alpine:latest
# 安装 Xray, Hy2 和展示网页需要的工具
RUN apk add --no-cache bash curl ca-certificates openssl jq python3

# 下载二进制
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip xray.zip -d /usr/bin/ && chmod +x /usr/bin/xray && \
    curl -Lo /usr/bin/hy2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && \
    chmod +x /usr/bin/hy2

# 准备证书和启动脚本
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/server.key -out /etc/server.crt -subj "/CN=bing.com" -days 3650
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露端口（容器内部监听 2053）
EXPOSE 2053
ENTRYPOINT ["/entrypoint.sh"]
