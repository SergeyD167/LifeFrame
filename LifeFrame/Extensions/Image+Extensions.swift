//
//  Image+Extensions.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

extension Image {
    
    // MARK: Images Properties
    
    func memoryImageStyle(w: CGFloat, h: CGFloat, corners: UIRectCorner, hide: Bool) -> some View {
        self
            .interpolation(.low)
            .resizable()
            .scaledToFill()
            .frame(width: w, height: h)
            .overlay(
                ZStack {
                    BlurView(style: .dark, intensity: hide ? 0.5 : 0)
                    Image(UI.Icons.incognito)
                        .foregroundColor(Color.theme.cW)
                        .opacity(hide ? 1 : 0)
                }
            )
            .clipped()
            .cornerRadius(8, corners: corners)
            .fixedSize(horizontal: true, vertical: true)
    }

    func imageInTFStyle(w: CGFloat, h: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: w, height: h)
            .clipped()
            .cornerRadius(2)
    }
    
    func imageInPopUpStyle(w: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: w)
            .clipped()
            .fixedSize(horizontal: true, vertical: true)
    }
}
