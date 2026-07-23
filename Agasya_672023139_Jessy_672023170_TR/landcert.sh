#!/bin/bash

RPC_URL="http://127.0.0.1:8545"

ADMIN_ADDRESS="0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"

ADMIN_PK="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

# ============================================================
# AMBIL ALAMAT KONTRAK
# ============================================================

KONTRAK="0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e"

echo "$KONTRAK" > contract_address.txt

# ============================================================
# CEK KONTRAK
# ============================================================

if [ -z "$KONTRAK" ]; then
    echo "❌ Alamat kontrak kosong."
    exit 1
fi

# ============================================================
# FUNGSI AMBIL DATA TANAH
# ============================================================

get_land_data() {

    local ID="$1"

    cast call "$KONTRAK" \
    "getLand(uint256)(string,uint256,string,address,bool,bool,bool)" \
    "$ID" \
    --rpc-url "$RPC_URL" \
    2>/dev/null
}

# ============================================================
# FUNGSI TAMPILKAN DATA TANAH
# ============================================================

show_land() {

    local ID="$1"

    DATA=$(get_land_data "$ID")

    if [ -z "$DATA" ]; then
        echo "❌ Data tanah ID $ID tidak ditemukan."
        return
    fi

    mapfile -t LINES <<< "$DATA"

    LOKASI=$(echo "${LINES[0]}" | tr -d '"' | xargs)
    LUAS=$(echo "${LINES[1]}" | tr -d '"' | xargs)
    PEMILIK=$(echo "${LINES[2]}" | tr -d '"' | xargs)
    PENDAFTAR=$(echo "${LINES[3]}" | tr -d '"' | xargs)
    DISPUTE=$(echo "${LINES[4]}" | tr -d '"' | xargs)
    EXISTS=$(echo "${LINES[5]}" | tr -d '"' | xargs)
    TAX=$(echo "${LINES[6]}" | tr -d '"' | xargs)

    echo ""
    echo "=============================================="
    echo "ID Sertifikat : $ID"
    echo "Lokasi        : $LOKASI"
    echo "Luas          : $LUAS m2"
    echo "Pemilik       : $PEMILIK"
    echo "Pendaftar     : $PENDAFTAR"

    if [ "$DISPUTE" = "true" ]; then
        echo "Sengketa      : ⚠️ YA / TERBLOKIR"
    else
        echo "Sengketa      : ✅ TIDAK"
    fi

    if [ "$TAX" = "true" ]; then
        echo "Pajak PBB     : ✅ LUNAS"
    else
        echo "Pajak PBB     : ❌ BELUM BAYAR"
    fi

    echo "=============================================="
}

# ============================================================
# MENU USER
# ============================================================

