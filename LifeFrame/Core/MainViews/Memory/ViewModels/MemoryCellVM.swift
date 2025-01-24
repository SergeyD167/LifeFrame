//
//  MemoryCellVM.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import AVFoundation
import UIKit
import SwiftUI

class MemoryCellVM: ObservableObject {
    @Published var sentimentColor: Color = .theme.c4
    
    private let memory: ItemMO
    
    init(memory: ItemMO) {
        self.memory = memory
        self.updateSentimentColor()
    }
    
    func updateSentimentColor() {
        switch memory.safeSentiment {
        case "positive":
            sentimentColor = Color.theme.c3
        case "negative":
            sentimentColor = Color.theme.c5
        default:
            sentimentColor = Color.theme.c4
        }
    }
    
    func getDuration(of recording: MediaMO) -> TimeInterval? {
        do {
            return try AVAudioPlayer(contentsOf: recording.safeAudioURL).duration
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func isPortrait(forOne: Bool) -> Bool {
        if forOne {
            guard let uiimage = memory.mediaArray.first?.uiImage as? UIImage else { return false }
            return uiimage.size.height > uiimage.size.width
        }
        
        let portraitCount = memory.mediaArray.filter { $0.uiImage.size.height > $0.uiImage.size.width }.count
        return portraitCount > (memory.mediaArray.count - portraitCount)
    }
}
