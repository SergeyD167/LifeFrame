//
//  BottomPopUpVM.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

class BottomPopUpVM: ObservableObject {
    @Published var isVisible = false
    
    func enablePopUp() {
        withAnimation {
            isVisible = true
        }
    }

    func disablePopUp() {
        withAnimation {
            isVisible = false
        }
    }
}
