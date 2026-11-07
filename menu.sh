#!/bin/bash
# BADVPN PRO (RUST EDITION)
# TODO EM UM: INSTALAÇÃO, GESTÃO, TURBO, OTIMIZAÇÃO UDP E DASHBOARD

REPO_URL="https://github.com/PhoenixxZ2023/badvpnpro"
SERVICE_DIR="/etc/systemd/system"
BIN="/usr/bin/badvpn-udpgw"
LOG="/var/log/badvpn.log"
DASHBOARD="/opt/badvpn-dashboard.py"

# CORES COM NEGRITO FORÇADO (\e[1;...)
ROJO="\e[1;31m"
VERDE="\e[1;32m"
AMARILLO="\e[1;33m"
AZUL="\e[1;34m"
MORADO="\e[1;35m"
BRANCO="\e[1;37m"
RESET="\e[0m"

function log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG; }

function banner() {
    clear
    echo -e "${MORADO}==============================================${RESET}"
    echo -e "${VERDE}       BADVPN PRO (RUST) – MENU ${RESET}"
    echo -e "${MORADO}==============================================${RESET}"
}

function check_root() {
    if [[ $EUID -ne 0 ]]; then echo -e "${ROJO}VOCÊ DEVE EXECUTAR ESTE SCRIPT COMO ROOT!${RESET}"; exit 1; fi
}

function check_installed() { [[ -x "$BIN" ]]; }

# ==================== INSTALAÇÃO ====================
function install_badvpn() {
    banner
    echo -e "${AMARILLO}1/4 INSTALANDO DEPENDÊNCIAS DO SISTEMA...${RESET}"
    apt update -y && apt install -y build-essential git curl python3 python3-pip net-tools lsof >/dev/null 2>&1
    pip3 install flask psutil --break-system-packages >/dev/null 2>&1

    echo -e "${AMARILLO}2/4 INSTALANDO COMPILADOR RUST (CARGO)...${RESET}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1
    source "$HOME/.cargo/env"

    echo -e "${AMARILLO}3/4 BAIXANDO E COMPILANDO BADVPN PRO (PODE DEMORAR UNS MINUTOS)...${RESET}"
    cd /opt
    rm -rf badvpnpro
    git clone $REPO_URL >/dev/null 2>&1
    cd badvpnpro
    cargo build --release >/dev/null 2>&1
    cp target/release/badvpn-udpgw $BIN
    chmod +x $BIN

    echo -e "${AMARILLO}4/4 CONFIGURANDO DASHBOARD...${RESET}"
    cp dashboard.py $DASHBOARD
    chmod +x $DASHBOARD

    echo -e "${VERDE}✔ INSTALAÇÃO DO BADVPN PRO CONCLUÍDA COM SUCESSO!${RESET}"
    log "BADVPN RUST INSTALADO VIA PHOENIXXZ2023"
}

# ==================== GESTÃO DE PORTAS ====================
function add_port() {
    banner
    echo -ne "${BRANCO}PORTA PARA ADICIONAR: ${RESET}"
    read port
    [[ ! "$port" =~ ^[0-9]+$ ]] && { echo -e "${ROJO}PORTA INVÁLIDA!${RESET}"; return; }
cat > ${SERVICE_DIR}/badvpn-${port}.service <<EOF
[Unit]
Description=BADVPN UDPGW (RUST) NA PORTA ${port}
After=network.target
[Service]
ExecStart=${BIN} --listen-addr 127.0.0.1:${port} --max-clients 1000 --max-connections-for-client 10 --client-socket-sndbuf 256000
Nice=-10
Restart=always
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable badvpn-${port}.service >/dev/null 2>&1
    systemctl start badvpn-${port}.service >/dev/null 2>&1
    echo -e "${VERDE}✔ PORTA ${port} ATIVADA COM CAPACIDADE PARA 1000 CLIENTES.${RESET}"
}

function remove_port() {
    banner
    echo -ne "${BRANCO}PORTA PARA REMOVER: ${RESET}"
    read port
    systemctl disable --now badvpn-${port}.service >/dev/null 2>&1
    rm -f ${SERVICE_DIR}/badvpn-${port}.service
    systemctl daemon-reload
    echo -e "${VERDE}✔ PORTA ${port} REMOVIDA COM SUCESSO.${RESET}"
}

function list_ports() {
    banner
    echo -e "${AZUL}PORTAS BADVPN ATIVAS:${RESET}"
    ls ${SERVICE_DIR} | grep badvpn | grep -v turbo | sed 's/.service//g'
}

function status_port() {
    banner
    echo -ne "${BRANCO}PORTA: ${RESET}"
    read port
    systemctl status badvpn-${port}.service
}

