#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: OdynBrouwer
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/mblancolabs/gridstart

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl git sudo
msg_ok "Installed Dependencies"

msg_info "Installing Node.js 22"
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
$STD apt-get install -y nodejs
msg_ok "Installed Node.js 22"

msg_info "Cloning GridStart"
git clone https://github.com/mblancolabs/gridstart.git /opt/gridstart
cd /opt/gridstart
msg_ok "Cloned GridStart"

msg_info "Installing Dependencies"
$STD npm install
msg_ok "Installed Dependencies"

msg_info "Creating .env File"
cat <<EOF > /opt/gridstart/.env
NODE_ENV=production
PORT=5000
CORS_ORIGIN=http://localhost:5173
CSRF_SECRET=$(openssl rand -hex 32)
EOF
msg_ok "Created .env File"

msg_info "Building GridStart"
$STD npm run build
msg_ok "Built GridStart"

msg_info "Creating Service"
cat <<EOF > /etc/systemd/system/gridstart.service
[Unit]
Description=GridStart Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/gridstart
ExecStart=/usr/bin/npm run start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now gridstart
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
