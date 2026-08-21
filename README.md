# Lindows

**Lindows** 是由 **SYSTEM-Intel-MIC** 定制的 Debian Bookworm AMD64 轻量级 Live 发行版。它以 ElevenDE 为默认 X11 桌面，提供 Windows 风格的开始菜单、任务栏、资源管理器、设置、任务管理器、运行对话框、SAS 安全界面和中文输入环境，而不安装完整 GNOME、KDE 或大型桌面元包。

> 本仓库通过 GitHub Actions 构建 **LiveCD + 图形化安装器**。每次主分支提交均会生成 ISO、ISO 校验文件、构建日志，以及 ElevenDE 和系统工具的本地 DEB 包集。

## 系统组成

| 分类 | Lindows 提供内容 |
|---|---|
| 桌面与会话 | ElevenDE 3.5.1、Openbox、picom、LightDM GTK Greeter、Xorg、NetworkManager。 |
| 发行版品牌 | `Lindows 1.0 (Bookworm)`、SYSTEM-Intel-MIC 作者标识、原创深蓝桌面壁纸、BIOS/UEFI Live 启动菜单和已安装系统 GRUB Lindows 主题。 |
| 安装程序 | Calamares 图形化安装器使用 Lindows 名称、标志、壁纸和引导项名称；桌面和应用菜单均提供“安装 Lindows”入口。ISO 不再打包会触发过时 Contents 索引请求的 Debian Installer Live。 |
| 中文支持 | Fcitx5、中文扩展、拼音、Noto CJK；GTK、Qt 和 XIM 环境变量已预配置。 |
| 日常软件 | Firefox ESR、VLC、Eye of GNOME 图片查看器、PeaZip Qt6。 |
| Lindows 服务应用 | Copilot for Linux AI 桌面面板。 |
| Windows 风格工具 | LinuxPCManager、linux-regedit、Lindows 蓝屏演示工具、Device Manager for Linux。 |

## 组件来源与许可

Lindows 使用固定提交构建第三方组件，避免构建时隐式获取默认分支的未知更新。具体提交、构建边界、危险功能限制和 PeaZip 校验值见 [Lindows 架构说明](docs/LINDOWS_ARCHITECTURE.md)。

