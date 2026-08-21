# ElevenDE Explorer 代码来源与许可证边界

## 结论

ElevenDE 集成的 `Explorer-for-Linux` 不能被当作未经修改的上游副本。Lindows 构建使用的 ElevenDE 固定提交为 `80d833958ad84f27b2890160a31d1443fe3c5ba6`；该提交中的 `Explorer-for-Linux` 目录没有单独的 LICENSE 文件，并且与上游 `macOS-Terminal/Explorer-for-Linux` 的 MIT 版本存在重大差异。静态对比显示，Explorer 核心源文件、CMake 构建文件和集成元数据均有差异，ElevenDE 对该组件进行了实质修改和基本重构。

| 层次 | 来源 | 许可证处理 |
|---|---|---|
| 上游 Explorer 原始代码 | [macOS-Terminal/Explorer-for-Linux](https://github.com/macOS-Terminal/Explorer-for-Linux)，许可证提交 `18676e1ce74b4dfa0c4eb897bc6c7cfe681f9db6` | MIT；保留 `Copyright (c) 2026 macOS-Terminal`、MIT 条款和来源链接。 |
| ElevenDE Explorer 修改/重构 | [SYSTEM-Intel-MIC/ElevenDE](https://github.com/SYSTEM-Intel-MIC/ElevenDE)，固定提交 `80d833958ad84f27b2890160a31d1443fe3c5ba6` | 按 ElevenDE 的 GPL-3.0-or-later 声明处理，但不消灭上游原始代码的 MIT 条件。 |
| Lindows 构建补丁 | 本仓库 `scripts/`、配置和打包集成 | 按 Lindows GPL-3.0-or-later 许可，且不改变上游或 ElevenDE 的既有边界。 |

因此，Lindows 文档不会把这个重构后的 Explorer 整体简单标记为“纯 MIT”或“纯 GPL”。分发时应同时提供本仓库的第三方声明、MIT 文本副本、ElevenDE GPL 文本及对应固定源码获取地址。

## 依据

1. [Explorer-for-Linux 上游 LICENSE](https://github.com/macOS-Terminal/Explorer-for-Linux/blob/main/LICENSE)
2. [Explorer-for-Linux 上游许可证提交](https://github.com/macOS-Terminal/Explorer-for-Linux/commit/18676e1ce74b4dfa0c4eb897bc6c7cfe681f9db6)
3. [ElevenDE 固定集成提交](https://github.com/SYSTEM-Intel-MIC/ElevenDE/commit/80d833958ad84f27b2890160a31d1443fe3c5ba6)
