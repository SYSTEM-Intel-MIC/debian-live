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

# 2. 直接在 config/bootstrap 里覆盖所有镜像变量
# debootstrap 使用 debian suite 格式：http://host suite
# security.debian.org 的正确 suite 是 bookworm-security（不是 bookworm/updates）
cat >> config/bootstrap << 'EOF'

# ---- 镜像覆盖（由 setup.sh 自动生成）----
LB_PARENT_MIRROR_CHROOT="http://deb.debian.org/debian/"
LB_PARENT_MIRROR_CHROOT_SECURITY="http://security.debian.org/debian-security/"
LB_MIRROR_CHROOT="http://deb.debian.org/debian/"
LB_MIRROR_CHROOT_SECURITY="http://security.debian.org/debian-security/"
LB_PARENT_MIRROR_BINARY="http://deb.debian.org/debian/"
LB_PARENT_MIRROR_BINARY_SECURITY="http://security.debian.org/debian-security/"
LB_MIRROR_BINARY="http://deb.debian.org/debian/"
LB_MIRROR_BINARY_SECURITY="http://security.debian.org/debian-security/"
LB_MIRROR_BOOTSTRAP="http://deb.debian.org/debian/"
EOF

# 3. 写入 archive override 文件（覆盖 binary 阶段的镜像）
sudo mkdir -p config/archives
cat > config/archives/mirrors.binary.chroot << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
cp config/archives/mirrors.binary.chroot config/archives/mirrors.binary.chroot.chroot
cp config/archives/mirrors.binary.chroot config/archives/mirrors.binary.live

echo "=== 验证镜像配置 ==="
grep "MIRROR.*SECURITY\|security" config/bootstrap | grep -v "^#"
echo "=== archive 文件 ==="
cat config/archives/mirrors.binary.chroot
