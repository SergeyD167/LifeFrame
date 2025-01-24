//
//  BlurView.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    let intensity: CGFloat
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return CustomIntensityVisualEffectView(effect: UIBlurEffect(style: style), intensity: intensity)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        if let customIntensityVisualEffectView = uiView as? CustomIntensityVisualEffectView {
            customIntensityVisualEffectView.setIntensity(intensity)
        }
    }
}

final class CustomIntensityVisualEffectView: UIVisualEffectView {
    init(effect: UIVisualEffect, intensity: CGFloat) {
        theEffect = effect
        customIntensity = intensity
        super.init(effect: nil)
    }

    required init?(coder aDecoder: NSCoder) { nil }

    deinit {
        animator?.stopAnimation(true)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.fractionComplete = customIntensity
    }
    
    func setIntensity(_ intensity: CGFloat) {
        animator?.stopAnimation(true)
        effect = nil
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.fractionComplete = intensity
    }

    private let theEffect: UIVisualEffect
    private let customIntensity: CGFloat
    private var animator: UIViewPropertyAnimator?
}
