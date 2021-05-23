#!/usr/bin/env bash

# Setup a fresh Ubuntu 20.04 server from scratch

ROOT_DOMAIN=$1
FIELD_NAME=$2

if [[ -z "${ROOT_DOMAIN}" ]]; then
  echo "Pass the root domain as first argument"
  exit 1
fi

if [[ -z "${FIELD_NAME}" ]]; then
  echo "Pass the field name as second argument"
  exit 1
fi

set -euo pipefail
set -x

# Update system
if ! dpkg -l | grep git; then
  sudo apt update
  sudo apt dist-upgrade -y
  sudo apt install -y git vim python3 python3-requests python3-jinja2 htop
fi

# Install docker based on https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
if ! dpkg -l | grep docker-ce; then
  sudo apt install -y apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

  # Install docker-compose based on https://docs.docker.com/compose/install/
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "alias d=docker" >>~/.bashrc
  echo "alias dc=docker-compose" >>~/.bashrc
fi

repo_dir="$HOME/ssl-simulation-setup"
if [[ ! -d "${repo_dir}" ]]; then
  git clone https://github.com/RoboCup-SSL/ssl-simulation-setup.git "${repo_dir}"
  cd "${repo_dir}" || exit 1
else
  cd "${repo_dir}" || exit 1
  git pull
fi

echo -n "${ROOT_DOMAIN}" >config/root_domain
echo -n "${FIELD_NAME}" >config/field_name
./config/docker/init.sh
./config/caddy/generate_caddyfile.py
docker-compose up -d
sleep 30s
./config/guacamole/update_guacamole.py
./config/caddy/update_caddy_passwords.sh
./config/caddy/generate_caddyfile.py
./config/caddy/update_caddy_config.sh

docker-compose -f docker-compose-teams.yaml up -d
