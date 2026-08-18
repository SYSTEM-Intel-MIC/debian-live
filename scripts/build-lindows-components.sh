#!/usr/bin/env bash
# Build all non-Debian Lindows components in a Debian Bookworm container.
# This script deliberately does not run upstream install.sh/build.sh files.
set -euo pipefail

ROOT="${ROOT:-/workspace}"
OUT="$ROOT/artifacts"
PKGS="$OUT/packages"
WORK="$OUT/work"
ELEV_ZIP="$ROOT/vendor/elevende-3.5.1-source.zip"

PCMANAGER_URL="https://github.com/SYSTEM-Intel-MIC/LinuxPCManager.git"
PCMANAGER_REV="4a744338aff580d4c7260bb00cbebfe8521bcf80"
REGEDIT_URL="https://github.com/heyManNice/regedit.git"
REGEDIT_REV="0e3de3dcfbf1aca0fbc8dda2be307a1224c0f04f"
BSOD_URL="https://github.com/heyManNice/bsod.git"
BSOD_REV="45757f64e6fa2983e92382a2ba8e47b1685d92f9"
DEVMGR_URL="https://github.com/daimile2/Device-Manager-But-Linux.git"
DEVMGR_REV="e7e8238cc72a08ce0302e4ffbd529838f49fbed4"
PEAZIP_URL="https://github.com/peazip/PeaZip/releases/download/11.2.0/peazip_11.2.0.LINUX.Qt6-1_amd64.deb"
PEAZIP_SHA256="11af7ca6fd633566eb8de969b43ca257b8bce759421775c8c7bbb66105406e58"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

require_root() {
    [ "$(id -u)" = 0 ] || die "this build must run as root inside the Debian build container"
}

clone_pinned() {
    local url="$1" rev="$2" dst="$3"
    git clone --filter=blob:none "$url" "$dst"
    git -C "$dst" checkout --detach "$rev"
    [ "$(git -C "$dst" rev-parse HEAD)" = "$rev" ] || die "unexpected revision for $url"
}

make_deb() {
    local name="$1" version="$2" depends="$3" stage="$4" description="$5"
    mkdir -p "$stage/DEBIAN"
    cat > "$stage/DEBIAN/control" <<CONTROL
Package: $name
Version: $version
Architecture: amd64
Maintainer: SYSTEM-Intel-MIC <opensource@system-intel-mic.invalid>
Depends: $depends
Section: utils
Priority: optional
Description: $description
 Lindows bundled component built from a fixed upstream source revision.
CONTROL
    dpkg-deb --build --root-owner-group "$stage" "$PKGS/${name}_${version}_amd64.deb" >/dev/null
}

require_root
export DEBIAN_FRONTEND=noninteractive
rm -rf "$OUT"
mkdir -p "$PKGS" "$WORK"

log "installing component build dependencies"
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip zip xz-utils dpkg-dev \
    build-essential cmake ninja-build meson pkg-config \
    libgtk-3-dev libjson-glib-dev libdrm-dev libfreetype-dev \
    libfontconfig1-dev libsystemd-dev libgl1-mesa-dev libxkbcommon-dev \
    xorg-dev libxi-dev libxtst-dev libdbus-1-dev libcrypt-dev \
    libgdk-pixbuf-2.0-dev librsvg2-bin qt6-base-dev qt6-svg-dev \
    libgl1-mesa-dev libpng-dev libxft-dev libx11-dev libfontconfig1-dev \
    libgtk-3-dev

log "checking vendored ElevenDE source"
[ -f "$ELEV_ZIP" ] || die "missing $ELEV_ZIP"
( cd "$ROOT/vendor" && sha256sum -c SHA256SUMS )
unzip -q "$ELEV_ZIP" -d "$WORK"
ELEV_SRC="$WORK/elevende-3.5.1"
[ -x "$ELEV_SRC/build-deb.sh" ] || die "ElevenDE source package is incomplete"

log "building ElevenDE 3.5.1"
(
    cd "$ELEV_SRC"
    BUILD_DIR="$WORK/elevende-build" ./build-deb.sh
    cp elevende_3.5.1_amd64.deb "$PKGS/"
)

log "building LinuxPCManager package"
PC="$WORK/linux-pcmanager"
clone_pinned "$PCMANAGER_URL" "$PCMANAGER_REV" "$PC"
STAGE="$WORK/pkg-linux-pcmanager"
mkdir -p "$STAGE/usr/lib/linux-pcmanager" "$STAGE/usr/bin" "$STAGE/usr/share/applications"
cp -a "$PC/src/." "$STAGE/usr/lib/linux-pcmanager/"
install -m 755 /dev/stdin "$STAGE/usr/bin/linux-pcmanager" <<'LAUNCH'
#!/bin/sh
exec python3 /usr/lib/linux-pcmanager/main.py "$@"
LAUNCH
install -m 644 "$PC/linux-pcmanager.desktop" "$STAGE/usr/share/applications/linux-pcmanager.desktop"
make_deb "linux-pcmanager" "1.0.0+lindows1" "python3, python3-tk, policykit-1, xdotool, wmctrl, x11-utils, pulseaudio-utils | alsa-utils" "$STAGE" "Windows-style Linux PC Manager"

