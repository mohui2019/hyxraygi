FROM alpine:latest

# 安装必要依赖，包括解压、证书、bash 和 libc 兼容库
RUN apk add --no-cache bash curl ca-certificates openssl unzip libc6-compat

# 下载 Xray 和 Hysteria 2 二进制文件
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip xray.zip -d /usr/bin/ && \
    chmod +x /usr/bin/xray && \
    rm xray.zip

RUN curl -Lo /usr/bin/hy2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && \
    chmod +x /usr/bin/hy2

# 生成 Hysteria 2 所需的自签名证书
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/server.key -out /etc/server.crt -subj "/CN=bing.com" -days 3650

COPY entrypoint.sh /entrypoint.sh
# 修复换行符问题并给予执行权限
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 2053
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
