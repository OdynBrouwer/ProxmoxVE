#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: OdynBrouwer
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/mblancolabs/gridstart

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl git sudo openssl
msg_ok "Installed Dependencies"

msg_info "Installing Node.js 24"
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
$STD apt-get install -y nodejs
msg_ok "Installed Node.js 24"

msg_info "Cloning GridStart"
git clone https://github.com/OdynBrouwer/gridstart.git /opt/gridstart
cd /opt/gridstart
msg_ok "Cloned GridStart"

msg_info "Patching production route"
cd /opt/gridstart
# Voeg /app route toe voor de SPA
sed -i 's|app.get("/\*", serveStatic({ root: "./dist/public" }));|app.get("/app", serveStatic({ path: "./dist/public/app.html" }));\napp.get("/*", serveStatic({ root: "./dist/public" }));|' server/production.ts
msg_ok "Patched production route"

msg_info "Creating .env File"
CORS_ORIGIN="http://$(hostname -I | awk '{print $1}'):5000"
cat <<EOF > /opt/gridstart/.env
NODE_ENV=production
PORT=5000
CORS_ORIGIN=${CORS_ORIGIN}
CSRF_SECRET=$(openssl rand -hex 32)
EOF
msg_ok "Created .env File"

msg_info "Installing Dependencies"
$STD npm install
msg_ok "Installed Dependencies"

msg_info "Building GridStart"
$STD npm run build
msg_ok "Built GridStart"

msg_info "Preparing Static Files"
cd /opt/gridstart
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
cp dist/fonts.css dist/public/ 2>/dev/null || true
cp -r dist/fonts dist/public/fonts 2>/dev/null || true
cp dist/index.html dist/public/
cp dist/landing.css dist/public/
cp dist/landing.js dist/public/
cp dist/gridstart-screenshot.png dist/public/ 2>/dev/null || true
cp dist/_headers dist/public/ 2>/dev/null || true
msg_ok "Prepared Static Files"

msg_info "Creating Service"
cat <<EOF > /etc/systemd/system/gridstart.service
[Unit]
Description=GridStart Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/gridstart
ExecStart=/usr/bin/npm start
Restart=on-failure
RestartSec=5
EnvironmentFile=/opt/gridstart/.env

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now gridstart
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