| 组件 | 上游项目 | 说明 |
|---|---|---|
| ElevenDE | [SYSTEM-Intel-MIC/ElevenDE](https://github.com/SYSTEM-Intel-MIC/ElevenDE) | 云端固定提交 `80d833958ad84f27b2890160a31d1443fe3c5ba6`；ElevenDE 自有代码按 GPL-3.0-or-later 发布，并集成 SAS-for-Linux、Explorer-for-Linux 与 runbox-linux。 |
| LinuxPCManager | [SYSTEM-Intel-MIC/LinuxPCManager](https://github.com/SYSTEM-Intel-MIC/LinuxPCManager) | Windows 风格电脑管家。 |
| linux-regedit | [heyManNice/regedit](https://github.com/heyManNice/regedit) | Linux 配置文件的注册表风格浏览器。 |
| lindows-bsod | [heyManNice/bsod](https://github.com/heyManNice/bsod) | 仅按需启动的 DRM/VT 蓝屏演示工具。 |
| Device Manager | [daimile2/Device-Manager-But-Linux](https://github.com/daimile2/Device-Manager-But-Linux) | Windows 风格硬件与驱动查看工具。 |
| PeaZip | [PeaZip](https://github.com/peazip/PeaZip) | 已固定版本并在构建中校验 SHA-256 的归档管理器。 |
| Copilot for Linux | [com-in/Copilot-For-Linux](https://github.com/com-in/Copilot-For-Linux) | GPL-3.0；固定 v1.0.0 amd64 DEB 并校验 SHA-256；不会预置 API 密钥。 |

Lindows 自有构建脚本、配置、打包元数据、品牌资源、文档和原创集成代码按 **GNU GPL-3.0-or-later** 发布，许可证全文见 [`LICENSE`](LICENSE)。本仓库是聚合发行项目，第三方组件不会因根目录许可证而被重新授权；完整的版权、固定提交、源码获取和独立许可证说明见 [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md)。其中，ElevenDE 云端仓库的自有代码已在提交 `a3b9c9ed17065cc2452678fd0cfe03deda33ab11` 正式切换为 GPL-3.0-or-later；Lindows 随附的上游许可证原文副本见 [`LICENSES/GPL-3.0-ElevenDE.txt`](LICENSES/GPL-3.0-ElevenDE.txt)，其内容与 ElevenDE 当前 `main` 的 LICENSE 校验一致，并在 `80d833958ad84f27b2890160a31d1443fe3c5ba6` 记录 runbox-linux；SAS-for-Linux 与 Explorer-for-Linux 上游已在 2026-08-19 添加 MIT License；SAS 的版权声明为 Copyright (c) 2026 macOS-Terminal，Explorer 同理。ElevenDE 内嵌的 Explorer 不是未经修改的上游副本：其目录与上游同名，但 ElevenDE 已对核心源文件、构建元数据和集成方式进行了重大修改，属于独立维护的衍生/重构代码。原始 Explorer 部分保留 MIT 条款，ElevenDE 对其修改和集成部分按 GPL-3.0-or-later 发布；Lindows 自有补丁仍按本项目 GPL-3.0-or-later 处理。 |

## 获取构建产物

1. 打开仓库的 [Releases](https://github.com/SYSTEM-Intel-MIC/lindows/releases) 页面，下载最新预发布版本中的 `Lindows-1.0-amd64-livecd.iso` 和对应 SHA-256 文件。
2. 在本机验证 ISO：

```sh
sha256sum -c Lindows-1.0-amd64-livecd.iso.sha256
```

3. 将 ISO 写入 USB 后启动 LiveCD。BIOS 与 UEFI 启动菜单均显示 Lindows 名称；进入桌面后点击“安装 Lindows”即可启动图形化安装器。
4. 每次 `main` 分支构建成功后，工作流会同步保留 Actions Artifact；若 Release 暂不可用，可下载 `Lindows-1.0-amd64-livecd-with-installer-*` Artifact 作为备用。

## 默认 Live 会话

LiveCD 默认使用 LightDM 自动进入 ElevenDE，并显示 Lindows 原创深蓝壁纸。Fcitx5 会随桌面启动，输入法环境同时适用于 GTK、Qt 和传统 Xlib 程序。首次运行时可以在 Fcitx5 配置中调整输入法、切换键和候选词行为。

## 本地构建

推荐在支持 Docker 的 Linux 主机上执行与 GitHub Actions 相同的构建步骤。构建会下载 Debian 软件包、固定提交的组件源码和固定版本 PeaZip 发布包，因此需要稳定网络，并会占用较多磁盘空间。

```sh
git clone https://github.com/SYSTEM-Intel-MIC/lindows.git lindows
cd lindows

# 从云端 ElevenDE 固定提交，以及其他固定上游提交生成本地 DEB。
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

## 许可证与第三方声明

本项目的 GPL 许可仅适用于 Lindows 自有代码和已明确按 GPL 发布的组件。MIT、LGPL-3.0 以及许可证尚未明确的上游组件必须保留各自来源与许可边界；不得把聚合 ISO 或 DEB 中的全部文件笼统宣传为 GPL。详见 [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md) 与 [`docs/license-audit-notes.md`](docs/license-audit-notes.md)。

## 安全说明

Lindows 不会自动执行系统清理、设备驱动卸载/更新或蓝屏演示。Copilot 不包含任何预置 API 密钥，用户必须自行配置服务地址和凭据。电脑管家、设备管理器、注册表编辑器和蓝屏演示工具均要求用户显式启动；涉及系统权限的操作应通过图形化授权边界执行。蓝屏演示桌面入口强制携带 `--restore` 参数：动画结束后恢复原图形桌面并退出，**不会重启系统**；它不被注册为守护进程，也不会根据日志自动触发。

## 维护者

**SYSTEM-Intel-MIC**

- 项目主页：<https://github.com/SYSTEM-Intel-MIC/lindows>
- Issue：<https://github.com/SYSTEM-Intel-MIC/lindows/issues>
