//
//  HandClass.swift
//  VisionKeyboard
//
//  Created by Andy on 2025/7/24.
//

import ARKit
import RealityKit
import SwiftUI
import simd


extension simd_float4x4 {
    var position: SIMD3<Float> {
        SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
    
    var translation: SIMD3<Float> {
        self.position
    }
}


@MainActor
@Observable
class HandClass {
    let session = ARKitSession()
    let handTracking = HandTrackingProvider()
    let RootEntity = Entity()
    var LeftHandAnchorEntity: ModelEntity?
    var LeftFingerTipsEntity: [HandSkeleton.JointName: ModelEntity] = [:]
    var RightHandAnchorEntity: ModelEntity?
    var RightFingerTipsEntity: [HandSkeleton.JointName: ModelEntity] = [:]
    
    func setupEntity(with viewModel: HandViewModel) {
        let mode = viewModel.inputMode ?? 0
        
        var leftTexts: [String] = ["", "", "", ""]
        var rightTexts: [String] = ["", "", "", ""]
        
        switch mode {
        case 1:
            rightTexts = ["C", "B", "A", ""]
        case 2:
            rightTexts = ["F", "E", "D", ""]
        case 3:
            rightTexts = ["I", "H", "G", ""]
        case 4:
            rightTexts = ["L", "K", "J", ""]
        case 5:
            leftTexts = ["W", "X", "Y", "Z"]
        case 6:
            leftTexts = ["T", "U", "V", ""]
        case 7:
            leftTexts = ["P", "Q", "R", "S"]
        case 8:
            leftTexts = ["M", "N", "O", ""]
        default:
            leftTexts = ["ABC", "DEF", "GHI", "JKL"]
            rightTexts = ["WXYZ", "TUV", "PQRS", "MNO"]
        }
        // 创建左手
        for value in LeftFingerTipsEntity.values {
            RootEntity.removeChild(value)
        }
        LeftFingerTipsEntity[.indexFingerTip] = createTextEntity(text: leftTexts[0])
        LeftFingerTipsEntity[.middleFingerTip] = createTextEntity(text: leftTexts[1])
        LeftFingerTipsEntity[.ringFingerTip] = createTextEntity(text: leftTexts[2])
        LeftFingerTipsEntity[.littleFingerTip] = createTextEntity(text: leftTexts[3])
        
        for value in LeftFingerTipsEntity.values {
            RootEntity.addChild(value)
        }
        
        // 创建右手
        for value in RightFingerTipsEntity.values {
            RootEntity.removeChild(value)
        }
        RightFingerTipsEntity[.indexFingerTip] = createTextEntity(text: rightTexts[0])
        RightFingerTipsEntity[.middleFingerTip] = createTextEntity(text: rightTexts[1])
        RightFingerTipsEntity[.ringFingerTip] = createTextEntity(text: rightTexts[2])
        RightFingerTipsEntity[.littleFingerTip] = createTextEntity(text: rightTexts[3])
        
        for value in RightFingerTipsEntity.values {
            RootEntity.addChild(value)
        }
    }
    
    func checkHandTracking() -> Bool {
        return HandTrackingProvider.isSupported
        && handTracking.state == .initialized
        
    }
    
