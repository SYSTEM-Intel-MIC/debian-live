# Lindows 发行版架构

## 目标

Lindows 是面向 AMD64 的 Debian Bookworm 轻量级 X11 Live 发行版。它以 ElevenDE 作为默认桌面会话，提供熟悉的 Windows 风格桌面、系统工具和图形化安装入口，同时避免引入完整 GNOME、KDE 或其他重量级桌面元包。镜像标识、启动菜单、`/etc/os-release`、桌面会话和安装器界面均使用 **Lindows**；作者标识为 **SYSTEM-Intel-MIC**。

## 运行时组成

| 层次 | 方案 | 目的 |
|---|---|---|
| 基础 | Debian Bookworm、Linux live-boot、固件与 Xorg | 提供可启动的 LiveCD 与广泛硬件兼容性。 |
| 桌面 | Openbox、picom、ElevenDE、LightDM GTK Greeter | 保持 X11 窗口管理器和登录路径轻量，同时提供 ElevenDE 的 Shell、开始菜单、任务栏、SAS、资源管理器与内置应用。 |
| 安装器 | Calamares + `lindows-installer` 启动器 | Live 会话可从桌面或开始菜单启动图形化安装；ISO 启动菜单同时保留 Debian Installer Live 入口作为恢复路径。 |
| 中文输入 | Fcitx5、GTK/Qt 前端、Chinese Addons、Noto CJK | 默认启动 Fcitx5，提供中/英切换和拼音输入，并确保 GTK3/Qt6 应用能获取输入法环境变量。 |
| 常用应用 | Firefox ESR、VLC、Eye of GNOME、PeaZip Qt6 | 提供浏览、视频、图片和压缩解压能力。PeaZip 使用固定的官方发布 DEB 及 SHA-256 校验。 |
| 系统工具 | LinuxPCManager、linux-regedit、lindows-bsod、devmgr | 集成用户指定的 Windows 风格电脑管家、注册表编辑器、蓝屏演示工具和设备管理器。危险操作仅在用户显式启动后使用 pkexec/root 权限。 |

## 第三方组件固定版本

构建流程使用提交标识固定源代码，而不是构建时追随默认分支。工作流会从 HTTPS 获取代码、校验提交标识后在 Debian Bookworm 环境构建；不会执行上游提供的安装脚本。

