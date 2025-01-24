//
//  SwipeItemView.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

struct SwipeItem<Content: View, Right: View>: View {

    var content: () -> Content
    var right: () -> Right
    var itemHeight: CGFloat = 0
    
    var anchorWidth: CGFloat { UI.screen_width / 4.2 }
    var swipeThreshold: CGFloat { UI.screen_width / 15 }
    
    @Binding var endSwipeAction: Bool
    @Binding var isKeyboardPresented: Bool

    @State var hoffset: CGFloat = 0
    @State var anchor: CGFloat = 0
    @State var rightPast = false

    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder right: @escaping () -> Right,
         itemHeight: CGFloat,
         endSwipeAction: Binding<Bool>,
         isKeyboardPresented: Binding<Bool>) {
        self.content = content
        self.right = right
        self.itemHeight = itemHeight
        self._endSwipeAction = endSwipeAction
        self._isKeyboardPresented = isKeyboardPresented
    }

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    let translation = value.translation.width
                    
                    if translation < 0 {
                        if abs(translation) > UI.screen_width / 10 {
                            hoffset = anchor + translation
                        }
                    } else {
                        hoffset = anchor + translation
                    }
                    
                    if hoffset > 0 {
                        hoffset = 0
                    }
                    
                    if abs(hoffset) > anchorWidth {
                       if rightPast {
                            hoffset = -anchorWidth
                        }
                    }

                    if anchor < 0 {
                        rightPast = hoffset < -anchorWidth + swipeThreshold
                    } else {
                        rightPast = hoffset < -swipeThreshold
                    }
                }
            }
            .onEnded { value in
                withAnimation {
                    if rightPast {
                        anchor = -anchorWidth
                    } else {
                        anchor = 0
                    }
                    hoffset = anchor
                }
            }
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                content()
                    .frame(width: geo.size.width)
                    .zIndex(0)

                right()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .background(Color.theme.cW)
                    .clipped()
            }
        }
        .offset(x: hoffset)
        .frame(height: itemHeight)
        .contentShape(Rectangle())
        .gesture(drag)
        .clipped()
        .onChange(of: endSwipeAction) { newValue in
            withAnimation {
                anchor = 0
                hoffset = anchor
            }
        }
        .disabled(endSwipeAction)
        .disabled(isKeyboardPresented)
    }
}

