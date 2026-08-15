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

# 2. 禁用 security 源（所有阶段都禁用）
# lb_chroot_apt / lb_chroot_archives 读取 config/chroot 里的 LB_SECURITY 来决定是否加 security 源
echo 'LB_SECURITY="false"' >> config/bootstrap
echo 'LB_SECURITY="false"' >> config/chroot
echo 'LB_FIRMWARE_CHROOT="false"' >> config/chroot

# 3. 覆盖所有镜像变量（三个 config 文件都要改）
# defaults.sh 硬编码了 ftp.debian.org，必须显式覆盖
echo 'LB_MIRROR_BOOTSTRAP="http://deb.debian.org/debian"' >> config/bootstrap
echo 'LB_PARENT_MIRROR_BOOTSTRAP="http://deb.debian.org/debian"' >> config/bootstrap
echo 'LB_PARENT_MIRROR_CHROOT="http://deb.debian.org/debian"' >> config/chroot
echo 'LB_MIRROR_CHROOT="http://deb.debian.org/debian"' >> config/chroot

# 4. 写入 archive override 文件（chroot + binary 两阶段都覆盖）
sudo mkdir -p config/archives
cat > config/archives/mirrors.chroot << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
EOF
cp config/archives/mirrors.chroot config/archives/mirrors.binary.chroot
cp config/archives/mirrors.chroot config/archives/mirrors.chroot.chroot
cp config/archives/mirrors.chroot config/archives/mirrors.binary.live
cp config/archives/mirrors.chroot config/archives/mirrors.binary.chroot.chroot

echo "=== 验证 ==="
ls -la config/archives/
cat config/archives/mirrors.chroot

