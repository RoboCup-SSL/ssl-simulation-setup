#!/usr/bin/env sh

set -euo pipefail

# Get all environment variables starting with "MULTISOCAT_"
# and convert them to the format "MULTISOCAT_<name>=<value>"
# to pass them to the multisocat script.
env | grep '^MULTISOCAT_' | while read -r line; do
  export "$line"
done
