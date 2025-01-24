//
//  CollageLayoutView.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

struct CollageLayoutView: View {
    @EnvironmentObject var quickActionSettings: QuickActionVM

    var images: [MediaMO] = []
    var width: CGFloat = 0
    
    var body: some View {
        switch images.count {
        case 1:
            if isPortrait(forOne: true) {
                HStack {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 3 - 2,
                              h: width / 3 * 1.5,
                              corners: [.allCorners],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    Spacer()
                }
            } else {
                HStack {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 1.5,
                              h: width / 1.5 / 1.5,
                              corners: [.allCorners],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    Spacer()
                }
            }
        case 2:
            if isPortrait(forOne: false) {
                HStack(spacing: 4) {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 3 - 2,
                              h: width / 3 * 1.5,
                              corners: [.topLeft, .bottomLeft],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    
                    if images.count > 1 {
                        LazyImage(url: images[1].safeImageURL,
                                  w: width / 3 - 2,
                                  h: width / 3 * 1.5,
                                  corners: [.topRight, .bottomRight],
                                  hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }
            } else {
                VStack(spacing: 4) {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 1.5,
                              h: width / 1.5 / 1.5,
                              corners: [.topLeft, .topRight],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    
                   
                    if images.count > 1 {
                        LazyImage(url: images[1].safeImageURL,
                                  w: width / 1.5,
                                  h: width / 1.5 / 1.5,
                                  corners: [.bottomLeft, .bottomRight],
                                  hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }
            }
        case 3:
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    LazyImage(url: images[0].safeImageURL,
                              w: width / 3 - 2,
                              h: width / 3 * 1.5,
                              corners: [.topLeft],
                              hide: quickActionSettings.isPrivateModeEnabled)
                    
                    if images.count > 1 {
                        LazyImage(url: images[1].safeImageURL,
                                  w: width / 3 - 2,
                                  h: width / 3 * 1.5,
                                  corners: [.topRight],
                                  hide: quickActionSettings.isPrivateModeEnabled)
                    }
                }.frame(width: width / 1.5)
                
                if images.count > 2 {
                    LazyImage(url: images[2].safeImageURL,
                              w: width / 1.5,
                              h: width / 1.5 / 1.5,
                              corners: [.bottomLeft, .bottomRight],
                              hide: quickActionSettings.isPrivateModeEnabled)
                }
            }.frame(width: width / 1.5)
        default:
            EmptyView()
        }
    }

    private func isPortrait(forOne: Bool) -> Bool {
        if forOne {
            guard let uiimage = images.first?.uiImage as? UIImage else { return false }
            return uiimage.size.height > uiimage.size.width
        }
        
        let portraitCount = images.filter { $0.uiImage.size.height > $0.uiImage.size.width }.count
        return portraitCount > (images.count - portraitCount)
    }
}

struct LazyImage: View {
    @StateObject private var imageLoader = ImageLoader()
    private let url: URL
    var w: CGFloat
    var h: CGFloat
    var corners: UIRectCorner
    var hide: Bool
    
    init(url: URL, w: CGFloat, h: CGFloat, corners: UIRectCorner, hide: Bool) {
        self.url = url
        self.w = w
        self.h = h
        self.corners = corners
        self.hide = hide
    }
    
    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .interpolation(.low)
                .resizable()
                .scaledToFill()
                .frame(width: w, height: h)
                .overlay(
                    hideView
                )
                .clipped()
                .cornerRadius(8, corners: corners)
                .fixedSize(horizontal: true, vertical: true)
        } else {
            Color.theme.c7
                .frame(width: w, height: h)
                .onAppear {
                    imageLoader.loadImage(from: url)
                }
        }
    }
    
    var hideView: some View {
        ZStack {
            if hide {
                BlurView(style: .dark, intensity: 0.5)
            }

            Image(UI.Icons.incognito)
                .foregroundColor(Color.theme.cW)
                .opacity(hide ? 1 : 0)
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }.resume()
    }
}
