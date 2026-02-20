#!/bin/bash

# 变量写死，彻底放弃 HTTP 网页提取
PORT=2053
UUID="ae8f4ad1-c000-4b2a-89a5-71649969242d"
HY_PASS="ClawCloud2026"
# Reality 私钥 (对应上文的公钥)
PRIV_KEY="uL8WzX7hK9mP2nJ5rB3vV6cZ9xX4yY1tS7dA0fG3hJ4="
SHORT_ID="a1b2c3d4"

# 生成 Xray Reality 配置 (不带 fallback)
cat <<EOF > /etc/xray.json
{
    "inbounds": [{
        "port": $PORT, "protocol": "vless",
        "settings": { "clients": [{"id": "$UUID", "flow": "xtls-rprx-vision"}], "decryption": "none" },
        "streamSettings": {
            "network": "tcp", "security": "reality",
            "realitySettings": { 
                "show": false, 
                "dest": "www.microsoft.com:443", 
                "xver": 0, 
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

# 依次启动服务，保持容器在前台运行
echo "Starting Xray Reality..."
/usr/bin/xray -c /etc/xray.json &
echo "Starting Hysteria 2..."
/usr/bin/hy2 server -c /etc/hy2.yaml
