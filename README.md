# MinimizeAll

一个 macOS 菜单栏小工具：一键最小化所有正在运行的 App 窗口。

基于 Swift + SwiftUI/AppKit 的 Accessibility API 实现，常驻菜单栏、不占用 Dock，支持全局快捷键与开机自启。

## 功能特性

- 一键最小化所有前台 App 的标准窗口（跳过已最小化的窗口）
- 自动退出全屏窗口后最小化
- 全局快捷键（默认 `⌘ + Shift + M`）
- 菜单栏图标操作：双击触发、右键菜单
- 开机自启（基于 `SMAppService`）
- 辅助功能权限检测与引导授权

## 环境要求

- macOS 13.0 及以上
- Xcode 15+ / Swift 5.9+（Swift Package Manager）

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/greatwoo01/MinimizeAll.git
cd MinimizeAll

# 构建并以 release 模式运行（菜单栏常驻）
./run.sh

# 仅构建
./build.sh

# Debug 构建
./build.sh debug

# 清理构建产物
./build.sh clean
```

### 打包成 .app

```bash
./package.sh
# 产物：dist/MinimizeAll.app
open dist/MinimizeAll.app
```

脚本会使用 ad-hoc 签名（`codesign --sign -`），仅适用于本机运行。若要分发给他人，需要 Apple Developer ID 证书并完成 notarize（公证）。

## 使用方法

1. 首次运行后，应用会驻留在菜单栏，图标为 `rectangle.compress.vertical`。
2. 首次触发最小化时会提示授予「辅助功能」权限：
   - 打开「系统设置 → 隐私与安全性 → 辅助功能」
   - 勾选 MinimizeAll
3. 触发方式：
   - **双击菜单栏图标**
   - **右键菜单 → 最小化所有窗口**
   - **全局快捷键** `⌘ + Shift + M`

> 权限说明：最小化其他应用窗口依赖 macOS 的 Accessibility API，因此必须授予辅助功能权限，否则无法操作其他 App 的窗口。

## 项目结构

```
MinimizeAll/
├── Package.swift                        # SwiftPM 配置
├── Info.plist                           # App Bundle 信息（LSUIElement 菜单栏模式）
├── build.sh                             # 构建脚本
├── run.sh                               # 构建并运行脚本
├── package.sh                           # 打包 .app 并签名
└── Sources/MinimizeAll/
    ├── main.swift                       # 入口，设置 .accessory 激活策略
    ├── AppDelegate.swift                # 应用生命周期与模块装配
    ├── MenuBarController.swift          # 菜单栏图标、双击判定与右键菜单
    ├── HotKeyManager.swift              # Carbon 全局快捷键注册
    ├── WindowMinimizer.swift            # Accessibility API 窗口最小化逻辑
    ├── PermissionManager.swift          # 辅助功能权限检测与引导
    └── SettingsStore.swift              # UserDefaults 偏好持久化
```

## 核心实现

- **窗口最小化**：通过 `AXUIElementCreateApplication` 获取应用元素，遍历 `kAXWindowsAttribute`，过滤标准窗口（`AXStandardWindow`），再设置 `kAXMinimized` 为 `true`；失败时回退调用 `AXMinimize` 动作。
- **全屏处理**：检测窗口的 `AXFullScreen` 属性，若为全屏则先退出全屏再最小化。
- **全局快捷键**：使用 Carbon 的 `RegisterEventHotKey`，无需额外权限，可全局生效。
- **菜单栏交互**：`NSStatusItem` 监听左右键，单双击用 250ms 定时器区分，双击触发最小化、单击弹出菜单。

## 自定义快捷键

默认快捷键为 `⌘ + Shift + M`，可通过 `SettingsStore` 的 `hotKeyModifiers` 与 `hotKeyKeyCode` 修改并持久化到 `UserDefaults`。当前的「设置…」菜单项为占位实现，可在此处挂载完整的设置窗口。

## 已知限制

- 部分不受标准窗口模型管理的 App（如自定义绘制的浮层、部分全屏游戏）可能无法被最小化。
- 需要辅助功能权限，未授权时不会执行任何最小化操作。
- ad-hoc 签名的 `.app` 在其他机器上首次打开可能需要在「系统设置 → 隐私与安全性」中手动允许。

## License

本项目未指定开源许可证，如需使用请先联系作者。
