//
//  QuickActions.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

class QuickActionVM: ObservableObject {
    @Published var isPrivateModeEnabled = false

    func enablePrivateMode() {
        isPrivateModeEnabled = true
    }

    func disablePrivateMode() {
        isPrivateModeEnabled = false
    }
}

