#!/bin/sh
# Render 注入 $PORT；TLS 由 Render 边缘终结，xray 只监听明文 WS。
set -e
: "${UUID:?UUID env var is required}"
: "${PORT:=10000}"
WS_PATH="${WS_PATH:-/xray}"
cat > /etc/xray/config.json <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [{
    "port": $PORT,
    "protocol": "vless",
    "settings": {"clients": [{"id": "$UUID"}], "decryption": "none"},
    "streamSettings": {"network": "ws", "wsSettings": {"path": "$WS_PATH"}}
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {"domainStrategy": "UseIPv4"}
  }]
}
EOF
exec /usr/local/bin/xray -config /etc/xray/config.json
