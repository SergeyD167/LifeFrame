//
//  Font+Extensions.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

// MARK: - UIFont Extensions -

extension UIFont {
    static func newYorkFont(_ size: CGFloat = 18) -> UIFont {
        let descriptor = UIFont.systemFont(ofSize: size, weight: .regular).fontDescriptor

        if let serif = descriptor.withDesign(.serif) {
            return UIFont(descriptor: serif, size: 0.0)
        }

        return UIFont(descriptor: descriptor, size: 0.0)
    }
    
    static func title(_ size: CGFloat = 17) -> UIFont {
        let descriptor = UIFont.systemFont(ofSize: size, weight: .semibold).fontDescriptor
        return UIFont(descriptor: descriptor, size: 0.0)
    }
}

// MARK: - Font Extensions -

extension Font {
    static func subscription(_ size: CGFloat = 12.5) -> Font {
        .system(size: size, weight: .regular, design: .none)
    }
    
    static func bodyText(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .none)
    }
    
    static func title(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .none)
    }
    
    static func memoryTextBase(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    
    static func memoryTextImage(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .regular, design: .serif)
        .italic()
    }
    
    static func headline(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
}