# ==================== OTIMIZAÇÃO KERNEL ====================
function optimize_udp() {
    banner
    echo -e "${AMARILLO}APLICANDO OTIMIZAÇÃO EXTREMA DE REDE UDP (SYSCTL)...${RESET}"
    sysctl -w net.core.rmem_max=67108864
    sysctl -w net.core.wmem_max=67108864
    sysctl -w net.core.netdev_max_backlog=200000
    sysctl -w net.ipv4.udp_rmem_min=32768
    sysctl -w net.ipv4.udp_wmem_min=32768
    sysctl -w net.ipv4.udp_mem="4194304 8388608 16777216"
    sysctl -w net.core.optmem_max=65536
    sysctl -w net.ipv4.tcp_fastopen=3
    sysctl -w net.ipv4.ip_forward=1
cat > /etc/sysctl.d/99-badvpn-udp.conf <<EOF
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.core.netdev_max_backlog=200000
net.ipv4.udp_rmem_min=32768
net.ipv4.udp_wmem_min=32768
net.ipv4.udp_mem=4194304 8388608 16777216
net.core.optmem_max=65536
net.ipv4.tcp_fastopen=3
net.ipv4.ip_forward=1
EOF
    sysctl --system >/dev/null 2>&1
    echo -e "${VERDE}✔ OTIMIZAÇÃO APLICADA AO KERNEL!${RESET}"
}

# ==================== MODO TURBO ====================
function modo_turbo_badvpn() {
    banner
    echo -e "${ROJO}🔥 ATIVANDO MODO TURBO MULTI-THREAD 🔥${RESET}"
    echo -ne "${BRANCO}PORTA TURBO (RECOMENDADO 7300): ${RESET}"
    read turbo_port
    optimize_udp 
cat > ${SERVICE_DIR}/badvpn-turbo-${turbo_port}.service <<EOF
[Unit]
Description=BADVPN TURBO (RUST) NA PORTA ${turbo_port}
After=network.target
[Service]
ExecStart=${BIN} --listen-addr 127.0.0.1:${turbo_port} --max-clients 2000 --client-socket-sndbuf 1048576
Nice=-15
Restart=always
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable badvpn-turbo-${turbo_port}.service >/dev/null 2>&1
    systemctl start badvpn-turbo-${turbo_port}.service >/dev/null 2>&1
    echo -e "${VERDE}✔ MODO TURBO ATIVO NA PORTA ${turbo_port}${RESET}"
}

# ==================== DASHBOARD ====================
function launch_dashboard() {
    banner
    pkill -f "python3 $DASHBOARD" >/dev/null 2>&1
    nohup python3 $DASHBOARD >/dev/null 2>&1 &
    echo -e "${VERDE}✔ DASHBOARD RODANDO! ACESSE: HTTP://<IP_DA_VPS>:8080${RESET}"
}

function stop_dashboard() {
    banner
    pkill -f "python3 $DASHBOARD" >/dev/null 2>&1
    echo -e "${VERDE}✔ DASHBOARD PARADO.${RESET}"
}

# ==================== MENU ====================
function menu() {
    banner
    echo -e "${AMARILLO}1)${BRANCO} INSTALAR BADVPN (RUST EDITION)${RESET}"
    echo -e "${AMARILLO}2)${BRANCO} ADICIONAR PORTA NORMAL${RESET}"
    echo -e "${AMARILLO}3)${BRANCO} REMOVER PORTA${RESET}"
    echo -e "${AMARILLO}4)${BRANCO} LISTAR PORTAS ATIVAS${RESET}"
    echo -e "${AMARILLO}5)${BRANCO} STATUS DE UMA PORTA${RESET}"
    echo -e "${AMARILLO}6)${BRANCO} VER LOGS DO SISTEMA${RESET}"
    echo -e "${AMARILLO}7)${BRANCO} OTIMIZAR REDE (SYSCTL)${RESET}"
    echo -e "${AMARILLO}8)${BRANCO} ATIVAR MODO TURBO 🔥${RESET}"
    echo -e "${AMARILLO}9)${BRANCO} INICIAR DASHBOARD WEB${RESET}"
    echo -e "${AMARILLO}10)${BRANCO} PARAR DASHBOARD WEB${RESET}"
    echo -e "${AMARILLO}11)${BRANCO} SAIR${RESET}"
    echo ""
    echo -ne "${BRANCO}OPÇÃO: ${RESET}"
    read op
    case $op in
        1) install_badvpn ;;
        2) check_installed && add_port || echo -e "${ROJO}INSTALE O BADVPN PRIMEIRO (OPÇÃO 1)${RESET}" ;;
        3) remove_port ;;
        4) list_ports ;;
        5) status_port ;;
        6) less $LOG ;;
        7) optimize_udp ;;
        8) check_installed && modo_turbo_badvpn || echo -e "${ROJO}INSTALE O BADVPN PRIMEIRO (OPÇÃO 1)${RESET}" ;;
        9) launch_dashboard ;;
        10) stop_dashboard ;;
        11) exit 0 ;;
        *) echo -e "${ROJO}OPÇÃO INVÁLIDA!${RESET}" ;;
    esac
    echo ""
    echo -ne "${BRANCO}APERTE ENTER PARA VOLTAR AO MENU...${RESET}" 
    read
    menu
}

check_root
menu
