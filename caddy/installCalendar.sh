#!/usr/bin/env bash

CALENDAR_ID="$1"

if [[ -z "${CALENDAR_ID}" ]]; then
  echo "Specify a calendar id in the format c_k23bjk71b5tqm3od1osjndu5mk@group.calendar.google.com"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

sed -i -e "s/@calendarId@/${CALENDAR_ID}/" "${SCRIPT_DIR}/init/site/calendar.html"
