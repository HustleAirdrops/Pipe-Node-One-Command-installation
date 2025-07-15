#!/bin/bash

# ==================== Aashish's Pipe Node Manager ====================
# Created by: Aashish 💻
# ======================================================================

# Color Codes
set -e
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[38;5;208m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Paths
ARCHIVE="pop-v0.3.2-linux-x64.tar.gz"
INSTALL_DIR="/opt/popcache"
POP_BIN="$INSTALL_DIR/pop"

# Header
show_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
    echo "│  ██╗░░██╗██╗░░░██╗░██████╗████████╗██╗░░░░░███████╗  ░█████╗░██╗██████╗░██████╗░██████╗░░█████╗░██████╗░░██████╗  │"
    echo "│  ██║░░██║██║░░░██║██╔════╝╚══██╔══╝██║░░░░░██╔════╝  ██╔══██╗██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝  │"
    echo "│  ███████║██║░░░██║╚█████╗░░░░██║░░░██║░░░░░█████╗░░  ███████║██║██████╔╝██║░░██║██████╔╝██║░░██║██████╔╝╚█████╗░  │"
    echo "│  ██╔══██║██║░░░██║░╚═══██╗░░░██║░░░██║░░░░░██╔══╝░░  ██╔══██║██║██╔══██╗██║░░██║██╔══██╗██║░░██║██╔═══╝░░╚═══██╗  │"
    echo "│  ██║░░██║╚██████╔╝██████╔╝░░░██║░░░███████╗███████╗  ██║░░██║██║██║░░██║██████╔╝██║░░██║╚█████╔╝██║░░░░░██████╔╝  │"
    echo "│  ╚═╝░░╚═╝░╚═════╝░╚═════╝░░░░╚═╝░░░╚══════╝╚══════╝  ╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝░╚════╝░╚═╝░░░░░╚═════╝░  │"
    echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
    echo -e "${YELLOW}                  🚀 Pipe Node Manager by Aashish 🚀${NC}"
    echo -e "${YELLOW}              GitHub: https://github.com/HustleAirdrops${NC}"
    echo -e "${YELLOW}              Telegram: https://t.me/Hustle_Airdrops${NC}"
    echo -e "${GREEN}===============================================================================${NC}"
}

