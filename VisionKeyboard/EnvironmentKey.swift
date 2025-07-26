//
//  EnvironmentKey.swift
//  esudrjytfkjh
//
//  Created by xunter hu on 2025/7/24.
//

import SwiftUI

struct GestureResultKey: EnvironmentKey {
    static let defaultValue: Binding<Int?>? = nil
}

extension EnvironmentValues {
    var gestureResult: Binding<Int?>? {
        get { self[GestureResultKey.self] }
        set { self[GestureResultKey.self] = newValue }
    }
}
