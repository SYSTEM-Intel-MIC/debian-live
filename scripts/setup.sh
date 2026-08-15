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

# 2. 禁用 bootstrap 阶段的安全源（security.debian.org 在 bootstrap 阶段不可用）
# live-build 默认在 bootstrap 的 apt sources 里加入 security 源，但 Debian 12
# 官方 security 源路径是 bookworm-security，不是 bookworm/updates
# 禁用后 bootstrap 阶段只用主镜像，chroot/binary 阶段再配置安全源
echo 'LB_SECURITY="false"' >> config/bootstrap

# 3. 写入 archive override 文件（chroot + binary 两阶段都覆盖）
# mirrors.chroot = chroot 阶段用的镜像
# mirrors.binary.chroot = chroot 阶段在 binary 阶段复用时的镜像
sudo mkdir -p config/archives
cat > config/archives/mirrors.chroot << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
cp config/archives/mirrors.chroot config/archives/mirrors.binary.chroot
cp config/archives/mirrors.chroot config/archives/mirrors.chroot.chroot
cp config/archives/mirrors.chroot config/archives/mirrors.binary.live
cp config/archives/mirrors.chroot config/archives/mirrors.binary.chroot.chroot

echo "=== 验证 ==="
ls -la config/archives/
cat config/archives/mirrors.chroot