# === Function: Full Install ===
full_install() {
  echo -e "${YELLOW}🔹 Enter the following details to configure your POP Node:${NC}"
  read -rp "$(echo -e "${YELLOW}1️⃣ POP NAME (e.g. my-pop-node): ${NC}")" POP_NAME
  NODE_NAME="$POP_NAME"

  read -rp "$(echo -e "${YELLOW}2️⃣ Invite Code: ${NC}")" INVITE_CODE

  LOCATION=$(curl -s https://ipinfo.io/json | jq -r '.region + ", " + .country')
  echo -e "${ORANGE}🌍 Auto-detected location: $LOCATION${NC}"

  read -rp "$(echo -e "${YELLOW}3️⃣ Solana Wallet Address: ${NC}")" SOLANA_PUBKEY
  read -rp "$(echo -e "${YELLOW}4️⃣ Memory Cache Size in MB (e.g. 4096): ${NC}")" MEMORY_SIZE_MB
  read -rp "$(echo -e "${YELLOW}5️⃣ Disk Cache Size in GB (e.g. 100): ${NC}")" DISK_SIZE_GB

  read -rp "$(echo -e "${YELLOW}6️⃣ Your Full Name: ${NC}")" NAME
  read -rp "$(echo -e "${YELLOW}7️⃣ Email Address: ${NC}")" EMAIL
  read -rp "$(echo -e "${YELLOW}8️⃣ Telegram Username (without @): ${NC}")" TELEGRAM

  WEBSITE="https://t.me/$TELEGRAM"
  TWITTER=""
  DISCORD=""
  WORKERS=0

  echo -e "${ORANGE}📦 Installing required packages...${NC}"
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev screen ufw -y

  echo -e "${ORANGE}🔐 Setting firewall rules...${NC}"
  sudo ufw allow 22
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  sudo ufw allow ssh
  sudo ufw --force enable
  sudo ufw reload

  echo -e "${ORANGE}📁 Setting up $INSTALL_DIR...${NC}"
  sudo mkdir -p "$INSTALL_DIR/logs"
  sudo chmod 777 "$INSTALL_DIR"

  if [ -f "$ARCHIVE" ]; then
    echo -e "${GREEN}✅ Using existing $ARCHIVE file...${NC}"
  else
    echo -e "${ORANGE}⬇️ Downloading PoP binary...${NC}"
    sudo wget -q https://download.pipe.network/static/$ARCHIVE -O $ARCHIVE
  fi

  sudo tar -xzf "$ARCHIVE" -C "$INSTALL_DIR"
  sudo chmod +x "$POP_BIN"
  sudo chmod 777 "$ARCHIVE"
  sudo useradd -m -s /bin/bash popcache || echo -e "${BLUE}ℹ️ User 'popcache' already exists.${NC}"
  sudo usermod -aG sudo popcache
  sudo chown -R popcache:popcache "$INSTALL_DIR"
  sudo ln -sf "$POP_BIN" /usr/local/bin/pop

  sudo tee /etc/sysctl.d/99-popcache.conf > /dev/null <<EOF
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 65535
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.core.wmem_max = 16777216
net.core.rmem_max = 16777216
EOF

  sudo sysctl --system
  echo -e "* soft nofile 65535\n* hard nofile 65535" | sudo tee /etc/security/limits.d/popcache.conf > /dev/null

  sudo tee "$INSTALL_DIR/config.json" > /dev/null <<EOF
{
  "pop_name": "$POP_NAME",
  "pop_location": "$LOCATION",
  "invite_code": "$INVITE_CODE",
  "server": {
    "host": "0.0.0.0",
    "port": 443,
    "http_port": 80,
    "workers": $WORKERS
  },
  "cache_config": {
    "memory_cache_size_mb": $MEMORY_SIZE_MB,
    "disk_cache_path": "./cache",
    "disk_cache_size_gb": $DISK_SIZE_GB,
    "default_ttl_seconds": 86400,
    "respect_origin_headers": true,
    "max_cacheable_size_mb": 1024
  },
  "api_endpoints": {
    "base_url": "https://dataplane.pipenetwork.com"
  },
  "identity_config": {
    "node_name": "$NODE_NAME",
    "name": "$NAME",
    "email": "$EMAIL",
    "website": "$WEBSITE",
    "twitter": "$TWITTER",
    "discord": "$DISCORD",
    "telegram": "$TELEGRAM",
    "solana_pubkey": "$SOLANA_PUBKEY"
  }
}
EOF

  sudo chown popcache:popcache "$INSTALL_DIR/config.json"
  [ -f "$INSTALL_DIR/.pop.lock" ] && sudo rm -f "$INSTALL_DIR/.pop.lock"

  sudo -u popcache bash -c "cd $INSTALL_DIR && ./pop --validate-config"

  sudo tee /etc/systemd/system/popcache.service > /dev/null <<EOF
[Unit]
Description=POP Cache Node
After=network.target

[Service]
Type=simple
User=popcache
Group=popcache
WorkingDirectory=$INSTALL_DIR
ExecStart=$POP_BIN
Restart=always
RestartSec=5
LimitNOFILE=65535
StandardOutput=append:$INSTALL_DIR/logs/stdout.log
StandardError=append:$INSTALL_DIR/logs/stderr.log
Environment=POP_CONFIG_PATH=$INSTALL_DIR/config.json

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reexec
  sudo systemctl daemon-reload
  sudo systemctl enable popcache
  sudo systemctl restart popcache

  echo -e "${GREEN}✅ POP Node installed & running!${NC}"
  echo -e "${CYAN}📜 View logs: ${NC}journalctl -u popcache -f"
}


# === Logs Function ===
view_logs() {
  echo -e "${CYAN}📜 Showing live logs. Press Ctrl+C to exit.${NC}"
  sudo journalctl -u popcache -f
}

# === Info Function ===
show_info() {
  echo -e "${CYAN}📊 Metrics:${NC}"
  curl -sk http://localhost/metrics | jq .
  echo -e "\n${CYAN}🔍 State:${NC}"
  curl -sk http://localhost/state | jq .
  echo -e "\n${CYAN}❤️ Health:${NC}"
  curl -sk http://localhost/health | jq .
}

# === Delete Node ===
delete_node() {
  echo -e "${RED}⚠️ WARNING: This will remove the node completely!${NC}"
  read -p "❓ Are you sure? (y/n): " confirm
  if [[ "$confirm" == "y" ]]; then
    sudo systemctl stop popcache
    sudo systemctl disable popcache
    sudo rm -rf "$INSTALL_DIR"
    sudo rm -f /etc/systemd/system/popcache.service
    sudo userdel -r popcache 2>/dev/null || true
    echo -e "${GREEN}✅ Node deleted successfully.${NC}"
  else
    echo -e "${YELLOW}❌ Deletion cancelled.${NC}"
  fi
}

# === Main Menu ===
while true; do
    show_header
    echo -e "${BLUE}${BOLD}================ PIPE NODE MANAGER BY Aashish 💖 =================${NC}"
    echo -e " 1️⃣  Full Install"
    echo -e " 2️⃣  View Logs"
    echo -e " 3️⃣  Show POP Info"
    echo -e " 4️⃣  Delete Node"
    echo -e " 5️⃣  Exit"
    echo -e "${BLUE}============================================================================${NC}"
    read -rp "👉 Choose option (1-5): " choice

    case "$choice" in
        1) full_install ;;
        2) view_logs ;;
        3) show_info ;;
        4) delete_node ;;
        5) echo -e "${GREEN}👋 Exiting...${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid choice. Try again.${NC}"; sleep 2 ;;
    esac
done
