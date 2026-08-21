# Lindows 第三方许可证审计记录

审计日期：2026-08-21（依据上游 main 分支许可证文件、提交记录和 ElevenDE 固定源码差异核验）。

## 已核实信息

| 组件 | 来源 | 当前核实结果 | 发布处理 |
|---|---|---|---|
| LinuxPCManager | https://github.com/SYSTEM-Intel-MIC/LinuxPCManager | 页面显示仓库根目录没有 LICENSE 文件；README 声明代码为个人学习目的的独立开源复刻、代码全部原创，并声明不代表 Microsoft。 | 不把该组件的许可证擅自改写为 GPL；应保留上游 README 与版权/来源说明，并在 Lindows 中作为独立第三方组件分发。 |
| Copilot for Linux | https://github.com/com-in/Copilot-For-Linux | GitHub 页面明确显示 GPL-3.0 license；README 与 Release 说明亦声明 GPL-3.0。 | 在 Lindows 中保留 GPL-3.0 版权与许可证文本，并提供对应源代码或可获取源码的固定提交链接。 |
| PeaZip | https://github.com/peazip/PeaZip | 公开项目说明其 Linux 版本为 LGPLv3；当前 Lindows 使用官方二进制 DEB。 | 不将 PeaZip 归入 Lindows GPL 代码；保留 LGPLv3 和上游版权信息。 |

## 重要合规边界

Lindows 主仓库可以选择 GPL-3.0-or-later 作为本项目自行编写代码的许可证，但不能通过仓库根目录的 LICENSE 文件单方面改变第三方组件原有许可证。第三方组件必须按其各自许可证保留版权、许可证文本和源码获取方式；若组件没有明确许可证，应避免声称其为 GPL，并保留原始 README、提交信息和来源记录，必要时进一步取得上游授权。

## 追加核实信息

| 组件 | 当前核实结果 | 发布处理 |
|---|---|---|
| linux-regedit | 当前 GitHub 页面根目录显示源码、README 和 Meson 文件，但未显示 LICENSE 文件；README 页面未给出明确许可证声明。 | 不应把其代码重新标为 GPL；在 Lindows 中保留来源、固定提交和“许可证未明确，按上游许可状态分发”的醒目标记，最好后续取得上游书面授权。 |

| bsod | GitHub 页面根目录存在 LICENSE，仓库页面明确显示 MIT license。 | Lindows 的 bsod 集成代码必须保留 MIT 版权和许可证文本；不能因 Lindows 主仓库选择 GPL 而改写为 GPL。 |

| Device Manager But Linux | GitHub 页面根目录存在 LICENSE，README 与页面均明确显示 MIT license。 | 保留 MIT 许可证与版权声明，作为独立第三方组件分发。 |
| PeaZip | GitHub `sources` 分支根目录存在 LICENSE，页面明确显示 LGPL-3.0 license；Lindows 构建下载官方 11.2.0 Qt6 AMD64 DEB。 | 保留 LGPL-3.0，提供官方源码/上游项目链接和原始二进制校验值；不得将 PeaZip 代码或包声明为 GPL。 |

| ElevenDE 3.5.1 | 历史本地包内为 MIT；云端在提交 `a3b9c9ed17065cc2452678fd0cfe03deda33ab11` 将 ElevenDE 自有代码切换为 GPL-3.0-or-later，最新许可边界记录提交为 `80d833958ad84f27b2890160a31d1443fe3c5ba6`。当前上游 LICENSE 为标准 GPL-3.0 文本。 | 以云端最新 LICENSE 为准，ElevenDE 自有代码按 GPL-3.0-or-later；Lindows 保存原文副本 [`LICENSES/GPL-3.0-ElevenDE.txt`](../LICENSES/GPL-3.0-ElevenDE.txt)，SAS、Explorer、runbox-linux 按各自上游声明独立处理。 |

| runbox-linux | [SYSTEM-Intel-MIC/runbox-linux](https://github.com/SYSTEM-Intel-MIC/runbox-linux)，提交 `a8a4786` | README 明确标注 MIT。 | 保留 MIT 条款，不因 ElevenDE GPL 根目录而重新授权。 |

## 结论

Lindows 应采用“**GPL-3.0-or-later 许可自有代码 + 第三方组件按原许可证独立保留**”的聚合发行模式，而不是把整个仓库中所有代码强行标成 GPL。当前审计发现的独立许可证包括 GPL-3.0、MIT、LGPL-3.0，以及若干上游许可证未在当前仓库页面明确声明的组件。对于未明确许可的 LinuxPCManager 与 linux-regedit，应明确标注许可证状态并保留来源，不应在未获得授权前把其源码重新授权为 GPL。
