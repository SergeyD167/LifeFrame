//
//  BottomPopUpView.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

struct BottomPopUpView: View {
    @EnvironmentObject var popUpVM: BottomPopUpVM
    
    @GestureState private var translation: CGFloat = 0
    
    @State private var maxHeight: CGFloat = 0
    
    var type: String
    
    private let width: CGFloat = UI.screen_width - 32
    
    private var offset: CGFloat {
        popUpVM.isVisible ? 0 : maxHeight + (self.maxHeight / 2)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.theme.cW)
                    .overlay (
                        GeometryReader { geo in
                            VStack(spacing: 16) {
                                Image(type == "settings" ? UI.PopUp.stats_image : UI.PopUp.editing_image)
                                        .imageInPopUpStyle(w: geo.size.width - 32)
                                
                                VStack(spacing: 8) {
                                    Text(type == "settings" ? UI.PopUp.stats_title : UI.PopUp.editing_title)
                                        .statsPopUpTitleStyle()
                                    
                                    Text(type == "settings" ? UI.PopUp.stats_text : UI.PopUp.editing_text)
                                        .statsPopUpTextStyle()
                                }.padding(.bottom, 48)
                                
                                Button(action: {
                                    popUpVM.disablePopUp()
                                }, label: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .foregroundColor(Color.theme.c3)
                                        .overlay(
                                            Text(type == "settings" ? UI.PopUp.stats_btn_text : UI.PopUp.editing_btn_text)
                                                .foregroundColor(Color.theme.cW)
                                                .font(.title(17))
                                        )
                                })
                                .frame(height: geo.size.width / 6)
                                
                            }
                            .paddings(vertical: 16, horizontal: 16)
                            .background (
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            maxHeight = proxy.size.height
                                        }
                                }
                            )
                        }
                    )
            }
            .frame(width: width, height: maxHeight)
            .cornerRadius(32)
            .frame(height: geometry.size.height - 32, alignment: .bottom)
            .offset(x: geometry.size.width / 2 - width / 2, y: max(self.offset + self.translation, 0))
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    let snapDistance = self.maxHeight * 0.3
                    
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    
                    withAnimation(.interactiveSpring) {
                        popUpVM.isVisible = value.translation.height < 0
                    }
                }
            )
            .animation(Animation.interpolatingSpring(mass: 1.2, stiffness: 300, damping: 20, initialVelocity: 0), value: popUpVM.isVisible)
        }
        .background {
            if popUpVM.isVisible {
                Color.theme.cB.opacity(0.25)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
//                        withAnimation {
                            popUpVM.disablePopUp()
//                        }
                    }
            }
        }
    }
}

struct ButtonCustomStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            .animation(.linear(duration: 1), value: 1)
    }
}
