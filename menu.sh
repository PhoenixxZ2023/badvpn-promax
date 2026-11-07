#!/bin/bash
# BADVPN PRO MAX (RUST EDITION)
# TODO EM UM: INSTALAÇÃO, GESTÃO, TURBO, OTIMIZAÇÃO UDP E DASHBOARD

REPO_URL="https://github.com/PhoenixxZ2023/badvpn-promax.git"
SERVICE_DIR="/etc/systemd/system"
BIN="/usr/bin/badvpn-udpgw"
LOG="/var/log/badvpn.log"
DASHBOARD="/opt/badvpn-dashboard.py"

function log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG; }

function banner() {
    clear
    echo -e "\e[1;35m==============================================\e[0m"
    echo -e "\e[1;32m       BADVPN PRO (RUST) – MENU \e[0m"
    echo -e "\e[1;34m           TELEGRAM: @TURBONET2023\e[0m"
    echo -e "\e[1;35m==============================================\e[0m"
}

function check_root() {
    if [[ $EUID -ne 0 ]]; then echo -e "\e[1;31mVOCÊ DEVE EXECUTAR ESTE SCRIPT COMO ROOT!\e[0m"; exit 1; fi
}

function check_installed() { [[ -x "$BIN" ]]; }

# ==================== INSTALAÇÃO ====================
function install_badvpn() {
    banner
    echo -e "\e[1;33m1/4 INSTALANDO DEPENDÊNCIAS DO SISTEMA...\e[0m"
    apt update -y && apt install -y build-essential git curl python3 python3-pip net-tools lsof >/dev/null 2>&1
    pip3 install flask psutil --break-system-packages >/dev/null 2>&1

    echo -e "\e[1;33m2/4 INSTALANDO COMPILADOR RUST (CARGO)...\e[0m"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1
    source "$HOME/.cargo/env"

    echo -e "\e[1;33m3/4 BAIXANDO E COMPILANDO BADVPN PRO (PODE DEMORAR UNS MINUTOS)...\e[0m"
    cd /opt
    rm -rf badvpn-promax
    git clone $REPO_URL >/dev/null 2>&1
    cd badvpn-promax
    cargo build --release >/dev/null 2>&1
    cp target/release/badvpn-udpgw $BIN
    chmod +x $BIN

    echo -e "\e[1;33m4/4 CONFIGURANDO DASHBOARD...\e[0m"
    cp dashboard.py $DASHBOARD
    chmod +x $DASHBOARD

    echo -e "\e[1;32m✔ INSTALAÇÃO DO BADVPN PRO CONCLUÍDA COM SUCESSO!\e[0m"
    log "BADVPN RUST INSTALADO VIA PHOENIXXZ2023"
}

# ==================== GESTÃO DE PORTAS ====================
function add_port() {
    banner
    echo -ne "\e[1;37mPORTA PARA ADICIONAR: \e[0m"
    read port
    [[ ! "$port" =~ ^[0-9]+$ ]] && { echo -e "\e[1;31mPORTA INVÁLIDA!\e[0m"; return; }
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
    echo -e "\e[1;32m✔ PORTA ${port} ATIVADA COM CAPACIDADE PARA 1000 CLIENTES.\e[0m"
}

function remove_port() {
    banner
    echo -ne "\e[1;37mPORTA PARA REMOVER: \e[0m"
    read port
    systemctl disable --now badvpn-${port}.service >/dev/null 2>&1
    rm -f ${SERVICE_DIR}/badvpn-${port}.service
    systemctl daemon-reload
    echo -e "\e[1;32m✔ PORTA ${port} REMOVIDA COM SUCESSO.\e[0m"
}

function list_ports() {
    banner
    echo -e "\e[1;34mPORTAS BADVPN ATIVAS:\e[0m"
    ls ${SERVICE_DIR} | grep badvpn | grep -v turbo | sed 's/.service//g'
}

function status_port() {
    banner
    echo -ne "\e[1;37mPORTA: \e[0m"
    read port
    systemctl status badvpn-${port}.service
}