log "building linux-regedit package"
REG="$WORK/regedit"
clone_pinned "$REGEDIT_URL" "$REGEDIT_REV" "$REG"
meson setup "$REG/build" "$REG" --buildtype=release
meson compile -C "$REG/build"
STAGE="$WORK/pkg-linux-regedit"
install -Dm755 "$REG/build/linux-regedit" "$STAGE/usr/local/bin/linux-regedit"
install -Dm644 /dev/stdin "$STAGE/usr/share/applications/linux-regedit.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Registry Editor
Name[zh_CN]=注册表编辑器
Comment=Browse Linux system and user configuration files
Exec=linux-regedit
Icon=preferences-system
Terminal=false
Categories=System;Settings;
DESKTOP
make_deb "linux-regedit" "0.1+lindows1" "libgtk-3-0, libjson-glib-1.0-0, man-db" "$STAGE" "Windows-style Linux configuration registry editor"

log "building Lindows BSOD package"
BSOD="$WORK/bsod"
clone_pinned "$BSOD_URL" "$BSOD_REV" "$BSOD"
meson setup "$BSOD/build" "$BSOD" --buildtype=release
meson compile -C "$BSOD/build"
STAGE="$WORK/pkg-lindows-bsod"
install -Dm755 "$BSOD/build/bsod" "$STAGE/usr/local/sbin/lindows-bsod"
install -Dm755 /dev/stdin "$STAGE/usr/local/bin/lindows-bsod-demo" <<'LAUNCH'
#!/bin/sh
# The Lindows menu entry is deliberately a reversible demonstration.
# --restore overrides upstream's default reboot behavior after the animation.
exec /usr/local/sbin/lindows-bsod --restore --show "Lindows demonstration"
LAUNCH
install -Dm644 /dev/stdin "$STAGE/usr/share/applications/lindows-bsod.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Lindows Blue Screen Demo
Name[zh_CN]=Lindows 蓝屏演示
Comment=Show a temporary blue-screen demonstration and restore the desktop
Exec=pkexec /usr/local/bin/lindows-bsod-demo
Icon=dialog-warning
Terminal=false
Categories=System;
DESKTOP
make_deb "lindows-bsod" "1.0.2+lindows1" "libdrm2, libfreetype6, libfontconfig1, libsystemd0" "$STAGE" "Lindows blue-screen demonstration tool"

log "building Device Manager package"
DEVMGR="$WORK/devmgr"
clone_pinned "$DEVMGR_URL" "$DEVMGR_REV" "$DEVMGR"
(
    cd "$DEVMGR"
    # The pinned upstream revision intentionally does not track go.sum.
    # Resolve and record module checksums in the disposable build tree first.
    go mod tidy
    go mod download
    CGO_ENABLED=1 go build -trimpath -ldflags="-s -w" -o devmgr ui.go
    go build -trimpath -ldflags="-s -w" -o devmgr-cli cli.go
)
STAGE="$WORK/pkg-lindows-devmgr"
install -Dm755 "$DEVMGR/devmgr" "$STAGE/usr/local/bin/devmgr"
install -Dm755 "$DEVMGR/devmgr-cli" "$STAGE/usr/local/bin/devmgr-cli"
install -Dm644 /dev/stdin "$STAGE/usr/share/applications/lindows-device-manager.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Device Manager
Name[zh_CN]=设备管理器
Comment=View Linux hardware in a Windows-style device manager
Exec=devmgr
Icon=computer
Terminal=false
Categories=System;Settings;HardwareSettings;
DESKTOP
make_deb "lindows-device-manager" "0.1.0+lindows1" "libgl1, libx11-6, libxrandr2, libxinerama1, libxcursor1, libxi6, policykit-1, pciutils, usbutils" "$STAGE" "Windows-style Linux device manager"

log "downloading fixed PeaZip package"
curl --fail --location --retry 3 --output "$PKGS/peazip_11.2.0.LINUX.Qt6-1_amd64.deb" "$PEAZIP_URL"
printf '%s  %s\n' "$PEAZIP_SHA256" "peazip_11.2.0.LINUX.Qt6-1_amd64.deb" | (cd "$PKGS" && sha256sum -c -)

(
    cd "$PKGS"
    sha256sum *.deb > SHA256SUMS
)
log "built local packages"
ls -lh "$PKGS"
