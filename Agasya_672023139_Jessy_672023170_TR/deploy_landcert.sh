#!/bin/bash

RPC_URL="http://127.0.0.1:8545"

ADMIN_PK="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

echo ""
echo "=============================================="
echo "       LANDCERT AUTOMATIC DEPLOYMENT"
echo "=============================================="
echo ""

# ============================================================
# CEK ANVIL
# ============================================================

echo "Mengecek koneksi Anvil..."

CHAIN_ID=$(cast chain-id \
    --rpc-url "$RPC_URL" \
    2>/dev/null)

if [ -z "$CHAIN_ID" ]; then

    echo ""
    echo "❌ Tidak dapat terhubung ke Anvil."
    echo ""
    echo "Pastikan Anvil sedang berjalan:"
    echo ""
    echo "anvil"
    echo ""

    exit 1

fi

echo "✅ Anvil terhubung."
echo "Chain ID: $CHAIN_ID"

echo ""

# ============================================================
# COMPILE
# ============================================================

echo "Membersihkan hasil compile lama..."

rm -rf out cache

echo ""

echo "Compile Smart Contract..."

forge build

if [ $? -ne 0 ]; then

    echo ""
    echo "❌ COMPILE GAGAL."
    exit 1

fi

echo ""
echo "✅ Compile berhasil."

# ============================================================
# DEPLOY
# ============================================================

echo ""
echo "Deploying LandCert ke Anvil..."
echo ""

DEPLOY_OUTPUT=$(forge create \
    src/LandCert.sol:LandCert \
    --rpc-url "$RPC_URL" \
    --private-key "$ADMIN_PK" \
    2>&1)

echo "$DEPLOY_OUTPUT"

# ============================================================
# AMBIL ALAMAT KONTRAK OTOMATIS
# ============================================================

KONTRAK=$(echo "$DEPLOY_OUTPUT" | \
    grep -i "Deployed to:" | \
    awk '{print $3}' | \
    tr -d '\r')

# Alternatif jika format berbeda
if [ -z "$KONTRAK" ]; then

    KONTRAK=$(echo "$DEPLOY_OUTPUT" | \
        grep -Eo '0x[a-fA-F0-9]{40}' | \
        head -1)

fi

# ============================================================
# VALIDASI ALAMAT
# ============================================================

if [[ ! "$KONTRAK" =~ ^0x[a-fA-F0-9]{40}$ ]]; then

    echo ""
    echo "❌ GAGAL MENDAPATKAN ALAMAT KONTRAK."
    echo ""
    echo "Output deployment:"
    echo "$DEPLOY_OUTPUT"
    echo ""

    exit 1

fi

# ============================================================
# SIMPAN ALAMAT KONTRAK
# ============================================================

echo "$KONTRAK" > contract_address.txt

echo ""
echo "=============================================="
echo "       DEPLOYMENT BERHASIL"
echo "=============================================="
echo ""
echo "Alamat Kontrak Baru:"
echo "$KONTRAK"
echo ""
echo "Alamat telah otomatis disimpan ke:"
echo "contract_address.txt"
echo ""

# ============================================================
# CEK KONTRAK
# ============================================================

echo "=============================================="
echo "       VERIFIKASI KONTRAK"
echo "=============================================="
echo ""

echo "Alamat Admin:"
cast call "$KONTRAK" \
    "getAdmin()(address)" \
    --rpc-url "$RPC_URL"

echo ""

echo "Jumlah Sertifikat:"
cast call "$KONTRAK" \
    "getCertificateCount()(uint256)" \
    --rpc-url "$RPC_URL"

echo ""

echo "Riwayat Sertifikat Wallet Admin:"
cast call "$KONTRAK" \
    "getMyCertificateIds()(uint256[])" \
    --rpc-url "$RPC_URL" \
    --from 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266

echo ""
echo "=============================================="
echo "       KONTRAK SIAP DIGUNAKAN"
echo "=============================================="
echo ""
echo "Alamat:"
cat contract_address.txt
echo ""
echo "Jalankan:"
echo "./landcert.sh"
echo ""

