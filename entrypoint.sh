#!/bin/bash

# 只运行 Xray，不再运行 Hy2，彻底避免端口争抢
# 将内部监听端口改为 443，匹配瓜云的默认检查
cat <<EOF > /etc/xray.json
{
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
                "privateKey": "uL8WzX7hK9mP2nJ5rB3vV6cZ9xX4yY1tS7dA0fG3hJ4=",
                "shortIds": ["a1b2c3d4"]
            }
        }
    }],
    "outbounds": [{"protocol": "freedom"}]
}
EOF

echo "Starting Xray on Port 443..."
/usr/bin/xray -c /etc/xray.json
