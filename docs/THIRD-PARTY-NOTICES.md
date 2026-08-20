# Lindows 第三方组件与许可证声明

Copyright © 2026 SYSTEM-Intel-MIC。Lindows 自有的构建脚本、配置、打包元数据、品牌资源、文档和集成代码，除文件另有说明外，采用 GNU GPL-3.0-or-later，许可证全文见 [`LICENSE`](../LICENSE)。

本仓库是一个聚合发行项目。**根目录的 GPL 许可证不会改变第三方组件的原始许可证。** 每个第三方组件仍按其上游许可证、版权声明和分发条件提供。许可证文本副本见 [`LICENSES/`](LICENSES/)。

## 固定组件清单

| 组件 | 上游来源与固定版本 | 许可证状态 | Lindows 分发说明 |
|---|---|---|---|
| ElevenDE 3.5.1 | [SYSTEM-Intel-MIC/ElevenDE](https://github.com/SYSTEM-Intel-MIC/ElevenDE)，固定提交 `80d833958ad84f27b2890160a31d1443fe3c5ba6` | ElevenDE 自有代码 GPL-3.0-or-later | 构建脚本从云端固定提交克隆，不再使用本地旧压缩包；SAS/Explorer/runbox-linux 按各自上游声明。 |
| Copilot for Linux 1.0.0 | [com-in/Copilot-For-Linux](https://github.com/com-in/Copilot-For-Linux)，固定提交 `842248411d1046881023e100073320c5dbd62b57` | GPL-3.0 | 通过固定 Release DEB 集成；源码可从上游固定提交获取，Lindows 不写入 API 密钥。 |
| LinuxPCManager | [SYSTEM-Intel-MIC/LinuxPCManager](https://github.com/SYSTEM-Intel-MIC/LinuxPCManager)，固定提交 `4a744338aff580d4c7260bb00cbebfe8521bcf80` | 当前上游页面未显示 LICENSE 文件；README 声明代码为个人学习目的的独立开源复刻 | 不将其重新标为 GPL；保留上游 README、来源和固定提交信息。若单独再发布该组件，应先取得明确许可证授权。 |
| linux-regedit | [heyManNice/regedit](https://github.com/heyManNice/regedit)，固定提交 `0e3de3dcfbf1aca0fbc8dda2be307a1224c0f04f` | 当前上游页面未显示 LICENSE 文件；当前审计未能确认可执行的明确许可证 | 不将其重新标为 GPL；仅按当前上游授权状态分发，并保留来源。建议上游作者补充明确许可证或提供书面授权。 |
| bsod | [heyManNice/bsod](https://github.com/heyManNice/bsod)，固定提交 `45757f64e6fa2983e92382a2ba8e47b1685d92f9` | MIT | 保留 MIT 版权和许可证文本；Lindows 入口仅以 `--restore` 演示模式调用。 |
| Device Manager | [daimile2/Device-Manager-But-Linux](https://github.com/daimile2/Device-Manager-But-Linux)，固定提交 `e7e8238cc72a08ce0302e4ffbd529838f49fbed4` | MIT | 保留 MIT 版权和许可证文本。 |
| PeaZip 11.2.0 | [peazip/PeaZip](https://github.com/peazip/PeaZip)，官方 `peazip_11.2.0.LINUX.Qt6-1_amd64.deb` | LGPL-3.0 | 使用上游官方二进制包；构建脚本校验 SHA-256 `11af7ca6fd633566eb8de969b43ca257b8bce759421775c8c7bbb66105406e58`。源码和许可证从上游项目获取。 |
| SAS-for-Linux | [macOS-Terminal/SAS-for-Linux](https://github.com/macOS-Terminal/SAS-for-Linux)，固定提交 `7b933fa` | 当前云端页面未显示 LICENSE，状态未明确 | 不因 ElevenDE 根目录 GPL 而自动重新授权；保留上游来源和状态。 |
| Explorer-for-Linux | [macOS-Terminal/Explorer-for-Linux](https://github.com/macOS-Terminal/Explorer-for-Linux)，固定提交 `4a9e19f` | 当前云端页面未显示 LICENSE，状态未明确 | 不因 ElevenDE 根目录 GPL 而自动重新授权；保留上游来源和状态。 |
| runbox-linux | [SYSTEM-Intel-MIC/runbox-linux](https://github.com/SYSTEM-Intel-MIC/runbox-linux)，固定提交 `a8a4786` | MIT（README 明确声明） | 保留 MIT 版权和许可证条件；不将其改标为 GPL。 |

## ElevenDE 上游边界

云端 ElevenDE 固定提交为 `80d833958ad84f27b2890160a31d1443fe3c5ba6`。ElevenDE 自有代码按 GPL-3.0-or-later 发布，并集成 SAS-for-Linux、Explorer-for-Linux 与 runbox-linux。前两个上游页面未显示明确 LICENSE；runbox-linux README 明确为 MIT。ElevenDE 根目录的 GPL 不自动改写这些上游组件。

## Debian 与系统依赖

Firefox ESR、VLC、Calamares、Fcitx5、Xorg、Openbox、NetworkManager 以及其他 Debian 软件包均由 Debian Bookworm 软件源提供，并保留各自的版权和许可证。安装后的系统应以 `/usr/share/doc/<package>/copyright` 为准；Lindows 不对 Debian 软件包重新授权。

Electron、Node.js、Python、GTK、Qt、Fyne、Go、GNU 工具链以及其他构建或运行时依赖也保留各自许可证。它们不是 Lindows 自有代码的一部分。

## 源码与对应源代码请求

Lindows 的自有集成代码、构建脚本和配置随本仓库发布。GPL 组件的对应源码可通过上表中的固定提交获取；构建脚本中使用的版本和校验值位于 [`scripts/build-lindows-components.sh`](scripts/build-lindows-components.sh) 与 [`vendor/SHA256SUMS`](vendor/SHA256SUMS)。对于官方二进制 PeaZip，使用其上游源码仓库和官方发布页面获取对应源码及 LGPL-3.0 许可证。

如果某个组件的上游许可证状态发生变化，发布者必须在制作新 ISO 或 DEB 前重新审计并更新本文件；许可证未明确的组件不得被宣传为 GPL 组件。

## 商标与品牌

“Windows”、“Microsoft”、“Copilot”等名称和标志可能属于其各自权利人。Lindows 是独立的 Linux 发行版项目，不代表或获得 Microsoft 授权；上游项目的商标声明继续有效。
