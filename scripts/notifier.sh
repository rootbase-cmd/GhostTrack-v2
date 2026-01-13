#!/usr/bin/env bash
# Usage: TELEGRAM_BOT_TOKEN=xxx TELEGRAM_CHAT_ID=yyy ./scripts/notifier.sh "Message text"
MSG="${1:-no message}"
if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" -d text="$MSG" >/dev/null 2>&1 || true
fi
if [ -n "${MATRIX_WEBHOOK:-}" ]; then
  curl -s -X POST "${MATRIX_WEBHOOK}" -H "Content-Type: application/json" -d "{\"text\":\"$MSG\"}" >/dev/null 2>&1 || true
fi
echo "notified"
