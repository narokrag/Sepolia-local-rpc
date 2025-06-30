# 🚀 Ethereum Sepolia Node Monitor & RPC Response Comparator

Script Bash sederhana untuk:
- Mengecek apakah node lokal sudah **sinkron** dengan Sepolia public RPC
- Mengukur **waktu respons RPC lokal dan publik**
- (Opsional) Menyimpan hasil monitoring ke file `.csv` untuk analisis

---

## 🔧 Kebutuhan

- Sistem Linux (Ubuntu/Debian)
- `curl` dan `jq` terinstal:
  ```bash
  sudo apt update && sudo apt install -y curl jq
