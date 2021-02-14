#!/usr/bin/env bash

# Fail on errors
set -eou pipefail

if [[ -v SSH_PUBLIC_KEY ]]; then
  mkdir -p ~/.ssh
  echo "${SSH_PUBLIC_KEY}" > ~/.ssh/authorized_keys
fi

if [[ ! -f ~/.ssh/ssh_host_rsa_key ]]; then
  ssh-keygen -t rsa -f ~/.ssh/ssh_host_rsa_key -N ''
fi
/usr/sbin/sshd -f /etc/ssh/sshd_config

echo "Cleanup old VNC server locks"
vncserver -kill "$DISPLAY" &>> .vnc_startup.log \
    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &>> .vnc_startup.log \
    || true

echo "Setting up VNC password"
mkdir -p "$HOME/.vnc"
PASSWD_PATH="$HOME/.vnc/passwd"
rm -f "$PASSWD_PATH"

echo "$VNC_PW" | vncpasswd -f >> "$PASSWD_PATH"
chmod 600 "$PASSWD_PATH"

echo "Starting VNC server"
exec vncserver "$DISPLAY" -depth "$VNC_COL_DEPTH" -geometry "$VNC_RESOLUTION" -fg -localhost no
