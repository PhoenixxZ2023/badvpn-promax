# 🚀 BadVPN Pro (Rust Edition)

Uma reescrita completa e otimizada do gateway `badvpn-udpgw` utilizando a linguagem **Rust** e o motor assíncrono **Tokio**. Ideal para servidores de alta demanda (túneis SSH, jogos online, chamadas de vídeo), superando as limitações do código original em C.

## ✨ Diferenciais
- **Multi-thread Nativo:** Distribui milhares de conexões UDP por todos os núcleos da CPU.
- **Limpeza Automática de Portas:** Conexões inativas por mais de 120s são destruídas, prevenindo travamentos por falta de portas (*ephemeral port exhaustion*).
- **Dashboard Web Integrado:** Monitore o consumo de CPU, RAM e PIDs de cada porta.
- **Evicção Inteligente (LRU):** Proteção automática contra sobrecarga de conexões por cliente.

## ⚙️ Instalação Rápida
Execute o comando abaixo como `root` no seu VPS:

````
wget -O install.sh [https://raw.githubusercontent.com/PhoenixxZ2023/badvpnpro/main/install.sh](https://raw.githubusercontent.com/PhoenixxZ2023/badvpnpro/main/install.sh) && chmod +x install.sh && ./install.sh
````

````bash
wget -O install.sh https://raw.githubusercontent.com/PhoenixxZ2023/badvpnpro/main/install.sh && && chmod +x install.sh && ./install.sh
