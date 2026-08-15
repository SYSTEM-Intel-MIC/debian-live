#!/bin/bash
set -e

# 0. 彻底清理旧配置和构建缓存（避免旧 stage 文件残留干扰）
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

# 2. 覆盖所有镜像变量 + 禁用 firmware（必须写在 lb config 之后）
# defaults.sh 硬编码了 ftp.debian.org，必须显式覆盖
echo 'LB_MIRROR_BOOTSTRAP="http://deb.debian.org/debian/"' >> config/bootstrap
echo 'LB_PARENT_MIRROR_BOOTSTRAP="http://deb.debian.org/debian/"' >> config/bootstrap
# chroot 阶段镜像
echo 'LB_PARENT_MIRROR_CHROOT="http://deb.debian.org/debian/"' >> config/chroot
echo 'LB_MIRROR_CHROOT="http://deb.debian.org/debian/"' >> config/chroot
# 禁用 security 源
echo 'LB_SECURITY="false"' >> config/chroot
# 禁用 firmware 下载（Contents-amd64.gz 已不存在于 Debian 12 镜像）
echo 'LB_FIRMWARE_CHROOT="false"' >> config/chroot

# 3. 写入 archive override 文件（lb_chroot_archives 只识别 *.list* 文件）
sudo mkdir -p config/archives
cat > config/archives/mirrors.list.chroot << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
EOF

echo "=== 验证 ==="
echo "--- config/chroot 中的镜像变量 ---"
grep "LB_.*MIRROR\|LB_SECURITY\|LB_FIRMWARE" config/chroot | grep -v "^#"
echo "--- archives/ ---"
ls config/archives/
cat config/archives/mirrors.list.chroot

