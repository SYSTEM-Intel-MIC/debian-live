# Copilot for Linux 与 Feedback Hub for Linux 审计

审计日期：2026-08-18。审计对象为用户指定的两个上游仓库，均采用只读方式获取和检查，未执行上游安装脚本。

| 组件 | 上游仓库 | 许可证 | 技术栈与依赖 | Debian 集成方式 |
|---|---|---|---|---|
| Copilot for Linux | https://github.com/com-in/Copilot-For-Linux | GPL-3.0 | Electron、Node.js、npm；README 提供 `npm install` 和 `npm run build:all`，项目已有 DEB 构建脚本与桌面应用入口 | 固定源码提交后使用 npm 依赖安装和上游 DEB 产物流程，优先在 Debian Bookworm 容器内构建；不纳入 API 密钥，用户自行配置 OpenAI-compatible API |
| Feedback Hub for Linux | https://github.com/com-in/FeedbackHub-For-Linux | GPL-3.0 | Python 3、PyGObject、GTK 3；`build_deb_linux.sh` 使用 `dpkg-deb` 生成 `feedbackhub_<version>_all.deb` | 固定源码提交后在 Debian Bookworm 容器内调用已审阅的本地打包逻辑，安装 `python3`, `python3-gi`, `gir1.2-gtk-3.0` 和桌面入口 |

## Copilot 审计结论

Copilot for Linux 是 Electron 桌面面板，默认以右 Ctrl 全局快捷键唤起，支持 Markdown、流式聊天、主题切换和 OpenAI-compatible API。其仓库声明 GPL-3.0，并包含 Linux DEB、RPM、AppImage 与 pacman 构建脚本。Lindows 构建不会注入 API 密钥，也不会在 Live 镜像中写入用户凭据；首次使用时由用户在应用设置中配置服务地址和密钥。

## Feedback Hub 审计结论

Feedback Hub for Linux 是本地 GTK 应用，反馈、投票和评论数据保存于用户的 `~/.local/share/feedbackhub/`，项目 README 声明不发送数据。其 DEB 构建脚本明确依赖 `python3`、`python3-gi` 和 `gir1.2-gtk-3.0`，并安装 `/usr/bin/feedbackhub`、桌面文件、SVG 图标及文档。该组件可直接作为 Lindows 的本地反馈中心集成。

## 固定版本

当前锁定值如下：Copilot for Linux 版本 `1.0.0`，提交 `842248411d1046881023e100073320c5dbd62b57`；Feedback Hub for Linux 版本 `1.0.0`，提交 `67befa32fc742a9a33080b0c2afa8f95f40ee3d9`。构建脚本使用固定提交而不是默认分支最新内容。上游源码只在组件构建容器中处理，构建日志不得包含任何用户 API 密钥。
