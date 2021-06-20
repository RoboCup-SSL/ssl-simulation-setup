#!/usr/bin/env bash

FIELDS="$*"

if [[ -z "${FIELDS}" ]]; then
  FIELDS="a b c d"
fi

for f in $FIELDS; do
  echo "Field $f"
  scp ./init/update.sh root@field-$f.virtual.ssl.robocup.org:
  ssh root@field-$f.virtual.ssl.robocup.org ./update.sh
done