# ==================== OTIMIZAÇÃO KERNEL ====================
function optimize_udp() {
    banner
    echo -e "\e[1;33mAPLICANDO OTIMIZAÇÃO EXTREMA DE REDE UDP (SYSCTL)...\e[0m"
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
    echo -e "\e[1;32m✔ OTIMIZAÇÃO APLICADA AO KERNEL!\e[0m"
}

# ==================== MODO TURBO ====================
function modo_turbo_badvpn() {
    banner
    echo -e "\e[1;31m🔥 ATIVANDO MODO TURBO MULTI-THREAD 🔥\e[0m"
    echo -ne "\e[1;37mPORTA TURBO (RECOMENDADO 7300): \e[0m"
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
    echo -e "\e[1;32m✔ MODO TURBO ATIVO NA PORTA ${turbo_port}\e[0m"
}

# ==================== DASHBOARD ====================
function launch_dashboard() {
    banner
    pkill -f "python3 $DASHBOARD" >/dev/null 2>&1
    nohup python3 $DASHBOARD >/dev/null 2>&1 &
    echo -e "\e[1;32m✔ DASHBOARD RODANDO! ACESSE: HTTP://<IP_DA_VPS>:8080\e[0m"
}

function stop_dashboard() {
    banner
    pkill -f "python3 $DASHBOARD" >/dev/null 2>&1
    echo -e "\e[1;32m✔ DASHBOARD PARADO.\e[0m"
}

# ==================== MENU ====================
function menu() {
    banner
    echo -e "\e[1;33m[\e[1;31m01\e[1;33m]\e[1;36m INSTALAR BADVPN (RUST EDITION)\e[0m"
    echo -e "\e[1;33m[\e[1;31m02\e[1;33m]\e[1;36m ADICIONAR PORTA NORMAL\e[0m"
    echo -e "\e[1;33m[\e[1;31m03\e[1;33m]\e[1;36m REMOVER PORTA\e[0m"
    echo -e "\e[1;33m[\e[1;31m04\e[1;33m]\e[1;36m LISTAR PORTAS ATIVAS\e[0m"
    echo -e "\e[1;33m[\e[1;31m05\e[1;33m]\e[1;36m STATUS DE UMA PORTA\e[0m"
    echo -e "\e[1;33m[\e[1;31m06\e[1;33m]\e[1;36m VER LOGS DO SISTEMA\e[0m"
    echo -e "\e[1;33m[\e[1;31m07\e[1;33m]\e[1;36m OTIMIZAR REDE (SYSCTL)\e[0m"
    echo -e "\e[1;33m[\e[1;31m08\e[1;33m]\e[1;36m ATIVAR MODO TURBO 🔥\e[0m"
    echo -e "\e[1;33m[\e[1;31m09\e[1;33m]\e[1;36m INICIAR DASHBOARD WEB\e[0m"
    echo -e "\e[1;33m[\e[1;31m10\e[1;33m]\e[1;36m PARAR DASHBOARD WEB\e[0m"
    echo -e "\e[1;33m[\e[1;31m11\e[1;33m]\e[1;36m SAIR\e[0m"
    echo ""
    echo -ne "\e[1;37mOPÇÃO: \e[0m"
    read op
    case $op in
        1|01) install_badvpn ;;
        2|02) check_installed && add_port || echo -e "\e[1;31mINSTALE O BADVPN PRIMEIRO (OPÇÃO 01)\e[0m" ;;
        3|03) remove_port ;;
        4|04) list_ports ;;
        5|05) status_port ;;
        6|06) less $LOG ;;
        7|07) optimize_udp ;;
        8|08) check_installed && modo_turbo_badvpn || echo -e "\e[1;31mINSTALE O BADVPN PRIMEIRO (OPÇÃO 01)\e[0m" ;;
        9|09) launch_dashboard ;;
        10) stop_dashboard ;;
        11) exit 0 ;;
        *) echo -e "\e[1;31mOPÇÃO INVÁLIDA!\e[0m" ;;
    esac
    echo ""
    echo -ne "\e[1;37mAPERTE ENTER PARA VOLTAR AO MENU...\e[0m" 
    read
    menu
}

check_root
menu
