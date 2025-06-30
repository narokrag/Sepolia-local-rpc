#!/bin/bash

# === Konfigurasi RPC ===
LOCAL_RPC="http://localhost:8545"
EXPLORER_RPC="https://sepolia.infura.io/v3/xxxxxxxxxxxxxxxxxxxxxxxxxx"

# === Fungsi ambil block number dan waktu ===
get_block_and_time() {
  RPC_URL="$1"

  # Simpan respons dan waktu ke file sementara
  TMP=$(mktemp)
  TIME=$(curl -s -w "%{time_total}" -o "$TMP" -X POST \
    -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    "$RPC_URL")

  BODY=$(cat "$TMP")
  rm "$TMP"

  HEX=$(echo "$BODY" | jq -r '.result')
  DEC=$((HEX))

  echo "$DEC $HEX $TIME"
}

# === Ambil data lokal dan explorer ===
read LOCAL_DEC LOCAL_HEX LOCAL_TIME < <(get_block_and_time "$LOCAL_RPC")
read EXPLORER_DEC EXPLORER_HEX EXPLORER_TIME < <(get_block_and_time "$EXPLORER_RPC")

# === Tampilkan hasil ===
echo "========================================="
echo "Local Node     Block: $LOCAL_DEC ($LOCAL_HEX)"
echo "                Time: ${LOCAL_TIME}s"
echo "Public Sepolia Block: $EXPLORER_DEC ($EXPLORER_HEX)"
echo "                Time: ${EXPLORER_TIME}s"
echo "========================================="

DIFF=$((EXPLORER_DEC - LOCAL_DEC))

if [ "$DIFF" -le 0 ]; then
  echo "✅ Node kamu sudah sinkron atau hanya tertinggal 0 block."
else
  echo "⚠️  Node kamu tertinggal $DIFF block dari head block Sepolia."
fi

# === (Opsional) Logging ke CSV ===
LOGFILE="block_compare_log.csv"
if [ ! -f "$LOGFILE" ]; then
  echo "timestamp,local_block,local_time,public_block,public_time,diff" > "$LOGFILE"
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$TIMESTAMP,$LOCAL_DEC,$LOCAL_TIME,$EXPLORER_DEC,$EXPLORER_TIME,$DIFF" >> "$LOGFILE"
