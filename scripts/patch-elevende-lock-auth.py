#!/usr/bin/env python3
"""Patch only the Lindows build copy of ElevenDE's lock screen.

The setuid-root helper must authenticate the real session user.  LightDM can
preserve a stale USER environment variable during an autologin/session restart;
TTY authentication then succeeds while the graphical gate checks another
account.  Resolve the account from the real UID instead.
"""
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit(f"usage: {sys.argv[0]} /path/to/shell/lock.c")

path = Path(sys.argv[1])
text = path.read_text()
old = '''    user = getenv("USER");
    if (!user || !*user) user = "kali";
'''
new = '''    /* LightDM may leave USER set to a previous/autologin account.  The
     * real UID is authoritative for the graphical session, including when
     * this helper is installed setuid-root. */
    struct passwd *session_pw = getpwuid(getuid());
    user = session_pw ? session_pw->pw_name : getenv("USER");
    if (!user || !*user) user = "kali";
'''
if old not in text:
    raise SystemExit("lock.c user-resolution marker not found")
if "getpwuid(getuid())" not in text:
    text = text.replace(old, new, 1)
path.write_text(text)
print(f"patched {path}")
