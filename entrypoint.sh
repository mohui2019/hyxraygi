#!/bin/bash

# 基础参数
PORT=2053
UUID="ae8f4ad1-c000-4b2a-89a5-71649969242d"
HY_PASS="ClawCloud2026"

# 自动生成匹配的 Reality 密钥对，并打印到日志供你查看
KEYS=$(/usr/bin/xray x25519)
PRIV_KEY=$(echo "$KEYS" | grep "Private key" | awk '{print $3}')
PUB_KEY=$(echo "$KEYS" | grep "Public key" | awk '{print $3}')
SHORT_ID="a1b2c3d4"
SNI_DOMAIN="www.microsoft.com"

echo "-----------------------------------------------------"
echo "REALITY PUBLIC KEY: $PUB_KEY"
echo "-----------------------------------------------------"

# 1. 生成 Xray 配置
cat <<EOF > /etc/xray.json
{
    "inbounds": [{
        "port": $PORT,
        "protocol": "vless",
        "settings": {
            "clients": [{"id": "$UUID", "flow": "xtls-rprx-vision"}],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "tcp",
            "security": "reality",
            "realitySettings": {
                "show": false,
                "dest": "$SNI_DOMAIN:443",
                "xver": 0,
                "serverNames": ["$SNI_DOMAIN"],
                "privateKey": "$PRIV_KEY",
                "shortIds": ["$SHORT_ID"]
            }
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

# 2. 生成 Hy2 配置
cat <<EOF > /etc/hy2.yaml
listen: :$PORT
tls: { cert: /etc/server.crt, key: /etc/server.key }
auth: { type: password, password: "$HY_PASS" }
EOF

# 3. 启动
/usr/bin/xray -c /etc/xray.json &
/usr/bin/hy2 server -c /etc/hy2.yaml
