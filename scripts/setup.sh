#!/bin/bash
set -e

# 1. 生成 live-build 配置
sudo lb config \
  --distribution bookworm \
  --architectures amd64 \
  --linux-flavours amd64 \
  --bootappend-live "boot=live components splash" \
  --binary-images iso-hybrid \
  --source false \
  --mode debian

# 2. 修复所有 config 文件里的 security 镜像（sed 改 lb config 生成的变量）
for f in config/bootstrap config/chroot config/binary; do
  sudo sed -i 's|http://security.debian.org/debian-security bookworm/updates|http://security.debian.org/debian-security bookworm-security main|g' "$f"
  sudo sed -i 's|http://security.debian.org/debian-security/debian-security|http://security.debian.org/debian-security|g' "$f"
done

# 3. 写入 archive override 文件
sudo mkdir -p config/archives
sudo tee config/archives/mirrors.binary.chroot > /dev/null << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
cp config/archives/mirrors.binary.chroot config/archives/mirrors.binary.chroot.chroot
cp config/archives/mirrors.binary.chroot config/archives/mirrors.binary.live

echo "Config done."
