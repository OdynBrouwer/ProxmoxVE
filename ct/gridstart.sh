#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: OdynBrouwer
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/mblancolabs/gridstart

# BELANGRIJK: vertel de engine dat de scripts in JOUW fork staan
export COMMUNITY_SCRIPTS_URL="https://raw.githubusercontent.com/OdynBrouwer/ProxmoxVE/main"

source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

APP="GridStart"
var_tags="${var_tags:-f1;dashboard}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

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
  # Prepare static files
  mkdir -p dist/public/assets
  cp dist/app.html dist/public/
  cp -r dist/assets/. dist/public/assets/
  cp dist/manifest.webmanifest dist/public/ 2>/dev/null || true
  cp dist/sw.js dist/public/ 2>/dev/null || true
  cp dist/workbox-*.js dist/public/ 2>/dev/null || true
  cp dist/favicon.svg dist/public/ 2>/dev/null || true
  cp dist/favicon.png dist/public/ 2>/dev/null || true
  cp dist/apple-touch-icon.png dist/public/ 2>/dev/null || true
  cp dist/pwa-192x192.png dist/public/ 2>/dev/null || true
  cp dist/pwa-512x512.png dist/public/ 2>/dev/null || true
  cp -r dist/fonts dist/public/fonts 2>/dev/null || true
  cp dist/fonts.css dist/public/ 2>/dev/null || true
  systemctl restart gridstart
  msg_ok "Updated ${APP}"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Access it using the following URL:${CL}"
echo -e "${GATEWAY}${BGN}http://${IP}:5000${CL}"
