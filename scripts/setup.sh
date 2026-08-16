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

# 1b. 明确指定内核包名（用 "linux-image" 让 live-build 拼接 flavour = linux-image-amd64）
#    不能用 "linux-image-amd64"，否则拼出来是 linux-image-amd64-amd64（重复）
sed -i 's|^LB_LINUX_PACKAGES=.*||' config/chroot 2>/dev/null || true
grep -q "^LB_LINUX_PACKAGES=" config/chroot || echo 'LB_LINUX_PACKAGES="linux-image"' >> config/chroot

# 2. 覆盖镜像变量（sed 修改已有行，echo 追加缺失的）
# 2a. bootstrap 镜像（defaults.sh 硬编码了 ftp.debian.org）
sed -i 's|^LB_MIRROR_BOOTSTRAP=.*|LB_MIRROR_BOOTSTRAP="http://deb.debian.org/debian"|' config/bootstrap 2>/dev/null || true
sed -i 's|^LB_PARENT_MIRROR_BOOTSTRAP=.*|LB_PARENT_MIRROR_BOOTSTRAP="http://deb.debian.org/debian"|' config/bootstrap 2>/dev/null || true
grep -q "^LB_MIRROR_BOOTSTRAP=" config/bootstrap || echo 'LB_MIRROR_BOOTSTRAP="http://deb.debian.org/debian"' >> config/bootstrap
grep -q "^LB_PARENT_MIRROR_BOOTSTRAP=" config/bootstrap || echo 'LB_PARENT_MIRROR_BOOTSTRAP="http://deb.debian.org/debian"' >> config/bootstrap

# 2b. chroot 镜像（sed 直接改已有值）
sed -i 's|^LB_PARENT_MIRROR_CHROOT=.*|LB_PARENT_MIRROR_CHROOT="http://deb.debian.org/debian"|' config/chroot 2>/dev/null || true
sed -i 's|^LB_MIRROR_CHROOT=.*|LB_MIRROR_CHROOT="http://deb.debian.org/debian"|' config/chroot 2>/dev/null || true
grep -q "^LB_PARENT_MIRROR_CHROOT=" config/chroot || echo 'LB_PARENT_MIRROR_CHROOT="http://deb.debian.org/debian"' >> config/chroot
grep -q "^LB_MIRROR_CHROOT=" config/chroot || echo 'LB_MIRROR_CHROOT="http://deb.debian.org/debian"' >> config/chroot

# 2c. 禁用 security 和 firmware 下载
sed -i 's|^LB_SECURITY=.*|LB_SECURITY="false"|' config/chroot 2>/dev/null || true
sed -i 's|^LB_FIRMWARE_CHROOT=.*|LB_FIRMWARE_CHROOT="false"|' config/chroot 2>/dev/null || true
grep -q "^LB_SECURITY=" config/chroot || echo 'LB_SECURITY="false"' >> config/chroot
grep -q "^LB_FIRMWARE_CHROOT=" config/chroot || echo 'LB_FIRMWARE_CHROOT="false"' >> config/chroot

# 3. 写入 archive override 文件（lb_chroot_archives 只识别 *.list* 文件）
sudo mkdir -p config/archives
cat > config/archives/mirrors.list.chroot << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
EOF

echo "=== 验证 ==="
echo "--- config/chroot 关键变量 ---"
grep -E "^LB_(PARENT_)?MIRROR.*CHROOT|^LB_SECURITY|^LB_FIRMWARE|^LB_LINUX_PACKAGES" config/chroot | grep -v "^#"
echo "--- archives/ ---"
ls config/archives/
cat config/archives/mirrors.list.chroot
