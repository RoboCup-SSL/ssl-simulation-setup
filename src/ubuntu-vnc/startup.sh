#!/usr/bin/env bash

# Fail on errors
set -eou pipefail

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
