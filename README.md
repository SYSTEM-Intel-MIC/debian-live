# Lindows

**Lindows** 是由 **SYSTEM-Intel-MIC** 定制的 Debian Bookworm AMD64 轻量级 Live 发行版。它以 ElevenDE 为默认 X11 桌面，提供 Windows 风格的开始菜单、任务栏、资源管理器、设置、任务管理器、运行对话框、SAS 安全界面和中文输入环境，而不安装完整 GNOME、KDE 或大型桌面元包。

> 本仓库通过 GitHub Actions 构建 **LiveCD + 图形化安装器**。每次主分支提交均会生成 ISO、ISO 校验文件、构建日志，以及 ElevenDE 和系统工具的本地 DEB 包集。

## 系统组成

| 分类 | Lindows 提供内容 |
|---|---|
| 桌面与会话 | ElevenDE 3.5.1、Openbox、picom、LightDM GTK Greeter、Xorg、NetworkManager。 |
| 发行版品牌 | `Lindows 1.0 (Bookworm)`、SYSTEM-Intel-MIC 作者标识、Lindows ISO 标签和 Lindows Live 安装入口。 |
| 安装程序 | Calamares 图形化安装器，桌面和应用菜单均提供“安装 Lindows”入口；ISO 启动菜单还保留 Debian Installer Live 机制。 |
| 中文支持 | Fcitx5、中文扩展、拼音、Noto CJK；GTK、Qt 和 XIM 环境变量已预配置。 |
| 日常软件 | Firefox ESR、VLC、Eye of GNOME 图片查看器、PeaZip Qt6。 |
| Windows 风格工具 | LinuxPCManager、linux-regedit、Lindows 蓝屏演示工具、Device Manager for Linux。 |

## 组件来源与许可

Lindows 使用固定提交构建第三方组件，避免构建时隐式获取默认分支的未知更新。具体提交、构建边界、危险功能限制和 PeaZip 校验值见 [Lindows 架构说明](docs/LINDOWS_ARCHITECTURE.md)。

| 组件 | 上游项目 | 说明 |
|---|---|---|
| ElevenDE | [ElevenDE 3.5.1](https://github.com/SYSTEM-Intel-MIC/debian-live) | Lindows 默认桌面环境。 |
| LinuxPCManager | [SYSTEM-Intel-MIC/LinuxPCManager](https://github.com/SYSTEM-Intel-MIC/LinuxPCManager) | Windows 风格电脑管家。 |
| linux-regedit | [heyManNice/regedit](https://github.com/heyManNice/regedit) | Linux 配置文件的注册表风格浏览器。 |
| lindows-bsod | [heyManNice/bsod](https://github.com/heyManNice/bsod) | 仅按需启动的 DRM/VT 蓝屏演示工具。 |
| Device Manager | [daimile2/Device-Manager-But-Linux](https://github.com/daimile2/Device-Manager-But-Linux) | Windows 风格硬件与驱动查看工具。 |
| PeaZip | [PeaZip](https://github.com/peazip/PeaZip) | 已固定版本并在构建中校验 SHA-256 的归档管理器。 |

## 获取构建产物

1. 打开仓库的 **Actions** 页面并选择最新的 **Build Lindows Live ISO** 工作流。
2. 在成功运行的 Artifacts 中下载 `Lindows-1.0-amd64-livecd-with-installer-*`。
3. 下载其中的 `Lindows-1.0-amd64.iso.sha256`，在本机验证 ISO：

```sh
sha256sum -c Lindows-1.0-amd64.iso.sha256
```

4. 将 ISO 写入 USB 后启动 LiveCD。进入桌面后点击“安装 Lindows”即可启动图形化安装器。

## 默认 Live 会话

LiveCD 默认使用 LightDM 自动进入 ElevenDE。Fcitx5 会随桌面启动，输入法环境同时适用于 GTK、Qt 和传统 Xlib 程序。首次运行时可以在 Fcitx5 配置中调整输入法、切换键和候选词行为。

## 本地构建

推荐在支持 Docker 的 Linux 主机上执行与 GitHub Actions 相同的构建步骤。构建会下载 Debian 软件包、固定提交的组件源码和固定版本 PeaZip 发布包，因此需要稳定网络，并会占用较多磁盘空间。

```sh
git clone https://github.com/SYSTEM-Intel-MIC/debian-live.git lindows
cd lindows

# 生成 ElevenDE 与第三方组件本地 DEB。
docker run --rm -v "$PWD:/workspace" -w /workspace \
  golang:1.24-bookworm bash ./scripts/build-lindows-components.sh

# 将本地包放入 live-build chroot 并构建 ISO。
sudo mkdir -p config/includes.chroot/opt/lindows/packages
sudo cp artifacts/packages/*.deb artifacts/packages/SHA256SUMS \
  config/includes.chroot/opt/lindows/packages/
sudo apt-get update
sudo apt-get install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools
sudo lb config --distribution bookworm --architectures amd64 --binary-images iso-hybrid --debian-installer live
sudo lb build
```

## 安全说明

Lindows 不会自动执行系统清理、设备驱动卸载/更新或蓝屏演示。电脑管家、设备管理器、注册表编辑器和蓝屏演示工具均要求用户显式启动；涉及系统权限的操作应通过图形化授权边界执行。蓝屏演示工具默认以恢复桌面模式启动，不被注册为守护进程，也不会根据日志自动触发。

## 维护者

**SYSTEM-Intel-MIC**

- 项目主页：<https://github.com/SYSTEM-Intel-MIC/debian-live>
- Issue：<https://github.com/SYSTEM-Intel-MIC/debian-live/issues>
