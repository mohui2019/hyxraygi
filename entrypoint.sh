#!/bin/bash

# 1. 强制生成私钥和公钥到独立文件，避免变量丢失
/usr/bin/xray x25519 > /tmp/keys.txt
PRIV_KEY=$(grep "Private key" /tmp/keys.txt | awk '{print $3}')
PUB_KEY=$(grep "Public key" /tmp/keys.txt | awk '{print $3}')

echo "===================================================="
echo "您的客户端公钥 (Public Key) 是: $PUB_KEY"
echo "===================================================="

# 2. 使用 printf 直接构建 JSON，防止变量被 EOF 吞掉
printf '{
    "inbounds": [{
        "port": 443,
        "protocol": "vless",
        "settings": {
            "clients": [{"id": "ae8f4ad1-c000-4b2a-89a5-71649969242d", "flow": "xtls-rprx-vision"}],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "tcp",
            "security": "reality",
            "realitySettings": {
                "show": false,
                "dest": "www.microsoft.com:443",
                "xver": 0,
                "serverNames": ["www.microsoft.com"],
                "privateKey": "%s",
                "shortIds": ["a1b2c3d4"]
            }
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}' "$PRIV_KEY" > /etc/xray.json

# 3. 启动
echo "Starting Xray..."
/usr/bin/xray -c /etc/xray.json
