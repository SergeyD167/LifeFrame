//
//  AudioRecorderVM.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import SwiftUI
import AVFoundation

class AudioRecorder: ObservableObject {
    @Published var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    @Published var audioURL: URL?
    @Published var audioID: String = ""
    
    var itemModel: ItemDataService

    init(itemModel: ItemDataService) {
        self.itemModel = itemModel
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            audioID = UUID().uuidString
            
            let audioFileName = audioID + ".m4a"
            let audioFileURL = documentPath.appendingPathComponent(audioFileName)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 96000,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100.0
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
            audioURL = audioFileURL
        } catch {
            print("Ошибка при начале записи: \(error.localizedDescription)")
        }
    }
    
    func stopRecording(chapter: ChapterMO) {
        audioRecorder?.stop()
        withAnimation {
            isRecording = false
        }
        
        if let audioURL {
            do {
                let recordingData = try Data(contentsOf: audioURL)
                print("Stop Recording - Saving to CoreData")
                // save the recording to CoreData
                saveRecordingToCoreData(chapter: chapter, id: audioID, recordingURL: audioURL.absoluteString, recordingData: recordingData)
            } catch {
                print("Stop Recording - Could not save to CoreData - Cannot get the recording data from URL: \(error)")
            }
            
        } else {
            print("Stop Recording -  Could not save to CoreData - Cannot find the recording URL")
        }
    }
    
    // MARK: - CoreData
    
    func saveRecordingToCoreData(chapter: ChapterMO, id: String, recordingURL: String, recordingData: Data) {
        itemModel.addItemMedia(chapter: chapter, id: id, attachment: recordingURL, type: ItemType.audio)
    }
    
    func deleteRecordingFile() {
        if let audioURL {
            do {
               try FileManager.default.removeItem(at: audioURL)
                print("Stop Recording - Successfully deleted the recording file")
            } catch {
                print("Stop Recording - Could not delete the recording file - Cannot find the recording URL")
            }
        }
    }
}
