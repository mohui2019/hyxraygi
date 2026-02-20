#!/bin/bash

# 1. 自动生成一组绝对合法的 Reality 密钥对
KEYS=$(/usr/bin/xray x25519)
PRIV_KEY=$(echo "$KEYS" | grep "Private key" | awk '{print $3}')
PUB_KEY=$(echo "$KEYS" | grep "Public key" | awk '{print $3}')
UUID="ae8f4ad1-c000-4b2a-89a5-71649969242d"

# 2. 将生成的公钥打印到日志，方便你填入客户端
echo "===================================================="
echo "您的客户端公钥 (Public Key) 是:"
echo "$PUB_KEY"
echo "===================================================="

# 3. 直接生成配置文件 (确保没有变量转义问题)
cat <<EOF > /etc/xray.json
{
    "inbounds": [{
        "port": 443,
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
                "dest": "www.microsoft.com:443",
                "xver": 0,
                "serverNames": ["www.microsoft.com"],
                "privateKey": "$PRIV_KEY",
                "shortIds": ["a1b2c3d4"]
            }
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

# 4. 启动服务
echo "Starting Xray on Port 443..."
/usr/bin/xray -c /etc/xray.json
