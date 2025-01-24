//
//  FileManager+Extensions.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import UIKit

extension FileManager {
    func retrieveImage(with id: String) -> UIImage? {
        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
        do {
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func retrieveURL(with id: String) -> URL? {
        URL.documentsDirectory.appendingPathComponent("\(id).jpg")
    }
    
    func retrieveURLString(with id: String) -> String? {
        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
        return url.absoluteString
    }
    
    func retrieveAudioURL(with id: String) -> URL? {
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileURL = documentPath.appendingPathComponent("\(id).m4a")
        return audioFileURL
    }
    
    func saveImage(with id: String, image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.4) {
            do {
                let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
                try data.write(to: url)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("Could not save image")
        }
    }
    
    func delete(with url: URL) {
        if fileExists(atPath: url.path) {
            do {
                try removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("Media item does not exist")
        }
    } 
}
