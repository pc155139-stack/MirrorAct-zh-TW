#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Advertise a temporary Google Cast service and accept TLS connections so a
# phone's device picker can be tested on the same Wi-Fi network. This is a
# discovery probe: it does not implement CastV2 or receive media.
set -euo pipefail

for tool in dns-sd openssl lsof mktemp; do
  command -v "$tool" >/dev/null || { echo "缺少 $tool" >&2; exit 1; }
done

if lsof -nP -iTCP:8009 -sTCP:LISTEN >/dev/null; then
  echo "TCP 8009 已被其他程式使用，請先關閉該程式。" >&2
  exit 1
fi

TEMP_DIR=$(mktemp -d /private/tmp/mirroract-cast-probe.XXXXXX)
DNS_PID=""
cleanup() {
  if [[ -n "$DNS_PID" ]]; then
    kill "$DNS_PID" 2>/dev/null || true
    wait "$DNS_PID" 2>/dev/null || true
  fi
  rm -rf -- "$TEMP_DIR"
}
trap cleanup EXIT INT TERM

openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
  -subj '/CN=MirrorAct Cast Probe' \
  -keyout "$TEMP_DIR/key.pem" -out "$TEMP_DIR/cert.pem" \
  >"$TEMP_DIR/certificate.log" 2>&1

dns-sd -R 'MirrorAct 測試電視' _googlecast._tcp local 8009 \
  id=5f4a7c9e102d4b6aa81e59243c0b7d65 \
  'fn=MirrorAct 測試電視' md=Chromecast ca=5 ve=05 st=0 nf=1 rs= \
  >"$TEMP_DIR/bonjour.log" 2>&1 &
DNS_PID=$!
sleep 1
if ! kill -0 "$DNS_PID" 2>/dev/null; then
  cat "$TEMP_DIR/bonjour.log" >&2
  exit 1
fi

echo '已發布「MirrorAct 測試電視」，並在 TCP 8009 接聽。'
echo '請讓 iPhone 與 Mac 連同一台一般 Wi-Fi，再開啟緯來 App 的投放清單。'
echo '此工具只測試裝置搜尋與 TLS 連線，不接收或播放影片。按 Control-C 結束。'
openssl s_server -accept 8009 -cert "$TEMP_DIR/cert.pem" \
  -key "$TEMP_DIR/key.pem" -quiet -state
