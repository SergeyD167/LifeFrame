//
//  View+Extensions.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

// MARK: - UIView Extensions -

extension UIView {
    func addSubviews(_ subviews: UIView...) { subviews.forEach { addSubview($0) } }
}

// MARK: - View Extensions -

extension View {

    // MARK: Texts Modifiers
    
    public func memoryTextBaseStyle(editingMode: Bool) -> some View {
        self.modifier(MemoryTextBase(editingMode: editingMode))
    }
    
    public func memoryTextImageStyle(editingMode: Bool) -> some View {
        self.modifier(MemoryTextImage(editingMode: editingMode))
    }
    
    public func memoryTimeStyle() -> some View {
        self.modifier(MemoryTime())
    }
    
    public func memoryAudioTimeStyle() -> some View {
        self.modifier(MemoryTime())
    }
    
    public func memoryRecordingDurationStyle() -> some View {
        self.modifier(MemoryRecordingDuration())
    }
    
    public func chapterYearStyle() -> some View {
        self.modifier(ChapterYear())
    }
    
    public func chapterDateStyle() -> some View {
        self.modifier(ChapterDate())
    }
    
    public func statsTitleStyle() -> some View {
        self.modifier(StatsTitle())
    }
    
    public func statsSubTitleStyle() -> some View {
        self.modifier(StatsSubtitle())
    }
    
    public func chartEmptyTextStyle() -> some View {
        self.modifier(ChartEmptyText())
    }
    
    public func wordTagStyle(color: Color) -> some View {
        self.modifier(WordTag(color: color))
    }
    
    
    // MARK: Shadows Modifiers
    
    public func shadowMemoryStatic() -> some View {
        self.modifier(ShadowMemoryStatic())
    }
    
    public func shadowInputControl() -> some View {
        self.modifier(ShadowInputControl())
    }
    
    public func shadowFloating() -> some View {
        self.modifier(ShadowFloating())
    }
    
    
    // MARK: PopUp Modifiers
    
    public func statsPopUpTitleStyle() -> some View {
        self.modifier(StatsPopUpTitle())
    }
    
    public func statsPopUpTextStyle() -> some View {
        self.modifier(StatsPopUpText())
    }
}

extension View {

    // MARK: Toolbar Modifier
    
    func keyboardToolbar<ToolbarView>(isPresented: Binding<Bool>, view: @escaping () -> ToolbarView) -> some View where ToolbarView: View {
        modifier(KeyboardToolbar(isPresented: isPresented, toolbar: view))
    }
    
    // MARK: SearchBar Modifiers
    
    func searchable(text: Binding<String>, isPresented: Binding<Bool>, inSearchMode: Binding<Bool>, closeAddView: @escaping () -> ()) -> some View {
        self.modifier(SearchBar(text: text, isPresented: isPresented, inSearchMode: inSearchMode, closeAddView: closeAddView))
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension View {
    func offsetModifier(_ offset: Binding<CGFloat>) -> some View {
        self.modifier(OffsetModifier(offset: offset))
    }
    
    func paddings(vertical: CGFloat = 8, horizontal: CGFloat = 16) -> some View {
        self.modifier(PaddingModifier(verticalPadding: vertical, horizontalPadding: horizontal))
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

extension UIView {

    // MARK: Animations Modifiers

    func zoomIn(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
        }
    }

    func zoomOut(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
        }
    }
}


//extension View {
//    func scrollToBottomOnChanges(_ binding: Binding<Bool>, isEditingMode: Bool, proxy: ScrollViewProxy, bottomID: Namespace.ID, delay: Double = 0.2) -> some View {
//        self.onChange(of: binding.wrappedValue) { newValue in
//            if !isEditingMode {
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    withAnimation(.linear(duration: 0.1)) {
//                        proxy.scrollTo(bottomID, anchor: .bottom)
//                    }
//                }
//            }
//        }
//    }
//}


extension View {
    
}
