#!/bin/bash

RPC_URL="http://127.0.0.1:8545"

ADMIN_PK="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

echo "=============================================="
echo "       LANDCERT SMART CONTRACT DEPLOYMENT"
echo "=============================================="
echo ""

echo "🔨 Melakukan deployment kontrak baru..."
echo ""

OUTPUT=$(forge create src/LandCert.sol:LandCert \
    --rpc-url "$RPC_URL" \
    --private-key "$ADMIN_PK" \
    --broadcast 2>&1)

echo "$OUTPUT"

CONTRACT=$(echo "$OUTPUT" | \
    grep "Deployed to:" | \
    awk '{print $3}')

if [ -z "$CONTRACT" ]; then

    echo ""
    echo "❌ DEPLOYMENT GAGAL!"
    echo ""
    exit 1

fi

echo "$CONTRACT" > contract_address.txt

echo ""
echo "=============================================="
echo "       DEPLOYMENT BERHASIL"
echo "=============================================="
echo ""
echo "Contract Address:"
echo "$CONTRACT"
echo ""
echo "RPC URL:"
echo "$RPC_URL"
echo ""
echo "✅ Alamat kontrak disimpan ke:"
echo "contract_address.txt"
echo ""
echo "✅ landcert.sh akan otomatis menggunakan alamat kontrak ini."
echo ""
echo "=============================================="

