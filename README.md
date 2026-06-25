# ClipboardSticky 🗂️

一个轻量的 macOS 剪贴板便利贴工具，类似 uPaste 的免费开源替代。

在屏幕边缘（左侧或右侧）驻留，鼠标悬停即可滑出完整面板，浏览剪贴板历史并一键复制。

## 功能

- **屏幕边缘驻留** — 小标签常驻屏幕左侧或右侧，不占空间
- **悬停/点击展开** — 鼠标悬停标签即滑出面板，移开自动收起
- **剪贴板历史** — 自动记录文本、HTML、图片、文件等多种类型
- **搜索过滤** — 快速查找历史记录
- **固定项目** — 将常用内容固定在列表顶部
- **来源应用显示** — 每条记录显示来源应用图标
- **全局快捷键** — `Cmd+Shift+V` 快速切换面板
- **毛玻璃效果** — 原生 macOS HUD 风格，深色/浅色模式适配
- **开机启动** — 支持添加为登录项
- **低内存占用** — 仅 ~30MB，相比 Electron 方案轻量 6-8 倍

## 安装

### 从源码构建

```bash
# 克隆
git clone https://github.com/yourusername/ClipboardSticky.git
cd ClipboardSticky

# 生成 Xcode 项目（需要 XcodeGen）
brew install xcodegen
make project

# 构建 & 运行
make run
```

或在 Xcode 中打开 `ClipboardSticky.xcodeproj`，按 `Cmd+R` 运行。

### 系统要求

- macOS 14.0+
- Xcode 15.0+（构建用）

## 使用方法

1. **启动应用** — 应用会在屏幕右侧（默认）出现一个小标签
2. **展开面板** — 鼠标悬停在标签上，面板滑出
3. **浏览历史** — 复制任何内容（文本、图片等），自动出现在列表中
4. **使用历史** — 点击任意条目复制回剪贴板，右键查看更多选项
5. **固定面板** — 点击 📌 图标锁定面板，防止自动收起
6. **切换位置** — 点击 ↔ 按钮切换到屏幕另一侧
7. **快捷键** — 按 `Cmd+Shift+V` 快速切换面板显隐

## 技术架构

```
SwiftUI + AppKit (原生 macOS)
├── PanelWindow (NSPanel) — 浮动无边框窗口
├── ClipboardMonitor — 0.5s 轮询 NSPasteboard
├── SwiftData — 本地持久化（默认 500 条）
├── Carbon HotKey — 全局快捷键
└── SMAppService — 登录项注册
```

## 设置

- **面板位置** — 左侧 / 右侧
- **面板高度** — 屏幕占比 40%-90%
- **面板宽度** — 250-500pt
- **展开方式** — 悬停 / 点击
- **最大历史条数** — 100/200/500/1000
- **开机启动** — 自动添加到登录项

## 许可

MIT License