    func createTextEntity(
        text: String,
        fontSize: Float = 0.008,
        color: UIColor = .white,
        position: SIMD3<Float> = [0, 1.5, 1]
    ) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: CGFloat(fontSize)),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
            
        )
        
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.setPosition(position, relativeTo: nil)
        entity.components[BillboardComponent.self] = BillboardComponent()
        
        return entity
    }
    
    func continuousHandUpdate(using viewModel: HandViewModel) async {
        var _: [HandAnchor.Chirality: Float] = [.left: 0.0, .right: 0.0]
        let releaseThreshold: Float = 0.017 // 分离距离阈值
        let letters: [[String]] = [["C", "B", "A", ""],
                                   ["F", "E", "D", ""],
                                   ["I", "H", "G", ""],
                                   ["L", "K", "J", ""],
                                   ["W", "X", "Y", "Z"],
                                   ["T", "U", "V", ""],
                                   ["P", "Q", "R", "S"],
                                   ["M", "N", "O", ""]
                                    ]
        for await update in handTracking.anchorUpdates {
            
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked else { continue }
            
            let handAnchorTransform = handAnchor.originFromAnchorTransform
            
            guard
                let thumbTipJointTransform = handAnchor.handSkeleton?.joint(
                    .thumbTip
                ).anchorFromJointTransform,
                let indexFingerTipJointTransform = handAnchor.handSkeleton?
                    .joint(
                        .indexFingerTip
                    ).anchorFromJointTransform,
                let middleFingerTipJointTransform = handAnchor.handSkeleton?
                    .joint(
                        .middleFingerTip
                    ).anchorFromJointTransform,
                let ringFingerTipJointTransform = handAnchor.handSkeleton?
                    .joint(
                        .ringFingerTip
                    ).anchorFromJointTransform,
                let littleFingerTipJointTransform = handAnchor.handSkeleton?
                    .joint(
                        .littleFingerTip
                    ).anchorFromJointTransform
            else { continue }
            
            let thumbTipWorldTransform =
            handAnchorTransform * thumbTipJointTransform
            let indexFingerTipWorldTransform =
            handAnchorTransform * indexFingerTipJointTransform
            let middleFingerTipWorldTransform =
            handAnchorTransform * middleFingerTipJointTransform
            let ringFingerTipWorldTransform =
            handAnchorTransform * ringFingerTipJointTransform
            let littleFingerTipWorldTransform =
            handAnchorTransform * littleFingerTipJointTransform
            
            
            let fingerTipsDict: [HandSkeleton.JointName: simd_float4x4] = [
                .indexFingerTip: indexFingerTipWorldTransform,
                .middleFingerTip: middleFingerTipWorldTransform,
                .ringFingerTip: ringFingerTipWorldTransform,
                .littleFingerTip: littleFingerTipWorldTransform
            ]
            if let gestureID = detectTriplePinch(
                handChirality: handAnchor.chirality, thumb: thumbTipWorldTransform,
                tips: fingerTipsDict
            ) {
                viewModel.gestureMode = gestureID
                viewModel.inputMode = nil
                setupEntity(with: viewModel)
//                if gestureID == 2{
//                    if viewModel.totalText.isEmpty != true{
//                        viewModel.totalText.removeLast()
//                    }
//                }else{
//                    viewModel.currentLetter = " "
//                    viewModel.totalText += viewModel.currentLetter
//                }
                print("\(gestureID)")
            }else{
                if let gestureID = detectFingerTouchResult(
                    handChirality: handAnchor.chirality, thumb: thumbTipWorldTransform,
                    tips: fingerTipsDict
                ) {
                    if viewModel.inputMode == nil {
                        print("🟢 记录手势模式为：\(gestureID)")
                        viewModel.inputMode = gestureID
                        setupEntity(with: viewModel)
                        viewModel.fastMode = true
                    }else{
                        if let currentMode = viewModel.inputMode {
                            let isLeftMode = (1...4).contains(currentMode)
                            let isRightMode = (5...8).contains(currentMode)
                            // 检查是否是“另一只手”
                            if (isLeftMode && handAnchor.chirality == .right) {
                                viewModel.currentLetter = letters[currentMode-1][gestureID - 5]
                                viewModel.fastMode = false
                            }
                            if (isRightMode && handAnchor.chirality == .left){
                                viewModel.currentLetter = letters[currentMode-1][gestureID-1]
                                viewModel.fastMode = false
                            }
                        }
                    }
                }else if let currentMode = viewModel.inputMode {
                    let thumbPos = thumbTipWorldTransform.translation
                    let releaseDistances = fingerTipsDict.mapValues { fingerTransform in
                        simd_distance(thumbPos, fingerTransform.translation)
                    }
                    let isLeftMode = (1...4).contains(currentMode)
                    let isRightMode = (5...8).contains(currentMode)
        

                    if isRightMode && handAnchor.chirality == .right {
                        if releaseDistances.values.allSatisfy({ $0 > releaseThreshold }) {
                            if viewModel.fastMode && viewModel.gestureMode == 0{
                                viewModel.currentLetter = letters[currentMode-1][0]
                            }else{
                                if viewModel.gestureMode == 2{
                                    if viewModel.totalText.isEmpty != true{
                                        viewModel.totalText.removeLast()
                                    }
                                }else{
                                    viewModel.currentLetter = " "
                                    viewModel.totalText += viewModel.currentLetter
                                }
                            }
                            viewModel.gestureMode = 0
                            viewModel.totalText += viewModel.currentLetter
                            viewModel.inputMode = nil
                            viewModel.currentLetter = ""
                            setupEntity(with: viewModel)
                        }
                    }
                    if isLeftMode && handAnchor.chirality == .left {
                        if releaseDistances.values.allSatisfy({ $0 > releaseThreshold }) {
                            if viewModel.fastMode && viewModel.gestureMode == 0{
                                viewModel.currentLetter = letters[currentMode-1][2]
                            }else{
                                if viewModel.gestureMode == 2{
                                    if viewModel.totalText.isEmpty != true{
                                        viewModel.totalText.removeLast()
                                    }
                                }else{
                                    viewModel.currentLetter = " "
                                    viewModel.totalText += viewModel.currentLetter
                                }
                            }
                            viewModel.gestureMode = 0
                            viewModel.totalText += viewModel.currentLetter
                            viewModel.inputMode = nil
                            viewModel.currentLetter = ""
                            setupEntity(with: viewModel)
                        }
                    }
                    if (isLeftMode && handAnchor.chirality == .right) ||
                       (isRightMode && handAnchor.chirality == .left) {
                        if releaseDistances.values.allSatisfy({ $0 > releaseThreshold }) {
                            viewModel.totalText += viewModel.currentLetter
                            viewModel.currentLetter = ""
                        }
                    }
                }
            }
            if handAnchor.chirality == .left {
                
                //                LeftHandAnchorEntity?.setTransformMatrix(
                //                    handAnchorTransform, relativeTo: nil)
                LeftFingerTipsEntity[.indexFingerTip]?
                    .setTransformMatrix(
                        indexFingerTipWorldTransform, relativeTo: nil)
                LeftFingerTipsEntity[.middleFingerTip]?
                    .setTransformMatrix(
                        middleFingerTipWorldTransform, relativeTo: nil)
                LeftFingerTipsEntity[.ringFingerTip]?
                    .setTransformMatrix(
                        ringFingerTipWorldTransform,
                        relativeTo: nil)
                LeftFingerTipsEntity[.littleFingerTip]?
                    .setTransformMatrix(
                        littleFingerTipWorldTransform,
                        relativeTo: nil
                    )
            } else {
                //                RightHandAnchorEntity?.setTransformMatrix(
                //                    handAnchorTransform, relativeTo: nil)
                RightFingerTipsEntity[.indexFingerTip]?
                    .setTransformMatrix(
                        indexFingerTipWorldTransform, relativeTo: nil)
                RightFingerTipsEntity[.middleFingerTip]?
                    .setTransformMatrix(
                        middleFingerTipWorldTransform, relativeTo: nil)
                RightFingerTipsEntity[.ringFingerTip]?
                    .setTransformMatrix(
                        ringFingerTipWorldTransform,
                        relativeTo: nil)
                RightFingerTipsEntity[.littleFingerTip]?
                    .setTransformMatrix(
                        littleFingerTipWorldTransform,
                        relativeTo: nil
                    )
            }
        }
        
        func detectFingerTouchResult(
            handChirality: HandAnchor.Chirality,
            thumb: simd_float4x4,
            tips: [HandSkeleton.JointName: simd_float4x4]
        ) -> Int? {
            let threshold: Float = 0.017 // 合拢判断距离（单位：米）
            
            let fingerOrder: [HandSkeleton.JointName] = [
                .indexFingerTip, .middleFingerTip, .ringFingerTip, .littleFingerTip
            ]
            
            for (index, finger) in fingerOrder.enumerated() {
                guard let fingerTransform = tips[finger] else { continue }
                
                let thumbPosition = thumb.translation
                let fingerPosition = fingerTransform.translation
                
                let distance = simd_distance(thumbPosition, fingerPosition)
                
                if distance < threshold {
                    // 输出值 1~4（左手）或 5~8（右手）
                    return handChirality == .left ? (index + 1) : (index + 5)
                }
            }
            return nil
        }
        func detectTriplePinch(
            handChirality: HandAnchor.Chirality,
            thumb: simd_float4x4,
            tips: [HandSkeleton.JointName: simd_float4x4]
        ) -> Int? {
            let threshold: Float = 0.017 // 合拢距离阈值（米）

            let fingerOrder: [HandSkeleton.JointName] = [
                .indexFingerTip, .middleFingerTip, .ringFingerTip, .littleFingerTip
            ]
            
            var closeFingers: [Int] = []

            for (index, finger) in fingerOrder.enumerated() {
                guard let fingerTransform = tips[finger] else { continue }
                
                let thumbPosition = thumb.translation
                let fingerPosition = fingerTransform.translation
                let distance = simd_distance(thumbPosition, fingerPosition)
                
                if distance < threshold {
                    closeFingers.append(index)
                }
            }

            if closeFingers.count >= 2 {
                // 只返回左右手标识：左手 1，右手 2
                return handChirality == .left ? 1 : 2
            }

            return nil
        }

    }
}