user_menu() {

    while true; do

        clear

        echo "=============================================="
        echo "       LANDCERT SECURE SYSTEM"
        echo "=============================================="
        echo ""
        echo "LOGIN SEBAGAI USER"
        echo ""
        echo "Wallet:"
        echo "$USER_ADDRESS"
        echo ""
        echo "Kontrak:"
        echo "$KONTRAK"
        echo ""
        echo "1. Daftar Tanah"
        echo "2. Bayar PBB"
        echo "3. Riwayat Tanah Saya"
        echo "4. Logout"
        echo ""

        read -p "Pilih menu (1-4): " PILIHAN

        case "$PILIHAN" in

        # ====================================================
        # DAFTAR TANAH
        # ====================================================

        1)

            clear

            echo "=============================================="
            echo "             DAFTAR TANAH BARU"
            echo "=============================================="
            echo ""

            read -p "Masukkan Lokasi Tanah: " LOKASI
            read -p "Masukkan Luas Tanah (m2): " LUAS
            read -p "Masukkan Nama Pemilik: " PEMILIK

            echo ""
            echo "⏳ Menyimpan data ke blockchain..."
            echo ""

            HASIL=$(cast send \
                "$KONTRAK" \
                "registerLand(string,uint256,string)" \
                "$LOKASI" \
                "$LUAS" \
                "$PEMILIK" \
                --rpc-url "$RPC_URL" \
                --private-key "$USER_PK" \
                2>&1)

            echo "$HASIL"

            if [[ "$HASIL" == *"transactionHash"* ]] || \
               [[ "$HASIL" == *"blockHash"* ]] || \
               [[ "$HASIL" == *"transactionHash:"* ]]; then

                echo ""
                echo "=============================================="
                echo "✅ TANAH BERHASIL DIDAFTARKAN"
                echo "=============================================="

            else

                echo ""
                echo "❌ Gagal mendaftarkan tanah."

            fi

            echo ""
            read -p "Tekan Enter untuk kembali..."

            ;;

        # ====================================================
        # BAYAR PBB
        # ====================================================

        2)

            clear

            echo "=============================================="
            echo "                 BAYAR PBB"
            echo "=============================================="
            echo ""

            echo "⏳ Mengambil tanah Anda..."

            MY_IDS=$(cast call \
                "$KONTRAK" \
                "getMyCertificateIds()(uint256[])" \
                --rpc-url "$RPC_URL" \
                --from "$USER_ADDRESS" \
                2>/dev/null)

            if [ -z "$MY_IDS" ] || [ "$MY_IDS" = "[]" ]; then

                echo ""
                echo "❌ Belum ada tanah yang Anda daftarkan."

                read -p "Tekan Enter untuk kembali..."

                continue

            fi

            echo ""
            echo "ID tanah Anda:"
            echo "$MY_IDS"
            echo ""

            read -p "Masukkan ID tanah yang ingin dibayar: " ID

            DATA=$(get_land_data "$ID")

            if [ -z "$DATA" ]; then

                echo "❌ Tanah tidak ditemukan."

                read -p "Tekan Enter untuk kembali..."

                continue

            fi

            mapfile -t LINES <<< "$DATA"

            LOKASI=$(echo "${LINES[0]}" | tr -d '"' | xargs)
            LUAS=$(echo "${LINES[1]}" | tr -d '"' | xargs)
            PEMILIK=$(echo "${LINES[2]}" | tr -d '"' | xargs)
            PENDAFTAR=$(echo "${LINES[3]}" | tr -d '"' | xargs)
            TAX=$(echo "${LINES[6]}" | tr -d '"' | xargs)

            echo ""
            echo "=============================================="
            echo "             DETAIL TANAH"
            echo "=============================================="
            echo "ID Sertifikat : $ID"
            echo "Lokasi        : $LOKASI"
            echo "Luas          : $LUAS m2"
            echo "Pemilik       : $PEMILIK"
            echo "Pendaftar     : $PENDAFTAR"
            echo ""

            if [ "$TAX" = "true" ]; then

                echo "⚠️ Pajak tanah ini sudah lunas."

                read -p "Tekan Enter untuk kembali..."

                continue

            fi

            echo "⏳ Memproses pembayaran PBB..."

            HASIL=$(cast send \
                "$KONTRAK" \
                "payTax(uint256)" \
                "$ID" \
                --rpc-url "$RPC_URL" \
                --private-key "$USER_PK" \
                2>&1)

            echo "$HASIL"

            if [[ "$HASIL" == *"transactionHash"* ]] || \
               [[ "$HASIL" == *"blockHash"* ]] || \
               [[ "$HASIL" == *"transactionHash:"* ]]; then

                echo ""
                echo "=============================================="
                echo "✅ PEMBAYARAN PBB BERHASIL"
                echo "=============================================="

            else

                echo ""
                echo "❌ Pembayaran PBB gagal."

            fi

            read -p "Tekan Enter untuk kembali..."

            ;;

        # ====================================================
        # RIWAYAT TANAH
        # ====================================================

        3)

            clear

            echo "=============================================="
            echo "             RIWAYAT TANAH SAYA"
            echo "=============================================="
            echo ""

            echo "Wallet:"
            echo "$USER_ADDRESS"
            echo ""

            echo "Kontrak:"
            echo "$KONTRAK"
            echo ""

            echo "⏳ Mengambil data blockchain..."
            echo ""

            MY_IDS=$(cast call \
                "$KONTRAK" \
                "getMyCertificateIds()(uint256[])" \
                --rpc-url "$RPC_URL" \
                --from "$USER_ADDRESS" \
                2>/dev/null)

            echo "Hasil blockchain:"
            echo "$MY_IDS"
            echo ""

            if [ -z "$MY_IDS" ] || [ "$MY_IDS" = "[]" ]; then

                echo "❌ Belum ada tanah yang Anda daftarkan."

            else

                echo "=============================================="
                echo "       TANAH YANG PERNAH ANDA DAFTARKAN"
                echo "=============================================="

                IDS=$(echo "$MY_IDS" | \
                    tr -d '[]' | \
                    tr ',' ' ')

                JUMLAH=0

                for ID in $IDS; do

                    ID=$(echo "$ID" | xargs)

                    if [[ "$ID" =~ ^[0-9]+$ ]]; then

                        JUMLAH=$((JUMLAH + 1))

                        show_land "$ID"

                    fi

                done

                echo ""
                echo "Total tanah Anda: $JUMLAH"

            fi

            echo ""
            read -p "Tekan Enter untuk kembali..."

            ;;

        4)

            echo ""
            echo "Logout berhasil."
            sleep 1
            return

            ;;

        *)

            echo ""
            echo "❌ Pilihan tidak valid."
            sleep 1

            ;;

        esac

    done
}

