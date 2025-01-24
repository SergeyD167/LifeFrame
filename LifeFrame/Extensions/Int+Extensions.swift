//
//  Int+Extensions.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation

extension Int {
    var stringFormat: String {
        if self >= 1000000 {
            return String(format: "%dM", self / 1000000)
        }
        
        if self >= 1000 {
            return String(format: "%dK", self / 1000)
        }
        
        return String(format: "%d", self)
    }
}
