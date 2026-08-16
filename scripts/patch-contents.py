#!/usr/bin/env python3
"""Patch /usr/lib/live/build/lb_chroot_linux-image to skip Contents-amd64.gz download.

Debian removed Contents-amd64.gz from their mirrors (404).
This script:
1. Comments out the wget lines that download the file
2. Creates an empty stub file so awk reads empty (→ no firmware packages → harmless)
"""
import re, os, sys

SCRIPT = "/usr/lib/live/build/lb_chroot_linux-image"

if not os.path.exists(SCRIPT):
    print(f"ERROR: {SCRIPT} not found", file=sys.stderr)
    sys.exit(1)

with open(SCRIPT) as f:
    content = f.read()

original = content

# Comment out the two wget lines that download Contents-amd64.gz
content = re.sub(
    r'^(\s*)wget\s+\$\{WGET_OPTIONS\}\s+\$\{LB_PARENT_MIRROR_CHROOT\}/dists/\$\{LB_PARENT_DISTRIBUTION\}/Contents-\$\{LB_ARCHITECTURES\}\.gz.*$',
    r'\1# PATCHED: Contents-amd64.gz unavailable on Debian mirrors',
    content, flags=re.MULTILINE
)
content = re.sub(
    r'^(\s*)wget\s+\{WGET_OPTIONS\}\s+\$\{LB_MIRROR_CHROOT\}/dists/\$\{LB_DISTRIBUTION\}/Contents-\$\{LB_ARCHITECTURES\}\.gz.*$',
    r'\1# PATCHED: Contents-amd64.gz unavailable on Debian mirrors',
    content, flags=re.MULTILINE
)

if content == original:
    print("WARNING: No wget lines matched – Contents may already be patched")
else:
    with open(SCRIPT, 'w') as f:
        f.write(content)
    print("Patched successfully")

    # Verify
    with open(SCRIPT) as f:
        for i, line in enumerate(f, 1):
            if 'PATCHED' in line:
                print(f"  line {i}: {line.rstrip()}")
