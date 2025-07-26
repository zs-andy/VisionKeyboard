//
//  HandViewModel.swift
//  esudrjytfkjh
//
//  Created by xunter hu on 2025/7/25.
//
import Observation

@Observable
class HandViewModel {
    var inputMode: Int? = nil 
    var currentLetter: String = ""
    var totalText: String = ""
    var fastMode: Bool = true
    var gestureMode: Int = 0
}
