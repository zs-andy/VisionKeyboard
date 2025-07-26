//
//  VisionKeyboardApp.swift
//  VisionKeyboard
//
//  Created by Andy on 2025/7/24.
//

import SwiftUI

@main
struct VisionKeyboardApp: App {
    @Environment(\.scenePhase) private var scene
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State var viewModel = HandViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .onChange(of: scene) { _, newScene in
            switch newScene {
            case .active:
                print("active")
                Task { await openImmersiveSpace(id: "HandView")
                }
            case .background:
                print("background")
                Task { await dismissImmersiveSpace() }
            case .inactive:
                print("inactive")
                Task { await dismissImmersiveSpace() }
            }
        }
//        ImmersiveSpace(id: "PlaneDetection") {
//                   PlaneDetectionView()
//               }
        ImmersiveSpace(id: "HandView"){
            HandView()
                .environment(viewModel)
        }
    }
}
