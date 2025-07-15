#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Typing effect function
typing_effect() {
    text="$1"
    delay=0.02
    for ((i=0; i<${#text}; i++)); do
        echo -ne "${text:$i:1}"
        sleep $delay
    done
    echo
}

clear
echo -e "${CYAN}"
typing_effect "==============================================="
typing_effect "          ASLEKAR ANTI CHEAT SYSTEM"
typing_effect "==============================================="
echo -e "${NC}"

# License check
echo
read -p "Enter your license key: " license_key

license_file="$HOME/keys.txt"

if grep -q "^$license_key:" "$license_file"; then
    expiry=$(grep "^$license_key:" "$license_file" | cut -d':' -f2)
    if [[ "$expiry" == "PERMANENT" ]]; then
        echo -e "${GREEN}[✔] Valid Permanent Key${NC}"
    else
        expiry_time=$(date -d "${expiry//_/ }" +%s)
        current_time=$(date +%s)
        if (( current_time < expiry_time )); then
            echo -e "${GREEN}[✔] Valid Key (expires at $expiry)${NC}"
        else
            echo -e "${RED}[✖] Key expired${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}[✖] Invalid Key${NC}"
    exit 1
fi

# Begin checks
suspect=0
echo
echo -e "${CYAN}[*] Bootloader & Security:${NC}"

bootloader_unlock=$(getprop ro.secureboot.lockstate)
flash_lock=$(getprop ro.boot.flash.locked)

if [[ "$bootloader_unlock" == "unlocked" ]]; then
    echo -e "${RED}ro.secureboot.lockstate: unlocked (Suspicious)${NC}"
    suspect=1
else
    echo -e "${GREEN}ro.secureboot.lockstate: locked (Safe)${NC}"
fi

if [[ "$flash_lock" == "0" ]]; then
    echo -e "${RED}ro.boot.flash.locked: 0 (Suspicious)${NC}"
    suspect=1
else
    echo -e "${GREEN}ro.boot.flash.locked: 1 (Safe)${NC}"
fi

echo
echo -e "${CYAN}[*] Root Binaries:${NC}"

root_bins=(
"/system/bin/su"
"/system/xbin/su"
"/sbin/su"
"/vendor/bin/su"
"/data/local/bin/su"
"/data/local/xbin/su"
)

for path in "${root_bins[@]}"; do
    if [[ -f "$path" ]]; then
        echo -e "${RED}$path : FOUND (Suspicious)${NC}"
        suspect=1
    else
        echo -e "${GREEN}$path : Not Found (Safe)${NC}"
    fi
done

echo
echo -e "${CYAN}[*] Magisk Check:${NC}"

if [[ -d "/sbin/.magisk" ]] || [[ -d "/data/adb/modules" ]]; then
    echo -e "${RED}Magisk modules found (Suspicious)${NC}"
    suspect=1
else
    echo -e "${GREEN}Magisk not found (Safe)${NC}"
fi

# Final Result
echo
echo -e "${YELLOW}====== FINAL SCAN RESULT ======${NC}"
if [[ "$suspect" == "1" ]]; then
    echo -e "${RED}⚠️ ROOT OR UNLOCK DETECTED${NC}"
else
    echo -e "${GREEN}✅ DEVICE IS SAFE${NC}"
fi
echo
