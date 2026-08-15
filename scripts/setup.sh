#!/bin/bash
set -e

# 0. 彻底清理旧配置和构建缓存
sudo rm -rf config/archives lb/ .build/ stage/ cache/ 2>/dev/null || true

# 1. 生成 live-build 配置
sudo lb config \
  --distribution bookworm \
  --architectures amd64 \
  --linux-flavours amd64 \
  --bootappend-live "boot=live components splash" \
  --binary-images iso-hybrid \
  --source false \
  --mode debian

# 2. 用 sed 直接修改 lb config 生成的配置（不能用 echo 追加，会被默认值覆盖）
# 2a. 覆盖 bootstrap 镜像（defaults.sh 硬编码了 ftp.debian.org）
sed -i 's|^LB_MIRROR_BOOTSTRAP=.*|LB_MIRROR_BOOTSTRAP="http://deb.debian.org/debian"|' config/bootstrap
sed -i 's|^LB_PARENT_MIRROR_BOOTSTRAP=.*|LB_PARENT_MIRROR_BOOTSTRAP="http://deb.debian.org/debian"|' config/bootstrap

# 2b. 覆盖 chroot 镜像（不能用追加，必须改已有行）
sed -i 's|^LB_PARENT_MIRROR_CHROOT=.*|LB_PARENT_MIRROR_CHROOT="http://deb.debian.org/debian"|' config/chroot
sed -i 's|^LB_MIRROR_CHROOT=.*|LB_MIRROR_CHROOT="http://deb.debian.org/debian"|' config/chroot

# 2c. 禁用 security 和 firmware 下载（sed 直接改已有值）
sed -i 's|^LB_SECURITY=.*|LB_SECURITY="false"|' config/chroot
sed -i 's|^LB_FIRMWARE_CHROOT=.*|LB_FIRMWARE_CHROOT="false"|' config/chroot

# 3. 写入 archive override 文件（lb_chroot_archives 只识别 *.list* 文件）
sudo mkdir -p config/archives
cat > config/archives/mirrors.list.chroot << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
EOF

echo "=== 验证 ==="
echo "--- config/chroot 关键变量 ---"
grep -E "LB_(PARENT_)?MIRROR.*CHROOT|LB_SECURITY|LB_FIRMWARE" config/chroot | grep -v "^#"
echo "--- archives/ ---"
ls config/archives/
echo "--- mirrors.list.chroot ---"
cat config/archives/mirrors.list.chroot
