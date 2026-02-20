FROM alpine:latest

# 1. 修正：增加了 unzip 和 libc6-compat (Xray 运行必选)
RUN apk add --no-cache bash curl ca-certificates openssl jq python3 unzip libc6-compat

# 2. 下载并安装 Xray
RUN curl -L https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o xray.zip && \
    unzip xray.zip -d /usr/bin/ && \
    chmod +x /usr/bin/xray && \
    rm xray.zip

# 3. 下载并安装 Hysteria 2
RUN curl -Lo /usr/bin/hy2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && \
    chmod +x /usr/bin/hy2

# 4. 生成自签名证书
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/server.key -out /etc/server.crt -subj "/CN=bing.com" -days 3650

COPY entrypoint.sh /entrypoint.sh
# 5. 修正：强制转换换行符，防止脚本无法执行
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 2053
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
