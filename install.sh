#!/bin/bash
# INSTALADOR BADVPN PRO (RUST EDITION)
# DESENVOLVEDOR: @TURBONET2023

# CORES COM NEGRITO FORÇADO
ROJO="\e[1;31m"
VERDE="\e[1;32m"
AMARILLO="\e[1;33m"
AZUL="\e[1;34m"
BRANCO="\e[1;37m"
RESET="\e[0m"

clear
echo -e "${VERDE}==============================================${RESET}"
echo -e "${BRANCO}      INICIANDO SETUP DO BADVPN PRO (RUST)${RESET}"
echo -e "${AZUL}             TELEGRAM: @TURBONET2023${RESET}"
echo -e "${VERDE}==============================================${RESET}"
echo ""

# VERIFICAÇÃO DE ROOT
if [[ $EUID -ne 0 ]]; then
    echo -e "${ROJO}ERRO: VOCÊ DEVE EXECUTAR ESTE SCRIPT COMO ROOT!${RESET}"
    echo -e "${BRANCO}DIGITE: sudo su${RESET}"
    exit 1
fi

echo -e "${AMARILLO}BAIXANDO O MENU DE GERENCIAMENTO DO GITHUB...${RESET}"
# CORREÇÃO: Nome do repositório (badvpn-promax) e nome do arquivo (menu.sh)
wget -q -O /root/menu.sh https://raw.githubusercontent.com/PhoenixxZ2023/badvpn-promax/master/menu.sh

if [[ -f "/root/menu.sh" ]]; then
    chmod +x /root/menu.sh
    echo -e "${VERDE}✔ DOWNLOAD CONCLUÍDO!${RESET}"
    
    # Cria o atalho com o comando badvpnpro de forma segura
    echo -e '#!/bin/bash\n/root/menu.sh' > /usr/local/bin/badvpnpro
    chmod +x /usr/local/bin/badvpnpro

    echo -e "${BRANCO}INICIANDO O SISTEMA...${RESET}"
    sleep 2
    badvpnpro
else
    echo -e "${ROJO}ERRO AO BAIXAR O SCRIPT! VERIFIQUE SE O REPOSITÓRIO ESTÁ PÚBLICO E O NOME DO ARQUIVO.${RESET}"
fi
