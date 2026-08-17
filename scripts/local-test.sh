#!/bin/bash
# scripts/local-test.sh — 本地模拟 GitHub Actions workflow 流程
# 用于在本地机器上测试构建流程（需要 sudo）

set -e

DIST="bookworm"
ARCH="amd64"
MIRROR="http://mirrors.aliyun.com/debian/"
SECURITY="http://mirrors.aliyun.com/debian-security/"

echo "=== Local Build Test (simulating GitHub Actions) ==="
echo "Distribution: $DIST | Architecture: $ARCH"
echo "Start time: $(date)"

# 1. 检查依赖
echo "[1/8] Checking dependencies..."
command -v lb >/dev/null 2>&1 || { echo "live-build not installed. Run: sudo apt-get install -y live-build"; exit 1; }
command -v xorriso >/dev/null 2>&1 || { echo "xorriso not installed."; exit 1; }
echo "  OK"

# 2. 清理
echo "[2/8] Cleaning old artifacts..."
sudo rm -rf config/archives lb/ .build/ stage/ cache/ *.iso *.log 2>/dev/null || true
echo "  Done"

# 3. lb config
echo "[3/8] Running lb config..."
sudo lb config \
    --distribution "${DIST}" \
    --architectures "${ARCH}" \
    --linux-flavours amd64 \
    --bootappend-live "boot=live components splash" \
    --binary-images iso-hybrid \
    --source false \
    --zsync false \
    --firmware-chroot false \
    2>&1 | tail -5
echo "  Done"

# 4. 配置镜像
echo "[4/8] Configuring mirrors..."

apply_mirror() {
    local file="$1"
    local key="$2"
    local val="$3"
    grep -q "^${key}=" "$file" && \
        sudo sed -i "s|^${key}=.*|${key}=\"${val}\"|" "$file" || \
        echo "${key}=\"${val}\"" | sudo tee -a "$file"
}

apply_mirror config/bootstrap "LB_MIRROR_BOOTSTRAP" "$MIRROR"
apply_mirror config/bootstrap "LB_PARENT_MIRROR_BOOTSTRAP" "$MIRROR"
apply_mirror config/chroot "LB_MIRROR_CHROOT" "$MIRROR"
apply_mirror config/chroot "LB_PARENT_MIRROR_CHROOT" "$MIRROR"
apply_mirror config/binary "LB_MIRROR_BINARY" "$MIRROR"
apply_mirror config/binary "LB_PARENT_MIRROR_BINARY" "$MIRROR"
apply_mirror config/binary "LB_MIRROR_BINARY_SECURITY" "$SECURITY"

echo "  Mirrors configured"

# 5. archive override
echo "[5/8] Writing archive override files..."
sudo mkdir -p config/archives
cat | sudo tee config/archives/mirrors.list.chroot > /dev/null << 'EOF'
deb http://mirrors.aliyun.com/debian/ bookworm main contrib non-free non-free-firmware
deb http://mirrors.aliyun.com/debian-security/ bookworm-security main contrib non-free non-free-firmware
EOF
cat | sudo tee config/archives/mirrors.list.binary > /dev/null << 'EOF'
deb http://mirrors.aliyun.com/debian/ bookworm main contrib non-free non-free-firmware
deb http://mirrors.aliyun.com/debian-security/ bookworm-security main contrib non-free non-free-firmware
EOF
echo "  Done"

# 6. SSH 包
echo "[6/8] Adding SSH package..."
sudo mkdir -p config/package-lists
echo "openssh-server" | sudo tee config/package-lists/ssh.list.chroot > /dev/null
echo "  Done"

# 7. SSH hook
echo "[7/8] Creating SSH hook..."
sudo mkdir -p config/hooks/live
cat | sudo tee config/hooks/live/enable-ssh.hook.chroot > /dev/null << 'EOF'
#!/bin/sh
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl enable ssh
EOF
sudo chmod +x config/hooks/live/enable-ssh.hook.chroot
echo "  Done"

# 8. 构建
echo "[8/8] Building ISO (this will take 10-30 minutes)..."
echo "  Start: $(date)"
sudo lb build 2>&1 | tee local-build-$(date +%Y%m%d-%H%M%S).log
BUILD_EXIT=$?
echo "  Exit code: $BUILD_EXIT"
echo "  Finish: $(date)"

# 找 ISO
ISO=$(find . -name "*.hybrid.iso" 2>/dev/null | grep -v stage | head -1)
if [ -n "$ISO" ]; then
    echo "✅ ISO generated: $ISO"
    ls -lh "$ISO"
else
    echo "❌ No ISO found"
    exit 1
fi

exit $BUILD_EXIT
