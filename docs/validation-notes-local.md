# Lindows 2.0 本地验证记录

## 2026-08-22：ISO 完整性回归与新增门控

本地早期 XZ SquashFS ISO 曾通过目录列表和有限 QEMU 存活检查，但实际图形虚拟机中出现以下读取错误：

```text
SQUASHFS error: xz decompression failed, data probably corrupt
SQUASHFS error: Failed to read block ... -5
```

这证明仅检查 ISO 内文件名或 QEMU 进程仍在运行不足以证明 Live 系统可用。Lindows 已将 `scripts/validate-lindows-live-image.sh` 改为先完整 `unsquashfs` 解压最终 `/live/filesystem.squashfs`，再检查 Calamares、原生 ElevenDE 服务、无 LightDM、组件适配器、Lindows Store 和 20 个图标别名。旧 XZ 映像因此不再可能被误判为有效产物。

随后一次使用 gzip SquashFS 的本地重建已通过完整 SquashFS 展开，但图形虚拟机在选择默认 Live 启动项后于早期启动阶段报出：

```text
Kernel panic - not syncing: No working init found.
```

对该 ISO 的 `/live/initrd.img` 运行 `lsinitramfs` 得到 `cpio: premature end of archive`，证明该 initrd 同样损坏或截断。因此该 gzip ISO 也**不是**可交付成果；它不能用作 ElevenDE Live 桌面、组件或 Calamares 的通过证据。

为防止再次发生同类漏检，最终 ISO 验证现已同时抽取并完整枚举 `/live/initrd.img`，且要求其中存在顶层 `init`。BIOS/UEFI 冒烟脚本也已改为通过 QEMU monitor 主动按下默认 Live 启动项、保存启动后的帧，避免把静止的启动菜单误报为成功。

下一项验证将在 GitHub Actions 的干净托管构建器中从锁定 package layer 重新生成 ISO，并由新的完整 SquashFS 与 initrd 门控先行验证。只有下载该可信 ISO 回本地虚拟机，确认 Live 免登录进入 ElevenDE、组件入口与 Calamares 安装路径后，才可以把 Lindows 2.0 视为本地回归通过。当前状态：**仍在验证，不可交付。**
