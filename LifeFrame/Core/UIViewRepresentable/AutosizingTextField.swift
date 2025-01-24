//
//  AutosizingTextField.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import SwiftUI
import UIKit
struct AutosizingTextField: UIViewRepresentable {
    let chapterService = ChapterDataService.shared

    @Binding var text: String
    @Binding var containerHeight: CGFloat
    @Binding var isFirstResponder: Bool
    
    let hint : String = UI.Strings.dear_diary
    let drafts : String = UI.Strings.draft
    
    var send : ()->()
    var media : ()->()
    var cancel : ()->()

    let view = UITextView()
    let sendButton = UIButton(type: .custom)
    let cancelButton = UIButton(type: .custom)
    let addMediaButton = UIButton(type: .custom)
    let tagButton = UIButton(type: .custom)


    func makeUIView(context: Context) -> UITextView {
        
        // - TextView -
    
        view.text = hint
        view.textColor = UIColor.theme.c3
        view.backgroundColor = .clear
        view.font = .newYorkFont()
        view.tintColor = UIColor.theme.c2
        view.delegate = context.coordinator
        view.adjustsFontForContentSizeCategory = false
        
//        view.isEditable = true
        view.isUserInteractionEnabled = true
//        view.isScrollEnabled = true
        
        // - ToolBar -
        
        let customInputView = CustomView()
        customInputView.backgroundColor = UIColor.theme.cW
        customInputView.autoresizingMask = .flexibleHeight
        
        // - Media Button -
    
        addMediaButton.isEnabled = true
        addMediaButton.setImage(UIImage(named: UI.Icons.attachments), for: .normal)
        addMediaButton.tintColor = UIColor.theme.c1
        addMediaButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        addMediaButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleMedia), for: .touchUpInside)
        
        // - Tag Button -
        
        tagButton.isEnabled = true
        tagButton.setImage(UIImage(named: UI.Icons.tag), for: .normal)
        tagButton.tintColor = UIColor.theme.c1
        tagButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20), forImageIn: .normal)
        tagButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleTag), for: .touchUpInside)

        // - Clear Button -

        cancelButton.isEnabled = true
        
        cancelButton.setTitle(UI.Strings.cancel, for: .normal)
        cancelButton.setTitleColor(UIColor.theme.c1, for: .normal)
        cancelButton.backgroundColor = UIColor.theme.c8
        cancelButton.titleLabel?.font = .title()
        cancelButton.layer.cornerRadius = 8
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        cancelButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleCancel), for: .touchUpInside)

        // - Send Button -
        
        sendButton.isHighlighted = false
        sendButton.setImage(UIImage(named: text.isEmpty ? (chapterService.isEditingMode ? UI.Buttons.submit_inactive : UI.Buttons.send_inactive) : (chapterService.isEditingMode ? UI.Buttons.submit_active : UI.Buttons.send_active)), for: .normal)
        sendButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32), forImageIn: .normal)
        sendButton.addTarget(context.coordinator, action: #selector(context.coordinator.handleSend), for: .touchUpInside)
        
        customInputView.addSubviews(sendButton, addMediaButton, cancelButton, tagButton)

        // MARK: - Layout Setting
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addMediaButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        tagButton.translatesAutoresizingMaskIntoConstraints = false

        // - Send Button -
        
        sendButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 6).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor, constant: -6).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: customInputView.trailingAnchor, constant: -10).isActive = true
        
        // - Add Media Button -
        
        addMediaButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 11).isActive = true
        addMediaButton.leadingAnchor.constraint(equalTo: customInputView.leadingAnchor, constant: 16).isActive = true
        addMediaButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor, constant: -11).isActive = true
        
        // - Tag Button -
        
        tagButton.topAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.topAnchor, constant: 11).isActive = true
        tagButton.leadingAnchor.constraint(equalTo: addMediaButton.trailingAnchor, constant: 16).isActive = true
        tagButton.bottomAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.bottomAnchor,constant: -11).isActive = true
        
        // - Clear Button -
        
        cancelButton.centerXAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.centerXAnchor).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: customInputView.layoutMarginsGuide.centerYAnchor).isActive = true

        view.inputAccessoryView = customInputView
        
        return view
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        DispatchQueue.main.async {
            containerHeight = textView.sizeThatFits(UI.screen_size).height

            // Cancel_Button
            if !chapterService.isEditingMode {
                context.coordinator.parent.cancelButton.isHidden = true
            } else {
                context.coordinator.parent.cancelButton.isHidden = false
            }
            
            context.coordinator.parent.sendButton.setImage(
                UIImage(named: context.coordinator.parent.text.isEmpty ? (chapterService.isEditingMode ? UI.Buttons.submit_inactive : UI.Buttons.send_inactive) : (chapterService.isEditingMode ? UI.Buttons.submit_active : UI.Buttons.send_active))
                , for: .normal
            )
            
            if context.coordinator.parent.sendButton.isSelected {
                textView.text = ""
                containerHeight = 0
                context.coordinator.parent.sendButton.isSelected = false
            }
            
            if context.coordinator.parent.cancelButton.isSelected {
                textView.text = ""
                containerHeight = 0
                context.coordinator.parent.cancelButton.isSelected = false
            }
            
            // Tag_Button
            if context.coordinator.parent.tagButton.isSelected {
                textView.text += "#"
                context.coordinator.parent.tagButton.isSelected = false
            }
            
            if isFirstResponder {
                textView.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return AutosizingTextField.Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent : AutosizingTextField
        
        init(parent : AutosizingTextField) {
            self.parent = parent
        }
        
        @objc func handleTag() {
            parent.text += "#"
            parent.tagButton.isSelected = true
        }
        
        @objc func handleMedia() {
            parent.media()
            parent.addMediaButton.isSelected = true
        }
        
        @objc func handleCancel() {
            parent.cancel()
            parent.cancelButton.isSelected = true
        }
        
        @objc func handleSend() {
            if parent.text.isEmpty {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            } else {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                UIView.transition(with: parent.sendButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
                    self.parent.sendButton.setImage(UIImage(named: UI.Buttons.send_inactive), for: .normal)
                }, completion: nil)
                
                parent.sendButton.isSelected = true
                parent.send()
                parent.text = ""
                
//                if parent.chapterService.isEditingMode {
//                    parent.isFirstResponder = false
//                }
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.textColor = UIColor.theme.cB
            
            if textView.text == parent.hint {
                textView.text = parent.text
            } else if textView.text == parent.drafts {
                withAnimation {
                    textView.text = parent.text
                }
            }
            
            parent.containerHeight = textView.contentSize.height
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let newPosition = textView.position(from: textView.endOfDocument, offset: 0) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                    self.parent.view.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.containerHeight = textView.contentSize.height
            
//            let resolvedText = textView.text.resolveHashtags(color: UIColor(Color.theme.c6))
//            textView.attributedText = resolvedText
        }
        
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.containerHeight = 0
            
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: textView.text.count) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            
            if textView.text == "" {
                textView.textColor = UIColor.theme.c3
                textView.text = parent.hint
            } else {
                textView.textColor = UIColor.theme.cW
                parent.text = textView.text
                textView.text = parent.drafts
            }
            
            withAnimation {
                parent.isFirstResponder = false
            }
        }
    }
}

class CustomView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
