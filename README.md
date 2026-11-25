<div align="center">

# VisionKeyboard

**A 26-key spatial gesture keyboard for Apple Vision Pro powered by ARKit fingertip tracking and RealityKit.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-visionOS-111827.svg)](#requirements)
[![AdventureX](https://img.shields.io/badge/AdventureX-Track%204th%20Place-F59E0B.svg)](#overview)
[![Swift](https://img.shields.io/badge/Swift-ARKit%20%7C%20RealityKit-F05138.svg)](#architecture)

**English** | [简体中文](README.zh-CN.md)

</div>

---

## Overview

Typing in spatial computing often forces users to hunt-and-peck across floating virtual keyboards. **VisionKeyboard** (AdventureX Track 4th Place) explores eyes-free, two-hand **fingertip chord input** on Apple Vision Pro:

- Uses **ARKit `HandTrackingProvider`** to track fingertip joints across both hands in real time inside an `ImmersiveSpace`.
- Projects floating 3D letter-group labels directly onto fingertips using **RealityKit** (`ModelEntity` text anchors):
  - **Left hand**: `ABC` · `DEF` · `GHI` · `JKL`
  - **Right hand**: `WXYZ` · `TUV` · `PQRS` · `MNO`
- Selecting a finger group dynamically switches fingertip labels to the individual characters in that group for fast two-step 26-letter input, with experimental **`PlaneDetectionProvider`** (`PlaneDetectionView`) for anchoring spatial surfaces.

## Project Structure

```text
VisionKeyboard/
├── VisionKeyboardApp.swift        # App lifecycle & ImmersiveSpace ("HandView") orchestration
├── ContentView.swift              # Live typed text window & immersive space launcher
├── HandView.swift                 # RealityView driving ARKitSession + continuous hand updates
├── HandClass.swift                # HandTrackingProvider, fingertip 3D text entities & 8-group 26-key mapping
├── HandViewModel.swift            # @Observable state (inputMode, currentLetter, totalText, fastMode)
├── PlaneDetectionView.swift       # Experimental horizontal/vertical ARKit PlaneDetectionProvider view
└── Packages/RealityKitContent/    # Reality Composer Pro spatial assets & materials
```

## Requirements & Running Locally

- **Xcode 15.2+** with the **visionOS SDK** installed
- **Apple Vision Pro** (required for live `HandTrackingProvider` joint updates; the visionOS Simulator launches UI but has limited hand-tracking gestures)

```sh
git clone https://github.com/zs-andy/VisionKeyboard.git
open VisionKeyboard/VisionKeyboard.xcodeproj
```

1. Select your Apple Vision Pro device (or visionOS Simulator) and set your Signing Team.
2. Build and run (**⌘R**); allow Hand Tracking permission when prompted.

## Roadmap & Contributing

Ideas where contributions would make a huge impact:

- **Word prediction / autocorrect** using `UITextChecker` or lightweight n-gram / on-device LM decoding.
- **Backspace, space, punctuation, and numeric layers** via dedicated thumb/pinch chords.
- **Spatial audio & visual highlight feedback** on pinch confirmation to improve typing rhythm.
- **Surface-tapping mode** combining `PlaneDetectionView` with fingertip velocity detection.

See [CONTRIBUTING.md](CONTRIBUTING.md) to get involved.

## License

Licensed under the [MIT License](LICENSE).
