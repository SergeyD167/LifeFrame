//
//  ImagesPicker.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI
import PhotosUI

struct ImagesPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selections: [UIImage]
    @Binding var selectionsVideo: [URL]
    var addFunc: ()->()
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.selection = .ordered
        configuration.selectionLimit = 3
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        let parent: ImagesPicker

        init(_ parent: ImagesPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for result in results {

                let identifier = UTType.image.identifier
                if result.itemProvider.hasItemConformingToTypeIdentifier(identifier) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        guard let image = image as? UIImage else { return }
                        DispatchQueue.main.async {
                            withAnimation {
                                self.parent.selections.append(image)
                            }
                            if self.parent.selections.count == results.count {
                                self.parent.addFunc()
                            }
                        }
                    }
                } else if result.itemProvider.hasItemConformingToTypeIdentifier("public.movie") {
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                        guard let url = url else { return }
                        DispatchQueue.main.async {
                            self.parent.selectionsVideo.append(url)
                        }
                    }
                }
            }
            self.parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

