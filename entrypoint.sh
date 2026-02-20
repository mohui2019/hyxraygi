#!/bin/bash

# 1. 变量准备（如果瓜云环境变量没填，则自动生成）
PORT=${PORT:-2053}
DEST_DOMAIN=${DEST_DOMAIN:-"www.microsoft.com:443"} # 换成更稳的微软
if [ -z "$XR_UUID" ]; then XR_UUID=$(/usr/bin/xray uuid); fi
if [ -z "$HY_PASSWORD" ]; then HY_PASSWORD=$(openssl rand -hex 8); fi
if [ -z "$REALITY_PRIV_KEY" ]; then
    KEYS=$(/usr/bin/xray x25519)
    REALITY_PRIV_KEY=$(echo "$KEYS" | grep "Private key" | awk '{print $3}')
    REALITY_PUB_KEY=$(echo "$KEYS" | grep "Public key" | awk '{print $3}')
fi
if [ -z "$REALITY_SHORT_ID" ]; then REALITY_SHORT_ID=$(openssl rand -hex 4); fi

# 2. 获取外部公网 IP（用于拼接链接）
PUBLIC_IP=$(curl -s https://ifconfig.me)

# 3. 生成 Xray 配置 (带 Fallback 回落到容器内 8080)
cat <<EOF > /etc/xray.json
{
    "inbounds": [{
        "port": $PORT, "protocol": "vless",
        "settings": { "clients": [{"id": "$XR_UUID", "flow": "xtls-rprx-vision"}], "decryption": "none" },
        "streamSettings": {
            "network": "tcp", "security": "reality",
            "realitySettings": { "show": false, "dest": "$DEST_DOMAIN", "xver": 0, "privateKey": "$REALITY_PRIV_KEY", "shortIds": ["$REALITY_SHORT_ID"] }
        },
        "sniffing": { "enabled": true, "destOverride": ["http", "tls"] },
        "fallback": { "dest": 8080 }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

# 4. 生成 Hy2 配置
cat <<EOF > /etc/hy2.yaml
listen: :$PORT
tls: { cert: /etc/server.crt, key: /etc/server.key }
auth: { type: password, password: "$HY_PASSWORD" }
EOF

# 5. 生成配置展示网页
mkdir -p /var/www
VLESS_LINK="vless://$XR_UUID@$PUBLIC_IP:$PORT?security=reality&encryption=none&pbk=$REALITY_PUB_KEY&headerType=none&fp=chrome&type=tcp&sni=${DEST_DOMAIN%:*}&sid=$REALITY_SHORT_ID&flow=xtls-rprx-vision#Claw-Reality"
HY2_LINK="hysteria2://$HY_PASSWORD@$PUBLIC_IP:$PORT/?sni=bing.com&insecure=1#Claw-Hy2"

cat <<EOF > /var/www/index.html
<html><body style="font-family:sans-serif;padding:20px;">
    <h2>ClawCloud 2053 综合门户</h2>
    <p>直接访问本端口显示此网页；使用客户端连接则为节点。</p>
    <h3>Xray Reality 链接:</h3><textarea style="width:100%;">$VLESS_LINK</textarea>
    <h3>Hysteria 2 链接:</h3><textarea style="width:100%;">$HY2_LINK</textarea>
</body></html>
EOF

# 6. 启动所有服务
/usr/bin/xray -c /etc/xray.json &
/usr/bin/hy2 server -c /etc/hy2.yaml &
cd /var/www && python3 -m http.server 8080
