# Custom Debian Live ISO

基于 Debian Bookworm 的最小化 Live ISO，使用 live-build 构建。

## 特性

- 📦 基于 Debian Bookworm（AMD64）
- 🔧 仅包含基础系统 + SSH，无 GUI
- 🔗 阿里云源（主）+ 清华源（备）
- 🤖 GitHub Actions 自动构建

## GitHub Actions 构建

1. 点击仓库 **Settings → Secrets → Actions**，添加：
   - `GH_TOKEN`（或 `PAT`）：你的 GitHub Personal Access Token

2. 在仓库页面点击 **Actions → Build Custom Debian Live ISO → Run workflow**

构建完成后在 **Actions → Artifacts** 下载 ISO。

## 本地构建（Linux / WSL）

```bash
# 安装依赖
sudo apt-get update && sudo apt-get install -y live-build

# 生成配置
sudo lb config --distribution bookworm --architectures amd64 --binary-images iso-hybrid --source false

# 覆盖 apt 源
cp config/archives/mirrors.binary.chroot lb/config/archives/
cp config/archives/mirrors.binary.chroot lb/config/archives/mirrors.binary.chroot.chroot
cp config/archives/mirrors.binary.chroot lb/config/archives/mirrors.binary.live

# 添加 SSH 包
mkdir -p config/package-lists
echo 'openssh-server' > config/package-lists/ssh.list.chroot

# 构建（需要 sudo）
sudo lb build
```

## ISO 默认登录

- 用户：`user`
- 密码：`live`
- SSH：`user@localhost`，密码同上

> ⚠️ 首次构建建议手动测试 ISO 是否正常启动后再合并。

## 镜像源

| 源 | 地址 |
|---|---|
| 阿里云（主） | `http://mirrors.aliyun.com/debian/` |
| 清华（备） | `http://mirrors.tuna.tsinghua.edu.cn/debian/` |
