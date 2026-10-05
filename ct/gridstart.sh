#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: jouw-naam
# License: MIT
# Source: https://github.com/mblancolabs/gridstart

APP="GridStart"
var_tags="f1;dashboard"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_os="debian"
var_version="12"
var_unprivileged="1"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/gridstart ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Updating ${APP}"
  cd /opt/gridstart
  git pull
  npm install
  npm run build
  systemctl restart gridstart
  msg_ok "Updated ${APP}"
  exit
}

# Start de installatie
if [[ ! -d /opt/gridstart ]]; then
  msg_info "Installing Dependencies"
  $STD apt-get update
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
  npm install
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
  npm run build
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
fi

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:5000${CL}"
