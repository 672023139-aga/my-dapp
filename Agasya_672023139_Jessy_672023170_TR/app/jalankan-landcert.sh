#!/bin/bash

# ====================================================================
# CONFIGURATION
# ====================================================================
RPC_URL="http://127.0.0.1:8545"
KONTRAK="0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
ADMIN_ADDRESS="0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
ADMIN_PK="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
NJOP_PER_M2=1000000 

# Mendeteksi folder Downloads Windows secara otomatis
WINDOWS_USER=$(cmd.exe /c "echo %username%" 2>/dev/null | tr -d '\r')
if [ -n "$WINDOWS_USER" ] && [ -d "/mnt/c/Users/$WINDOWS_USER/Downloads" ]; then
    TARGET_DIR="/mnt/c/Users/$WINDOWS_USER/Downloads"
else
    TARGET_DIR="."
fi

while true; do
    clear
    echo "===================================================="
    echo "          WELCOME TO LANDCERT SECURE SYSTEM         "
    echo "===================================================="
    echo " Silahkan masukkan Private Key Anda untuk Login."
    echo " Ketik 'exit' jika ingin menutup aplikasi."
    echo "----------------------------------------------------"
    read -p "Masukkan Private Key Wallet Anda: " USER_PK
    echo ""

    if [[ "${USER_PK,,}" == "exit" ]]; then
        echo "Terima kasih telah menggunakan LandCert Secure System. Goodbye!"
        exit 0
    fi

    if [[ ! "$USER_PK" =~ ^0x ]]; then
        USER_PK="0x$USER_PK"
    fi

    USER_ADDRESS=$(cast wallet address --private-key "$USER_PK" 2>/dev/null)

    if [ -z "$USER_ADDRESS" ]; then
        echo "❌ LOGIN GAGAL: Private Key tidak valid atau Anvil mati!"
        read -p "Tekan [Enter]..."
        continue
    fi

    if [ "${USER_ADDRESS,,}" == "${ADMIN_ADDRESS,,}" ]; then
        ROLE="ADMIN (BADAN PERTANAHAN / GOVT)"
    else
        ROLE="USER / MASYARAKAT (WAJIB PAJAK)"
    fi

    tampilkan_kop() {
        clear
        echo "===================================================="
        echo "          LANDCERT SMART GOVERNMENT SYSTEM          "
        echo "===================================================="
        echo " KONTRAK AKTIF : $KONTRAK"
        echo " LOGIN SEBAGAI : $ROLE"
        echo " ALAMAT WALLET : $USER_ADDRESS"
        echo "===================================================="
    }

    while true; do
        tampilkan_kop
        
        if [ "${USER_ADDRESS,,}" == "${ADMIN_ADDRESS,,}" ]; then
            echo "[ HALAMAN UTAMA: DIREKTORAT ADMIN GOVT ]"
            echo "1. Daftarkan Sertifikat Tanah Baru"
            echo "2. Kelola Status Sengketa (Blokir Aset)"
            echo "3. Transfer Kepemilikan (Jual Beli / Balik Nama)"
            echo "4. Periksa Detail & Riwayat Tanah (Publik)"
            echo "5. LOGOUT (Kembali ke Layar Login)"
            echo "----------------------------------------------------"
            read -p "Pilih menu Admin (1-5): " pilihan_admin
            
            case $pilihan_admin in
                1) pilihan=1 ;;
                2) pilihan=2 ;;
                3) pilihan=4 ;; 
                4) pilihan=5 ;; 
                5) pilihan=6 ;; 
                *) echo "Pilihan tidak valid"; sleep 1; continue ;;
            esac
        else
            echo "[ HALAMAN UTAMA: PORTAL LAYANAN MASYARAKAT ]"
            echo "1. Simulasi & Pembayaran Pajak PBB"
            echo "2. Periksa Detail & Riwayat Tanah (Melihat Saja)"
            echo "3. LOGOUT (Kembali ke Layar Login)"
            echo "----------------------------------------------------"
            read -p "Pilih menu Warga (1-3): " pilihan_user
            
            case $pilihan_user in
                1) pilihan=3 ;; 
                2) pilihan=5 ;; 
                3) pilihan=6 ;; 
                *) echo "Pilihan tidak valid"; sleep 1; continue ;;
            esac
        fi

        if [ "$pilihan" -eq 6 ]; then
            break 
        fi

        case $pilihan in
            1)
                echo -e "\n--- DAFTARKAN SERTIFIKAT BARU ---"
                echo "ID Sertifikat akan dibuat otomatis oleh Blockchain."
                read -p "Masukkan Lokasi Tanah: " lokasi
                read -p "Masukkan Luas Tanah (m2): " luas
                read -p "Masukkan Nama Pemilik: " pemilik
                
                CLEAN_HEX=$(echo "$cert_input" | sed 's/^0x//')
                printf -v PAD_HEX "%-64s" "$CLEAN_HEX"
                CERT_ID="0x${PAD_HEX// /0}"

                CLEAN_HEX=$(echo "$cert_input" | sed 's/^0x//')
                printf -v PAD_HEX "%-64s" "$CLEAN_HEX"
                CERT_ID="0x${PAD_HEX// /0}"
                cast send "$KONTRAK" "registerLand(bytes32,string,uint256,string)" "$CERT_ID" "$lokasi" "$luas" "$pemilik" --rpc-url "$RPC_URL" --private-key "$USER_PK"
                read -p "Tekan [Enter]..."
                ;;
            2)
                echo -e "\n--- KELOLA STATUS SENGKETA ---"
                read -p "Masukkan ID Sertifikat: " cert_input
                read -p "Kunci Sengketa? (y/n): " status_pilih
                [ "$status_pilih" == "y" ] && STATUS="true" || STATUS="false"
                CLEAN_HEX=$(echo "$cert_input" | sed 's/^0x//')
                printf -v PAD_HEX "%-64s" "$CLEAN_HEX"
                CERT_ID="0x${PAD_HEX// /0}"
                1)
    echo -e "\n--- DAFTARKAN SERTIFIKAT BARU ---"

    echo "ID Sertifikat akan dibuat otomatis oleh Blockchain."

    read -p "Masukkan Lokasi Tanah: " lokasi
    read -p "Masukkan Luas Tanah (m2): " luas
    read -p "Masukkan Nama Pemilik: " pemilik

    HASIL=$(cast send "$KONTRAK" \
        "registerLand(string,uint256,string)" \
        "$lokasi" \
        "$luas" \
        "$pemilik" \
        --rpc-url "$RPC_URL" \
        --private-key "$USER_PK" \
        2>&1)

    echo "$HASIL"

    if [[ "$HASIL" == *"transactionHash"* ]]; then
        echo ""
        echo "✅ SERTIFIKAT BERHASIL DIDAFTARKAN!"
        echo "ID dibuat otomatis oleh Blockchain."
    fi

    read -p "Tekan [Enter]..."
    ;;
                read -p "Tekan [Enter]..."
                ;;
            3)
                echo -e "\n--- SIMULASI & PEMBAYARAN PAJAK PBB ---"
                read -p "Masukkan ID Sertifikat Tanah: " cert_input
                CLEAN_HEX=$(echo "$cert_input" | sed 's/^0x//')
                printf -v PAD_HEX "%-64s" "$CLEAN_HEX"
                CERT_ID="0x${PAD_HEX// /0}"
                
                DATA=$(cast call "$KONTRAK" "getLand(bytes32)(string,uint256,string,bool,bool,bool)" "$CERT_ID" --rpc-url "$RPC_URL" 2>/dev/null)
                if [ -z "$DATA" ]; then
                    echo "❌ Sertifikat tidak ditemukan!"
                else
                    CLEAN_DATA=$(echo "$DATA" | sed 's/"//g')
                    IFS=$'\n' read -rd '' -a LINES <<< "$CLEAN_DATA"
                    LOKASI=$(echo "${LINES[0]}" | xargs)
                    LUAS=$(echo "${LINES[1]}" | xargs)
                    PEMILIK=$(echo "${LINES[2]}" | xargs)
                    TAX_STATUS=$(echo "${LINES[5]}" | xargs)

                    TOTAL_NJOP=$(( LUAS * NJOP_PER_M2 ))
                    PAJAK_PBB=$(( TOTAL_NJOP / 1000 ))

                    echo "----------------------------------------------------"
                    echo "   Nama Wajib Pajak : $PEMILIK"
                    echo "   Total Tagihan    : Rp $PAJAK_PBB"
                    echo "   Status Saat Ini  : $( [ "$TAX_STATUS" == "true" ] && echo "LUNAS" || echo "BELUM BAYAR" )"
                    echo "----------------------------------------------------"

                    CETAK_NOTA="n"
                    if [ "$TAX_STATUS" == "false" ]; then
                        read -p "Bayar pajak sekarang? (y/n): " konfirmasi
                        if [ "$konfirmasi" == "y" ]; then
                            echo "Mengirim pelunasan pajak dengan otorisasi Admin..."
                            HASIL=$(cast send "$KONTRAK" "payTax(bytes32)" "$CERT_ID" --rpc-url "$RPC_URL" --private-key "$ADMIN_PK" 2>&1)
                            if [[ $HASIL == *"revert"* ]]; then
                                echo "❌ Gagal memproses pembayaran pajak!"
                            else
                                echo "✅ Pajak berhasil dibayar & status sinkron di Blockchain!"
                                CETAK_NOTA="y"
                            fi
                        fi
                    else
                        echo "ℹ️ Pajak sudah lunas. Mengunduh ulang nota pembayaran..."
                        CETAK_NOTA="y"
                    fi

                    if [ "$CETAK_NOTA" == "y" ]; then
                        NAMA_FILE="$TARGET_DIR/nota_pajak_${cert_input}.txt"
                        {
                            echo "==============================================="
                            echo "              NOTA PELUNASAN PAJAK PBB         "
                            echo "              LANDCERT SECURE BLOCKCHAIN       "
                            echo "==============================================="
                            echo " Tanggal Cetak    : $(date)"
                            echo " ID Sertifikat    : $cert_input"
                            echo " Nama Wajib Pajak : $PEMILIK"
                            echo " Lokasi Aset      : $LOKASI"
                            echo " Luas Tanah       : $LUAS m2"
                            echo "-----------------------------------------------"
                            echo " TOTAL NJOP       : Rp $TOTAL_NJOP"
                            echo " PAJAK TERBAYAR   : Rp $PAJAK_PBB"
                            echo " STATUS TRANSAKSI : LUNAS (TERCATAT DI BLOCKCHAIN)"
                            echo "==============================================="
                        } > "$NAMA_FILE"
                        echo -e "\n📥 NOTA PEMBAYARAN TELAH DI-GENERATE TERCETAK!"
                        echo "File tersimpan sebagai: $NAMA_FILE"
                    fi
                fi
                read -p "Tekan [Enter]..."
                ;;
            4)
                echo -e "\n--- TRANSFER KEPEMILIKAN (BALIK NAMA) ---"
                read -p "Masukkan ID Sertifikat Tanah: " cert_input
                read -p "Masukkan Nama Pemilik Baru: " pembeli
                CLEAN_HEX=$(echo "$cert_input" | sed 's/^0x//')
                printf -v PAD_HEX "%-64s" "$CLEAN_HEX"
                CERT_ID="0x${PAD_HEX// /0}"
                HASIL=$(cast send "$KONTRAK" "transferOwnership(bytes32,string)" "$CERT_ID" "$pembeli" --rpc-url "$RPC_URL" --private-key "$USER_PK" 2>&1)
                if [[ $HASIL == *"revert"* ]]; then
                    echo -e "\n❌ TRANSFER GAGAL!"
                    echo "Penyebab: $HASIL"
                else
                    echo -e "\n🔄 TRANSFER HAK MILIK SUKSES!"
                fi
                read -p "Tekan [Enter]..."
                ;;
            5)
                echo -e "\n--- DETAIL SERTIFIKAT ---"
                read -p "Masukkan ID Sertifikat: " cert_input
                CLEAN_HEX=$(echo "$cert_input" | sed 's/^0x//')
                printf -v PAD_HEX "%-64s" "$CLEAN_HEX"
                CERT_ID="0x${PAD_HEX// /0}"
                
                DATA=$(cast call "$KONTRAK" "getLand(bytes32)(string,uint256,string,bool,bool,bool)" "$CERT_ID" --rpc-url "$RPC_URL" 2>&1)
                if [[ $DATA == *"revert"* || -z "$DATA" ]]; then
                    echo "❌ Data sertifikat tidak ditemukan!"
                else
                    CLEAN_DATA=$(echo "$DATA" | sed 's/"//g')
                    IFS=$'\n' read -rd '' -a LINES <<< "$CLEAN_DATA"
                    echo -e "\n🔍 DETAIL DATA BLOCKCHAIN STATE SUKSES DIREAD:"
                    echo "----------------------------------------------------"
                    echo "   ID Sertifikat    : $CERT_ID"
                    echo "   Nama Pemilik     : $(echo "${LINES[2]}" | xargs)"
                    echo "   Luas Tanah       : $(echo "${LINES[1]}" | xargs) m2"
                    echo "   Lokasi / Alamat  : $(echo "${LINES[0]}" | xargs)"
                    echo "   Status Sengketa  : $( [ "$(echo "${LINES[4]}" | xargs)" == "true" ] && echo "⚠️ YA (TERBLOKIR)" || echo "✅ TIDAK (AMAN)" )"
                    echo "   Status Pajak PBB : $( [ "$(echo "${LINES[5]}" | xargs)" == "true" ] && echo "✅ LUNAS" || echo "❌ BELUM BAYAR" )"
                    echo "----------------------------------------------------"
                fi
                read -p "Tekan [Enter]..."
                ;;
        esac
    done
done
