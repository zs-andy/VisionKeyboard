//
//  HandView.swift
//  VisionKeyboard
//
//  Created by Andy on 2025/7/24.
//

import Foundation
import RealityKit
import SwiftUI
import ARKit
struct HandView: View {
    @State var hand = HandClass()
    @Environment(HandViewModel.self) var viewModel
    
    var body: some View {
        RealityView { content in
            let rootEntity = hand.RootEntity
            hand.setupEntity(with: viewModel)
            content.add(rootEntity)
        }.task {
            do {
                let checkHandTracking = hand.checkHandTracking()
                try await hand.session.run([hand.handTracking])
            } catch {
                print("Unable to start session", error)
            }
        }.task {
            await hand.continuousHandUpdate(using: viewModel) // ✅ 注入 viewModel
        }
    }
}
