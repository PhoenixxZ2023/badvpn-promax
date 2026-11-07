#!/bin/bash
# INSTALADOR BADVPN PRO (RUST EDITION)

# CORES COM NEGRITO FORÇADO
ROJO="\e[1;31m"
VERDE="\e[1;32m"
AMARILLO="\e[1;33m"
BRANCO="\e[1;37m"
RESET="\e[0m"

clear
echo -e "${VERDE}==============================================${RESET}"
echo -e "${BRANCO}      INICIANDO SETUP DO BADVPN PRO (RUST)${RESET}"
echo -e "${VERDE}==============================================${RESET}"
echo ""

# VERIFICAÇÃO DE ROOT
if [[ $EUID -ne 0 ]]; then
    echo -e "${ROJO}ERRO: VOCÊ DEVE EXECUTAR ESTE SCRIPT COMO ROOT!${RESET}"
    echo -e "${BRANCO}DIGITE: sudo su${RESET}"
    exit 1
fi

echo -e "${AMARILLO}BAIXANDO O MENU DE GERENCIAMENTO DO GITHUB...${RESET}"
wget -q -O /root/menu.sh https://raw.githubusercontent.com/PhoenixxZ2023/badvpnpro/main/menu.sh

if [[ -f "/root/menu.sh" ]]; then
    chmod +x /root/menu.sh
    echo -e "${VERDE}✔ DOWNLOAD CONCLUÍDO!${RESET}"
    
    echo "/root/menu.sh" > /usr/local/bin/menu
    chmod +x /usr/local/bin/menu

    echo -e "${BRANCO}INICIANDO O SISTEMA...${RESET}"
    sleep 2
    /root/menu.sh
else
    echo -e "${ROJO}ERRO AO BAIXAR O SCRIPT! VERIFIQUE SE O REPOSITÓRIO ESTÁ PÚBLICO E SE O LINK ESTÁ CORRETO.${RESET}"
fi
