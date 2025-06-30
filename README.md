# 🚀 Ethereum Sepolia Node Monitor & RPC Response Comparator

Script Bash sederhana untuk:
- Mengecek apakah node lokal sudah **sinkron** dengan Sepolia public RPC
- Mengukur **waktu respons RPC lokal dan publik**

---

## 🔧 Kebutuhan

- Sistem Linux (Ubuntu/Debian)
- `curl` dan `jq` terinstal:
  ```bash
  sudo apt update && sudo apt install -y curl jq

1. Simpan script di file
   ```bash
   nano compare_block.sh

```bash
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

```
2. ganti rpc public dengan punyamu https://sepolia.infura.io/v3/xxxxxxxxxxxxxxxxxxxxxxxxxx
3. lalu simpan file CTRL+X lalu tekan y kemudian ENTER
4. Ubah menjadi executable:
   ```bash
   chmod +x compare_block.sh
5. Jalankan:
   ```bash
   watch -n 10 ./compare_block.sh
📊 Contoh Output
```bash
=========================================
Local Node     Block: 8661802 (0x842b2a)
                Time: 0.001323s
Public Sepolia Block: 8661802 (0x842b2a)
                Time: 0.445376s
=========================================
✅ Node kamu sudah sinkron atau hanya tertinggal 0 block.
```

6. Berhenti tekan CTRL + C
