#!/usr/bin/env bash

# Fail on errors
set -eou pipefail

apt-get update
apt-get install -y \
  supervisor icewm xterm xfonts-base xauth xinit \
  tigervnc-standalone-server \
  openssh-server \
  iproute2 \
  vim wget git unzip

apt-get purge -y pm-utils xscreensaver*
apt-get autoremove -y
apt-get clean -y
