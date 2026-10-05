#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: OdynBrouwer
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/mblancolabs/gridstart

source <(curl -fsSL https://raw.githubusercontent.com/OdynBrouwer/ProxmoxVE/main/misc/build.func)

APP="GridStart"
var_tags="${var_tags:-f1;dashboard}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

# BELANGRIJK: vertel build.func dat het installatiescript in JOUW repo staat
var_install="${var_install:-gridstart-install}"
var_install_url="${var_install_url:-https://raw.githubusercontent.com/OdynBrouwer/ProxmoxVE/main/install/${var_install}.sh}"

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

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Access it using the following URL:${CL}"
echo -e "${GATEWAY}${BGN}http://${IP}:5000${CL}"