# ============================================================
# MENU ADMIN
# ============================================================

admin_menu() {

    while true; do

        clear

        echo "=============================================="
        echo "       LANDCERT SECURE SYSTEM"
        echo "=============================================="
        echo ""
        echo "LOGIN SEBAGAI ADMIN"
        echo ""
        echo "Wallet:"
        echo "$USER_ADDRESS"
        echo ""
        echo "Kontrak:"
        echo "$KONTRAK"
        echo ""
        echo "1. Kelola Sengketa"
        echo "2. Transfer Tanah"
        echo "3. Semua Data Tanah"
        echo "4. Logout"
        echo ""

        read -p "Pilih menu (1-4): " PILIHAN

        case "$PILIHAN" in

        1)

            clear

            echo "=============================================="
            echo "             KELOLA SENGKETA"
            echo "=============================================="
            echo ""

            read -p "Masukkan ID Tanah: " ID
            read -p "Blokir tanah? (y/n): " STATUS

            if [ "$STATUS" = "y" ]; then
                VALUE="true"
            else
                VALUE="false"
            fi

            HASIL=$(cast send \
                "$KONTRAK" \
                "setDisputeStatus(uint256,bool)" \
                "$ID" \
                "$VALUE" \
                --rpc-url "$RPC_URL" \
                --private-key "$ADMIN_PK" \
                2>&1)

            echo "$HASIL"

            read -p "Tekan Enter..."

            ;;

        2)

            clear

            echo "=============================================="
            echo "             TRANSFER KEPEMILIKAN"
            echo "=============================================="
            echo ""

            read -p "Masukkan ID Tanah: " ID
            read -p "Masukkan Nama Pemilik Baru: " PEMILIK_BARU

            HASIL=$(cast send \
                "$KONTRAK" \
                "transferOwnership(uint256,string)" \
                "$ID" \
                "$PEMILIK_BARU" \
                --rpc-url "$RPC_URL" \
                --private-key "$ADMIN_PK" \
                2>&1)

            echo "$HASIL"

            read -p "Tekan Enter..."

            ;;

        3)

            clear

            echo "=============================================="
            echo "             SEMUA DATA TANAH"
            echo "=============================================="
            echo ""

            ALL_IDS=$(cast call \
                "$KONTRAK" \
                "getAllCertificateIds()(uint256[])" \
                --rpc-url "$RPC_URL" \
                2>/dev/null)

            echo "ID:"
            echo "$ALL_IDS"
            echo ""

            IDS=$(echo "$ALL_IDS" | tr -d '[]' | tr ',' ' ')

            JUMLAH=0

            for ID in $IDS; do

                ID=$(echo "$ID" | xargs)

                if [[ "$ID" =~ ^[0-9]+$ ]]; then

                    JUMLAH=$((JUMLAH + 1))

                    show_land "$ID"

                fi

            done

            echo ""
            echo "Total tanah: $JUMLAH"

            read -p "Tekan Enter..."

            ;;

        4)

            echo "Logout berhasil."
            sleep 1
            return

            ;;

        *)

            echo "❌ Pilihan tidak valid."
            sleep 1

            ;;

        esac

    done
}

# ============================================================
# LOGIN
# ============================================================

while true; do

    clear

    echo "=============================================="
    echo "       LANDCERT SECURE SYSTEM"
    echo "=============================================="
    echo ""
    echo "LOGIN"
    echo ""
    echo "Private Key Wallet:"
    echo "Ketik exit untuk keluar."
    echo ""

    read -p "Private Key: " USER_PK

    if [[ "${USER_PK,,}" = "exit" ]]; then

        echo "Terima kasih telah menggunakan LandCert."
        exit 0

    fi

    if [[ ! "$USER_PK" =~ ^0x ]]; then
        USER_PK="0x$USER_PK"
    fi

    USER_ADDRESS=$(cast wallet address \
        --private-key "$USER_PK" \
        2>/dev/null)

    if [ -z "$USER_ADDRESS" ]; then

        echo ""
        echo "❌ Private Key tidak valid."

        read -p "Tekan Enter..."

        continue

    fi

    if [ "${USER_ADDRESS,,}" = "${ADMIN_ADDRESS,,}" ]; then

        admin_menu

    else

        user_menu

    fi

done
