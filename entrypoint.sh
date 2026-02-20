#!/bin/bash

# 参数写死（请确保与客户端填写的参数一致）
PORT=2053
UUID="ae8f4ad1-c000-4b2a-89a5-71649969242d"
HY_PASS="ClawCloud2026"
PRIV_KEY="uL8WzX7hK9mP2nJ5rB3vV6cZ9xX4yY1tS7dA0fG3hJ4="
SHORT_ID="a1b2c3d4"
# 目标域名（不仅要 dest，还要 serverNames）
SNI_DOMAIN="www.microsoft.com"

# 生成 Xray 配置 (修正了 serverNames 缺失问题)
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

# 生成 Hysteria 2 配置
cat <<EOF > /etc/hy2.yaml
listen: :$PORT
tls: { cert: /etc/server.crt, key: /etc/server.key }
auth: { type: password, password: "$HY_PASS" }
EOF

# 启动服务
echo "Starting Xray Reality..."
/usr/bin/xray -c /etc/xray.json &
echo "Starting Hysteria 2..."
/usr/bin/hy2 server -c /etc/hy2.yaml
