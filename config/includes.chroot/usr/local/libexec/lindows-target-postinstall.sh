#!/bin/sh
set -eu

# This script runs inside the newly installed target through Calamares
# shellprocess. It must be safe to run more than once.
TARGET=/

# The Live image deliberately autologins a temporary `user` account. Never
# carry that policy into the installed target: it resets the user's password,
# suppresses LightDM's greeter, and breaks logout/login recovery.
if command -v systemctl >/dev/null 2>&1; then
    systemctl disable lindows-live-session-init.service >/dev/null 2>&1 || true
fi
rm -f /etc/systemd/system/lindows-live-session-init.service \
      /etc/systemd/system/multi-user.target.wants/lindows-live-session-init.service \
      /etc/systemd/system/lightdm.service.d/10-lindows-live-user.conf \
      /usr/local/sbin/lindows-lightdm \
      /usr/local/sbin/lindows-live-session-init \
      /etc/lightdm/lightdm.conf.d/99-lindows-autologin.conf \
      /etc/lightdm/lightdm.conf.d/50-lindows.conf
rm -f /etc/xdg/autostart/lindows-desktop-trust.desktop
# LightDM is only the session launcher. ElevenDE's own elevende-lock login
# page must remain visible, so autologin the Calamares-created human account
# into ElevenDE instead of showing a second LightDM greeter.
installed_account=$(awk -F: '$3 >= 1000 && $3 < 60000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
if [ -n "$installed_account" ]; then
    install -Dm644 /dev/stdin /etc/lightdm/lightdm.conf.d/60-lindows-installed.conf <<EOF
[Seat:*]
user-session=elevende
autologin-user=$installed_account
autologin-user-timeout=0
autologin-session=elevende
greeter-hide-users=false
EOF
fi

# Installed systems must not keep the Live-only installer entry.
find /home /root /etc/skel -type f \( -iname '*install*lindows*.desktop' -o -iname 'install-debian.desktop' -o -iname 'debian-installer.desktop' -o -iname 'debian-installer-launcher.desktop' \) -delete 2>/dev/null || true
rm -f /usr/share/applications/lindows-installer.desktop \
      /usr/share/applications/debian-installer.desktop \
      /usr/share/applications/debian-installer-launcher.desktop \
      /usr/share/applications/install-system.desktop \
      /etc/xdg/autostart/calamares-desktop-icon.desktop \
      /etc/xdg/autostart/lindows-desktop-trust.desktop
for entry in /usr/share/applications/*.desktop; do
    [ -f "$entry" ] || continue
    if grep -qiE '^Name(\[[^]]+\])?=.*(Install Lindows|Install System|安装 Lindows|安装系统)' "$entry" 2>/dev/null; then
        rm -f "$entry"
    fi
done

# Keep the Lindows GRUB theme self-contained in the installed target. Copy
# both the theme and its relative desktop-image asset before running grub-mkconfig.
THEME_SRC=/usr/share/lindows/branding/theme.txt
[ -f "$THEME_SRC" ] || THEME_SRC=/boot/grub/themes/lindows/theme.txt
WALL_SRC=/usr/share/lindows/branding/lindows-aurora-wallpaper.png
[ -f "$WALL_SRC" ] || WALL_SRC=/boot/grub/themes/lindows/lindows-aurora-wallpaper.png
if [ -f "$THEME_SRC" ] && [ -f "$WALL_SRC" ]; then
    install -Dm644 "$THEME_SRC" /boot/grub/themes/lindows/theme.txt
    install -Dm644 "$WALL_SRC" /boot/grub/themes/lindows/lindows-aurora-wallpaper.png
    mkdir -p /etc/default/grub.d
    cat > /etc/default/grub.d/00-lindows.cfg <<'EOF'
GRUB_DISTRIBUTOR="Lindows"
GRUB_THEME="/boot/grub/themes/lindows/theme.txt"
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=6
GRUB_DEFAULT=0
GRUB_DISABLE_OS_PROBER=false
EOF
else
    # Never leave a dangling GRUB_THEME which produces a boot-time error.
    rm -f /etc/default/grub.d/00-lindows.cfg
fi

# Enable a real lock screen for the installed graphical session.
if command -v light-locker >/dev/null 2>&1; then
    install -Dm644 /dev/stdin /etc/xdg/autostart/lindows-lock.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Lindows Screen Lock
Name[zh_CN]=Lindows 锁屏
Exec=sh -c 'xset s 600 600; xset +dpms; xset dpms 0 0 900; exec light-locker --lock-after-screensaver=1 --idle-hint'
OnlyShowIn=ElevenDE;LXDE;Openbox;
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF
fi

# Ensure a display change is restored on the next login when saved by Settings.
install -Dm755 /dev/stdin /usr/local/bin/lindows-restore-display <<'EOF'
#!/bin/sh
set -eu
[ -n "${DISPLAY:-}" ] || exit 0
[ -f "$HOME/.config/lindows/display.conf" ] || exit 0
mode=$(sed -n '1p' "$HOME/.config/lindows/display.conf")
[ -n "$mode" ] || exit 0
output=$(xrandr 2>/dev/null | awk '/ connected/{print $1; exit}')
[ -n "$output" ] || exit 0
xrandr --output "$output" --mode "$mode" >/dev/null 2>&1 || true
sleep 2
pkill -USR1 -x elevende-shell >/dev/null 2>&1 || true
EOF
install -Dm644 /dev/stdin /etc/xdg/autostart/lindows-restore-display.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Lindows Display Restore
Exec=/usr/local/bin/lindows-restore-display
OnlyShowIn=ElevenDE;LXDE;Openbox;
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF

# Preserve the password entered in Calamares and make the created human user
# eligible for sudo without changing or resetting its password.
if getent group sudo >/dev/null 2>&1; then
    for account in $(awk -F: '$3 >= 1000 && $3 < 60000 && $1 != "nobody" {print $1}' /etc/passwd); do
        usermod -aG sudo "$account" >/dev/null 2>&1 || true
    done
fi

# Refresh device state and initramfs so firmware already present in the target
# is discovered without requiring a second manual driver step.
command -v udevadm >/dev/null 2>&1 && udevadm trigger --action=add || true
command -v depmod >/dev/null 2>&1 && depmod -a || true
command -v update-initramfs >/dev/null 2>&1 && update-initramfs -u -k all || true

# Regenerate GRUB only after the target theme and defaults are present.
command -v update-grub >/dev/null 2>&1 && update-grub || true

# Perform one more hardware/firmware probe at first boot, when the installed
# kernel and target udev database are active. Optional firmware never blocks
# graphical login.
install -Dm644 /dev/stdin /etc/systemd/system/lindows-driver-probe.service <<'EOF'
[Unit]
Description=Lindows hardware and firmware probe
After=local-fs.target systemd-udev-settle.service
Before=graphical.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'udevadm trigger --action=add; depmod -a; update-initramfs -u -k all; if command -v fwupdmgr >/dev/null 2>&1; then fwupdmgr get-devices || true; fi'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
if command -v systemctl >/dev/null 2>&1; then
    systemctl enable lindows-driver-probe.service >/dev/null 2>&1 || true
fi
