#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AUDIT=/home/ubuntu/lindows-component-audit-20260818
TMP=/tmp/lindows-new-components-validation
rm -rf "$TMP"
mkdir -p "$TMP"

bash -n "$ROOT/scripts/build-lindows-components.sh"
[ "$(git -C "$AUDIT/copilot" rev-parse HEAD)" = 842248411d1046881023e100073320c5dbd62b57 ]

grep -q 'Copilot for Linux' "$ROOT/README.md"
grep -q 'COPILOT_SHA256=' "$ROOT/scripts/build-lindows-components.sh"


curl --fail --location --retry 2 --output "$TMP/copilot-for-linux_1.0.0_amd64.deb" \
  https://github.com/com-in/Copilot-For-Linux/releases/download/v1.0.0/copilot-for-linux_1.0.0_amd64.deb
printf '%s  %s\n' \
  744120cc972fe66b0e1040a526943f8d8daa92de272d6cec4e3bcad9acfa0158 \
  copilot-for-linux_1.0.0_amd64.deb \
  | (cd "$TMP" && sha256sum -c -)
dpkg-deb --info "$TMP/copilot-for-linux_1.0.0_amd64.deb" | grep -q '^ Package: copilot-for-linux'
dpkg-deb --contents "$TMP/copilot-for-linux_1.0.0_amd64.deb" | grep -q '/usr/share/applications/'

echo 'New Lindows component validation: PASS'
