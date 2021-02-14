#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
GUACAMOLE_URL=https://vnc.field-a.localhost/guacamole
GUACAMOLE_USERNAME=guacadmin
GUACAMOLE_PASSWORD=guacadmin
GUACAMOLE_DATASOURCE=postgresql
VNC_PASSWORD=vncpassword
TEAMS=$(sed ':a;N;$!ba;s/\n/ /g' "${SCRIPT_DIR}/teams")
CURL="curl -k --silent --show-error --fail"

SSH_KEY_LOCATION="${SCRIPT_DIR}/vnc_rsa"

if [[ ! -f "${SSH_KEY_LOCATION}" ]]; then
  ssh-keygen -t rsa -m PEM -f "${SSH_KEY_LOCATION}" -N "" -C guacamole-vnc
fi

GUACAMOLE_PRIVATE_KEY=$(sed ':a;N;$!ba;s/\n/\\n/g' "${SSH_KEY_LOCATION}")

authToken=$(curl -k -s \
  --data-urlencode "username=${GUACAMOLE_USERNAME}" \
  --data-urlencode "password=${GUACAMOLE_PASSWORD}" \
  "${GUACAMOLE_URL}/api/tokens" |
  jq -r '.authToken')

echo "authToken: ${authToken}"

set -x

function createConnection() {
  connectionName="$1"
  connectionHost="$2"
  vncPort="$3"
  parentIdentifier="$4"
  readOnly="$5"
  sftpEnabled="$6"
  listConnectionsResponse=$(
    ${CURL} \
      "${GUACAMOLE_URL}/api/session/data/${GUACAMOLE_DATASOURCE}/connections?token=${authToken}"
  )
  connectionId=$(echo "$listConnectionsResponse" | jq -c 'to_entries[] | .value | select(.name == "'"${connectionName}"'") | .identifier | tonumber')

  if [[ -z "${connectionId}" ]]; then
    createConnectionResponse=$(
      ${CURL} \
        -H "Content-Type: application/json" \
        --request POST \
        --data '{
  "parentIdentifier": "'"${parentIdentifier}"'",
  "name": "'"${connectionName}"'",
  "protocol": "vnc",
  "parameters": {
    "port": "'"${vncPort}"'",
    "read-only": "'"${readOnly}"'",
    "swap-red-blue": "",
    "cursor": "",
    "color-depth": "",
    "clipboard-encoding": "",
    "disable-copy": "",
    "disable-paste": "",
    "dest-port": "",
    "recording-exclude-output": "",
    "recording-exclude-mouse": "",
    "recording-include-keys": "",
    "create-recording-path": "",
    "enable-sftp": "'"${sftpEnabled}"'",
    "sftp-port": "",
    "sftp-server-alive-interval": "",
    "enable-audio": "",
    "audio-servername": "",
    "sftp-directory": "",
    "sftp-root-directory": "/home/default",
    "sftp-passphrase": "",
    "sftp-private-key": "'"${GUACAMOLE_PRIVATE_KEY}"'",
    "sftp-username": "default",
    "sftp-password": "",
    "sftp-host-key": "",
    "sftp-hostname": "",
    "recording-name": "",
    "recording-path": "",
    "dest-host": "",
    "password": "'"${VNC_PASSWORD}"'",
    "username": "",
    "hostname": "'"${connectionHost}"'"
  },
  "attributes": {
    "max-connections": "1000",
    "max-connections-per-user": "",
    "weight": "",
    "failover-only": "",
    "guacd-port": "",
    "guacd-encryption": "",
    "guacd-hostname": ""
  }
}' \
        "${GUACAMOLE_URL}/api/session/data/${GUACAMOLE_DATASOURCE}/connections?token=${authToken}"
    )
    connectionId=$(echo "${createConnectionResponse}" | jq -r '.identifier | tonumber')
  fi
  echo "${connectionId}"
}

# Change default guacadmin password
# TODO

# Create 'Viewer' connection group
listViewerResponse=$(
  ${CURL} \
    "${GUACAMOLE_URL}/api/session/data/${GUACAMOLE_DATASOURCE}/connectionGroups?token=${authToken}"
)
viewerConnectionGroupId=$(echo "${listViewerResponse}" | jq -c 'to_entries[] | .value | select(.name == "viewers") | .identifier | tonumber')

if [[ -z "${viewerConnectionGroupId}" ]]; then
  createViewerResponse=$(
    ${CURL} \
      -H "Content-Type: application/json" \
      --request PUT \
      --data '{
  "parentIdentifier": "1",
  "name": "viewers",
  "type": "ORGANIZATIONAL",
  "attributes": {
    "max-connections": "",
    "max-connections-per-user": "",
    "enable-session-affinity": ""
  }
}' \
      "${GUACAMOLE_URL}/api/session/data/${GUACAMOLE_DATASOURCE}/connectionGroups?token=${authToken}"
  )
  viewerConnectionGroupId=$(echo "${createViewerResponse}" | jq -r '.identifier | tonumber')
fi

# Create a user per team
for team in $TEAMS; do
  # TODO generate and store password
  if ! ${CURL} "${GUACAMOLE_URL}/api/session/data/${GUACAMOLE_DATASOURCE}/users/${team}?token=${authToken}"; then
    ${CURL} \
      -H "Content-Type: application/json" \
      --request POST \
      --data '{"username":"'"${team}"'","password":"test",  "attributes": {
    "disabled": "",
    "expired": "",
    "access-window-start": "",
    "access-window-end": "",
    "valid-from": "",
    "valid-until": "",
    "timezone": null,
    "guac-full-name": "",
    "guac-organization": "",
    "guac-organizational-role": ""
  }}' \
      "${GUACAMOLE_URL}/api/session/data/${GUACAMOLE_DATASOURCE}/users?token=${authToken}"
  fi

  # Create a write connection per team
  connectionId=$(createConnection "${team}" "${team}" 5901 "ROOT" "" "true")

  # Add write connection to team and assign it to Viewer group
  ${CURL} \
    -H "Content-Type: application/json" \
    --request PATCH \
    --data '[
  {
    "op": "add",
    "path": "/connectionPermissions/'"${connectionId}"'",
    "value": "READ"
  },
  {
    "op": "add",
    "path": "/connectionGroupPermissions/'"${viewerConnectionGroupId}"'",
    "value": "READ"
  }
]' \
    "${GUACAMOLE_URL}/api/session/data/${GUACAMOLE_DATASOURCE}/users/${team}/permissions?token=${authToken}"

  # Create a read connection per team
  createConnection "${team}-read-only" "${team}" 5901 "${viewerConnectionGroupId}" "true" ""

done

# Create connection for grSim
createConnection "grsim" "grsim" 5900 "ROOT" "" ""
createConnection "grsim-read-only" "grsim" 5900 "${viewerConnectionGroupId}" "true" ""

# Create connection for tigers autoRef
createConnection "autoref-tigers" "autoref-tigers" 5900 "ROOT" "" ""
createConnection "autoref-tigers-read-only" "autoref-tigers" 5900 "${viewerConnectionGroupId}" "true" ""