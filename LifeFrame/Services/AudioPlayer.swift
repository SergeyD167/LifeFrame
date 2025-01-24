//
//  AudioPlayerVM.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//


import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentlyPlaying: MediaMO?
    @Published var isPlaying: Bool = false
    
    var audioPlayer: AVAudioPlayer?
    
    func startPlayback(recording: MediaMO) {
        stopPlayback()
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.spokenAudio)
            try playbackSession.setActive(true)
            print("Start Recording - Playback session setted")
        } catch {
            print("Play Recording - Failed to set up playback session")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.safeAudioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            self.currentlyPlaying = recording
            
            print("Play Recording - Playing")
        
        } catch {
            print("Play Recording - Playback failed: - \(error.localizedDescription)")
            self.currentlyPlaying = nil
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        print("Play Recording - Paused")
    }
    
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
        print("Play Recording - Resumed")
    }
    
    func stopPlayback() {
        if audioPlayer != nil {
            audioPlayer?.stop()
            isPlaying = false
            print("Play Recording - Stopped")
            self.currentlyPlaying = nil
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
            print("Play Recording - Recoring finished playing")
            DispatchQueue.main.async {
                self.currentlyPlaying = nil
            }
        }
    }
}

