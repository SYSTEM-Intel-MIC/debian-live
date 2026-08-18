# 云端 ElevenDE 许可证审计

审计对象：

- ElevenDE：https://github.com/SYSTEM-Intel-MIC/ElevenDE
- SAS-for-Linux：https://github.com/macOS-Terminal/SAS-for-Linux
- Explorer-for-Linux：https://github.com/macOS-Terminal/Explorer-for-Linux

## 已核实

| 项目 | 云端当前状态 | 处理结论 |
|---|---|---|
| ElevenDE | 历史审计时 `c388f41` 页面显示 MIT；随后 ElevenDE 权利人在云端提交 `a3b9c9ed17065cc2452678fd0cfe03deda33ab11` 正式将自有代码切换为 GPL-3.0-or-later，并在 `80d833958ad84f27b2890160a31d1443fe3c5ba6` 补充 runbox-linux 声明。 | 以最新云端 LICENSE 和提交记录为准：ElevenDE 自有代码按 GPL-3.0-or-later；SAS、Explorer、runbox-linux 仍按各自上游许可边界处理。 |
| SAS-for-Linux | 当前 `main` 最新提交为 `7b933fa`，页面展示源代码、CMakeLists 和 README，但未显示根目录 LICENSE 文件；README 未给出可执行的明确许可证。 | 许可证状态未明确；不能未经授权将其代码标为 GPL。应保留来源和固定提交，并建议上游作者先补充 GPL LICENSE。 |

## 待核实

Explorer-for-Linux 页面将在下一步读取。云端 ElevenDE 目录同时包含 `SAS-for-Linux/` 与 `Explorer-for-Linux/`，但这不等于下游可以替上游改变许可证。

## 发布边界

Lindows 可以把自己的构建脚本、配置、打包元数据、品牌资源和原创集成代码按 GPL-3.0-or-later 发布；但第三方代码仍受其原许可证约束。若用户希望 ElevenDE、SAS 或 Explorer 本身改用 GPL，需要对相应上游仓库执行独立的许可证变更，并确认所有贡献者拥有必要的版权授权。

| Explorer-for-Linux | 当前 `main` 最新提交为 `4a9e19f`，页面显示源代码、README、构建文件和实验性资源管理器内容，但未显示根目录 LICENSE 文件，README 未给出明确许可证。 | 许可证状态未明确；不能未经授权将 Explorer-for-Linux 标为 GPL。保留上游来源、固定提交并建议上游作者补充明确 GPL LICENSE。 |

## 云端审计结论

历史审计结论已被云端更新取代。当前以 ElevenDE 提交 `80d833958ad84f27b2890160a31d1443fe3c5ba6` 为准：ElevenDE 自有代码已按 GPL-3.0-or-later 发布；SAS-for-Linux 与 Explorer-for-Linux 当前未显示明确 LICENSE；runbox-linux README 明确为 MIT。Lindows 下游继续保留这些独立上游许可边界。

| runbox-linux | [SYSTEM-Intel-MIC/runbox-linux](https://github.com/SYSTEM-Intel-MIC/runbox-linux)，当前 `main` 最新提交为 `a8a4786`；README 明确标注 MIT，页面当前未展示独立 LICENSE 文件。 | 按上游 README 的 MIT 声明处理；ElevenDE 的 GPL 不自动改变 RunBox 的 MIT 条款。Lindows 与 ElevenDE 的第三方声明应保留 RunBox 来源、固定提交和 MIT 文本。 |
