<div align="center">

# VisionKeyboard

**基于 Apple Vision Pro 指尖追踪与 RealityKit 的 26 键空间手势输入法。**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-visionOS-111827.svg)](#运行环境与本地构建)
[![AdventureX](https://img.shields.io/badge/AdventureX-赛道第四名-F59E0B.svg)](#项目简介)
[![Swift](https://img.shields.io/badge/Swift-ARKit%20%7C%20RealityKit-F05138.svg)](#项目结构)

[English](README.md) | **简体中文**

</div>

---

## 项目简介

空间计算中的传统悬浮键盘往往需要抬手点按，长时间输入容易疲劳。**VisionKeyboard**（AdventureX 赛道第四名）探索了 Apple Vision Pro 上的双手**指尖分组手势输入**：

- 在 `ImmersiveSpace` 中使用 **ARKit `HandTrackingProvider`** 实时追踪双手各指尖关节坐标。
- 通过 **RealityKit** 在指尖上方动态附着 3D 字母分组标签：
  - **左手四指**：`ABC` · `DEF` · `GHI` · `JKL`
  - **右手四指**：`WXYZ` · `TUV` · `PQRS` · `MNO`
- 选中某一组后，对侧手指即刻展开对应单个字母，实现两步直达 26 个英文字母；同时包含基于 **`PlaneDetectionProvider`** 的桌面/平面识别实验视图（`PlaneDetectionView`）。

## 项目结构

```text
VisionKeyboard/
├── VisionKeyboardApp.swift        # 应用生命周期与 ImmersiveSpace（HandView）管理
├── ContentView.swift              # 实时文本输出窗口与空间入口
├── HandView.swift                 # RealityView 与 ARKitSession 持续手部追踪更新
├── HandClass.swift                # HandTrackingProvider、指尖 3D 文本实体与 8 组 26 键映射逻辑
├── HandViewModel.swift            # @Observable 输入状态（inputMode、currentLetter、totalText 等）
├── PlaneDetectionView.swift       # 水平/垂直空间平面检测实验模块
└── Packages/RealityKitContent/    # Reality Composer Pro 材质与空间资源包
```

## 运行环境与本地构建

- **Xcode 15.2+**（需安装 **visionOS SDK**）
- **Apple Vision Pro 真机**（完整 `HandTrackingProvider` 关节追踪需要真机；visionOS 模拟器仅支持基础界面预览）

```sh
git clone https://github.com/zs-andy/VisionKeyboard.git
open VisionKeyboard/VisionKeyboard.xcodeproj
```

1. 在 Xcode 中选择 Apple Vision Pro 设备并配置签名 Team。
2. 按 **⌘R** 编译运行，并授予手部追踪权限。

## 后续方向与参与贡献

非常欢迎对空间交互感兴趣的开发者一起完善：

- **联想词与纠错**：接入 `UITextChecker` 或端侧轻量语言模型提升输入效率。
- **扩展键位**：通过捏合/手势补充空格、退格、标点与数字层。
- **空间音效与触觉替代反馈**：在按键确认瞬间增加空间音频与指尖高亮动画。
- **桌面敲击输入模式**：结合 `PlaneDetectionView` 实现真实桌面上的虚拟敲击检测。

详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 开源协议

基于 [MIT License](LICENSE) 开源。
