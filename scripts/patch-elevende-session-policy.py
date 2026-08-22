#!/usr/bin/env python3
"""Apply the Lindows Live/installed ElevenDE login policy to a build copy."""
from __future__ import annotations

import sys
from pathlib import Path

path = Path(sys.argv[1]) if len(sys.argv) == 2 else None
if path is None or not path.is_file():
    raise SystemExit("usage: patch-elevende-session-policy.py PATH/TO/session/elevende-session")

old = '''# Login gate: show a Win11-style login screen with a password field before
# the desktop starts. Skips (or continues) if the lock cannot run.
if [ -x /usr/local/bin/elevende-lock ]; then
    echo "elevende-session: login gate"
    /usr/local/bin/elevende-lock --login || true
    echo "elevende-session: unlocked"
fi
'''
new = '''# LINDOWS-SESSION-POLICY: Live media enters its disposable user session
# directly. Installed systems retain ElevenDE's own Win11-style login gate;
# no external display-manager greeter is involved.
if [ "${LINDOWS_LIVE_SESSION:-0}" != "1" ] && [ ! -d /run/live ] && \\
        [ -x /usr/local/bin/elevende-lock ]; then
    echo "elevende-session: ElevenDE native login gate"
    /usr/local/bin/elevende-lock --login || true
    echo "elevende-session: unlocked"
else
    echo "elevende-session: Live session bypasses the login gate"
fi
'''
text = path.read_text(encoding="utf-8")
if "LINDOWS-SESSION-POLICY" in text:
    raise SystemExit("Lindows session policy is already present")
if old not in text:
    raise SystemExit("ElevenDE login gate marker was not found")
path.write_text(text.replace(old, new, 1), encoding="utf-8")
print("patched ElevenDE session for Live bypass and installed native login")
