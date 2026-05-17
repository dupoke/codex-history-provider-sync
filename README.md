# Codex History Provider Sync

一个用于恢复 Codex Desktop 本地历史对话显示的 Windows 小工具。

当你切换 API、provider、模型或登录方式之后，Codex Desktop 有时会出现“本地历史明明还在，但侧边栏看不到”的情况。这个工具会检查本机的本地历史数据库、会话文件和侧边栏索引，并把旧线程重新挂到当前正在使用的 `model_provider` / `model` 下面。

本仓库是基于 [GODGOD126/codex-history-sync-tool](https://github.com/GODGOD126/codex-history-sync-tool) 的 MIT 许可版本整理而来，正式名称为 **Codex History Provider Sync**。

## 这个工具能做什么

- 查看当前本机 Codex 历史线程属于哪些 provider 和 model
- 一键把旧 provider / model 下的线程、会话元数据和侧边栏索引同步到当前设置
- Codex Desktop 正在运行时也可以同步；如果本地数据库正在写入，工具会等待空闲后继续
- 在同步前自动备份数据库、侧边栏索引和会话元数据
- 从备份恢复数据库
- 提供一个可直接点击的 Windows 图形界面

## 适用场景

- 你切换了不同 API、provider、模型或登录方式
- 你把官方接入换成了 OpenAI 兼容 API / 自定义 `base_url`
- 你确认本地历史文件还在，但 Codex Desktop 左侧历史列表变空了

## 不适用的场景

- 云端账号之间的聊天记录互相同步
- 本地历史文件已经被删除
- 不同电脑之间迁移聊天记录

## 运行环境

- Windows
- PowerShell 5.1 或更高版本
- Python 3.10 或更高版本
- 本机存在 Codex Desktop 本地数据目录，通常是 `%USERPROFILE%\.codex`

## 快速使用

### 图形界面

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\launch_ui.ps1
```

也可以双击 `Start-Codex-History-Provider-Sync.cmd`。中文入口 `双击启动.cmd` 也会保留。发布压缩包里的普通用户说明是 `使用说明.md`。

### 创建桌面快捷方式

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\launch_ui.ps1 -InstallShortcutOnly
```

### 查看当前状态

```powershell
py -3 .\sync_backend.py --json status
```

### 执行同步

```powershell
py -3 .\sync_backend.py --json sync
```

### 手动创建备份

```powershell
py -3 .\sync_backend.py --json backup
```

### 从最新备份恢复

```powershell
py -3 .\sync_backend.py --json restore
```

### 运行测试

```powershell
py -3 -m unittest discover -s tests -v
```

### 打包发布

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\package_release.ps1 -Version v0.1.0
```

压缩包会生成在 `dist/`，文件名形如 `codex-history-provider-sync-v0.1.0.zip`。

## 附带文档

- [Codex API Fast Mode Patch Note](docs/codex-api-fast-mode-patch.md)：公开清理版的 Fast/Speed 模式补丁说明，已移除本机设备信息、用户名、token、绝对私有路径等内容。

## 备份说明

- 每次同步前都会自动创建一份备份
- 每次恢复前也会先创建一份安全备份
- 备份默认保存在 `%USERPROFILE%\.codex\history_sync_backups`
- 新版备份会同时保存 `session_index.jsonl` 和会话文件首行元数据，恢复时会一起还原

## 使用建议

- Codex Desktop 开着也可以同步；如果它正在生成回复或保存历史，工具可能会等待几秒
- 恢复备份会覆盖当前状态，最稳妥的做法仍然是在恢复前暂停正在运行的 Codex 任务
- 如果同步完成后历史列表没有立刻刷新，重开一次 Codex Desktop 即可
- 新版 Codex 可能还会按当前项目目录显示历史。如果同步后仍然看不到旧对话，先确认是否打开了旧对话原来的项目目录；本工具默认不会批量改写线程的 `cwd` 项目归属。

## 项目文件

- `sync_backend.py`：后端同步、备份、恢复逻辑
- `launch_ui.ps1`：Windows 图形界面
- `package_release.ps1`：发布压缩包打包脚本
- `docs/`：附带说明文档

## 免责声明

这个工具直接操作本机 Codex 的本地状态数据库。虽然已经做了自动备份，但仍建议你在使用前先理解它的作用，并自行确认本地数据目录状态。
