//
//  ContentView.swift
//  VisionKeyboard
//
//  Created by Andy on 2025/7/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(HandViewModel.self) var viewModel
    
    var body: some View {
        Text(viewModel.totalText)
            .font(.largeTitle)
            .onAppear(){
                Task {
                    await openImmersiveSpace(id: "HandView")
                }
            }
    }
}