| 组件 | 源码 | 固定提交 | 集成方式 | 许可状态 |
|---|---|---|---|---|
| ElevenDE | [SYSTEM-Intel-MIC/ElevenDE](https://github.com/SYSTEM-Intel-MIC/ElevenDE) | `80d833958ad84f27b2890160a31d1443fe3c5ba6`；许可证变更提交 `a3b9c9ed17065cc2452678fd0cfe03deda33ab11` | 在 Bookworm 构建容器中从云端固定提交执行 `build-deb.sh` | ElevenDE 自有代码 GPL-3.0-or-later；原文副本见 [`LICENSES/GPL-3.0-ElevenDE.txt`](../LICENSES/GPL-3.0-ElevenDE.txt)；SAS/Explorer/runbox-linux 按各自上游声明。 |
| LinuxPCManager | SYSTEM-Intel-MIC/LinuxPCManager | `4a744338aff580d4c7260bb00cbebfe8521bcf80` | 仅复制已审查的 Python/Tk 源码与桌面入口，制作本地 DEB。 | 当前云端页面未显示 LICENSE 文件；不将其重新标为 GPL，随镜像提供来源与原始说明。 |
| linux-regedit | heyManNice/regedit | `0e3de3dcfbf1aca0fbc8dda2be307a1224c0f04f` | Meson/Ninja 构建，制作本地 DEB。 | 当前云端页面未显示 LICENSE，许可状态未明确；不将其重新标为 GPL。 |
| lindows-bsod | heyManNice/bsod | `45757f64e6fa2983e92382a2ba8e47b1685d92f9` | Meson/Ninja 构建，安装为按需运行的 root 工具。 | MIT。 |
| devmgr | daimile2/Device-Manager-But-Linux | `e7e8238cc72a08ce0302e4ffbd529838f49fbed4` | Go 1.24 Bookworm 容器构建 GUI 与 CLI，制作本地 DEB。 | MIT。 |
| PeaZip | peazip/PeaZip 11.2.0 | 固定官方发布 | 下载 `peazip_11.2.0.LINUX.Qt6-1_amd64.deb`，核对 SHA-256 后安装。 | LGPLv3，随上游 DEB 提供。 |
| SAS-for-Linux | [macOS-Terminal/SAS-for-Linux](https://github.com/macOS-Terminal/SAS-for-Linux) | `6f06ef4c2817729d6c1359a800458f683b4878f4` | 随云端 ElevenDE 源码构建。 | MIT；Copyright (c) 2026 macOS-Terminal；保留上游 MIT 条款。 |
| Explorer-for-Linux | [macOS-Terminal/Explorer-for-Linux](https://github.com/macOS-Terminal/Explorer-for-Linux) | 上游许可证提交 `18676e1ce74b4dfa0c4eb897bc6c7cfe681f9db6`；ElevenDE 集成提交 `80d833958ad84f27b2890160a31d1443fe3c5ba6` | 随云端 ElevenDE 源码构建；ElevenDE 对 Explorer 核心源文件、构建元数据和集成方式进行了重大修改与基本重构。 | 上游原始部分 MIT；ElevenDE 修改/重构部分按 GPL-3.0-or-later 声明，不能把整个重构副本简单标成单一许可证。 |
| runbox-linux | [SYSTEM-Intel-MIC/runbox-linux](https://github.com/SYSTEM-Intel-MIC/runbox-linux) | `a8a4786` | 随云端 ElevenDE 源码构建。 | README 明确 MIT；保留独立 MIT 条款。 |

## 构建边界与安全原则

GitHub Actions 分为两个阶段。第一阶段在 Debian Bookworm 容器中从固定源码生成 ElevenDE 和第三方组件的本地 `.deb` 文件。第二阶段调用 `live-build`，将这些已构建软件包、启动配置、桌面文件、输入法设置和品牌文件放入 Live chroot。构建完成后上传 ISO、构建日志、软件包清单和组件校验记录。

蓝屏组件不会注册为守护进程，也不会监听日志后自动运行。它仅以 `lindows-bsod` 命令和桌面入口存在，默认使用恢复桌面的模式；其 DRM/VT 操作需要用户主动授权。电脑管家、设备管理器和注册表编辑器同样不自动执行清理、设备驱动变更或系统配置写入。

## 轻量化取舍

Lindows 不安装 GNOME、KDE、task-desktop 或完整办公套件。Calamares 是为 Live 安装程序保留的最大单项依赖；其余桌面功能由 ElevenDE、Openbox 和单用途应用提供。Firefox ESR、VLC、PeaZip 与 Noto CJK 是用户明确要求的应用与语言支持，因此属于镜像的功能性基础，而非可选桌面元包。

## 外部来源记录

| 资源 | 已核验信息 | 来源 |
|---|---|---|
| ElevenDE | 云端提交 `a3b9c9ed17065cc2452678fd0cfe03deda33ab11` 将 ElevenDE 自有代码切换为 GPL-3.0-or-later，后续固定提交为 `80d833958ad84f27b2890160a31d1443fe3c5ba6`；Lindows 的许可证副本与上游 LICENSE 校验一致，并记录 SAS、Explorer、runbox-linux 上游边界。 | <https://github.com/SYSTEM-Intel-MIC/ElevenDE> |
| SAS-for-Linux | 当前 `main` 提交 `6f06ef4c2817729d6c1359a800458f683b4878f4` 已包含 MIT LICENSE，版权为 Copyright (c) 2026 macOS-Terminal。 | <https://github.com/macOS-Terminal/SAS-for-Linux> |
| Explorer-for-Linux | 当前 `main` 提交 `18676e1ce74b4dfa0c4eb897bc6c7cfe681f9db6` 已包含 MIT LICENSE；ElevenDE 固定副本 `80d833958ad84f27b2890160a31d1443fe3c5ba6` 对核心代码进行了重大修改和基本重构。 | <https://github.com/macOS-Terminal/Explorer-for-Linux> |
| runbox-linux | 当前 `main` 提交 `a8a4786`，README 明确标注 MIT。 | <https://github.com/SYSTEM-Intel-MIC/runbox-linux> |
| LinuxPCManager | README 声明 Debian/Ubuntu 支持、Python 3 + Tkinter 和相关权限工具；当前页面未显示 LICENSE 文件。 | <https://github.com/SYSTEM-Intel-MIC/LinuxPCManager> |
| linux-regedit | 当前页面未显示 LICENSE 文件，许可状态未明确。 | <https://github.com/heyManNice/regedit> |
| bsod | README 说明需要 libdrm、FreeType、fontconfig、libsystemd，且运行时需 root 操作 VT/DRM；仓库 `LICENSE` 为 MIT。 | <https://github.com/heyManNice/bsod> |
| Device Manager | README 说明 GUI 使用 Fyne、提供 `devmgr`/`devmgr-cli`，危险设备操作通过 pkexec；仓库 `LICENSE` 为 MIT。 | <https://github.com/daimile2/Device-Manager-But-Linux> |
| Fcitx5 中文 | Debian Bookworm 的 `fcitx5-chinese-addons` 元包依赖拼音和表格输入组件。 | <https://packages.debian.org/bookworm/fcitx5-chinese-addons> |
| Firefox ESR | Debian Bookworm 官方提供 `firefox-esr`。 | <https://packages.debian.org/bookworm/firefox-esr> |
| 图片查看器 | Debian Bookworm 官方提供 `eog`（Eye of GNOME）。 | <https://packages.debian.org/bookworm/eog> |
| Calamares | Debian Bookworm 官方提供发行版独立的图形化安装器框架。 | <https://packages.debian.org/bookworm/calamares> |
| PeaZip | Debian Bookworm 未提供 `peazip` 包；使用官方 GitHub 11.2.0 Qt6 AMD64 DEB，并固定 SHA-256 `11af7ca6fd633566eb8de969b43ca257b8bce759421775c8c7bbb66105406e58`。 | <https://github.com/peazip/PeaZip/releases/tag/11.2.0> |
