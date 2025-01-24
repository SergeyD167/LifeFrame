//
//  MemoryCellView.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI
import AVFoundation

struct MemoryCellView: View {
    @EnvironmentObject var quickActionSettings: QuickActionVM
    @EnvironmentObject var popUp: BottomPopUpVM
    
    @ObservedObject private var vm: MemoryCellVM
    @ObservedObject var audioPlayer: AudioPlayer

    @Binding var isKeyboardPresented: Bool
    
    @State private var sliderValue: Double = 0.0
    @State private var isDragging = false
    @State private var isSwipeable = false
    @State private var deleteSwipeAction = false

    @State var cellHeight: CGFloat = 0
   
    let chapterService = ChapterDataService.shared

    let timer = Timer
        .publish(every: 0.01, on: .main, in: .common)
        .autoconnect()
    
    var memory: ItemMO
    
    var delete: ()->()
    var edit: ()->()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(memory: ItemMO, isKeyboardPresented: Binding<Bool>, audioPlayer: AudioPlayer, delete: @escaping ()->(), edit: @escaping ()->()) {
        self.memory = memory
        self.audioPlayer = audioPlayer
        self.delete = delete
        self.edit = edit
        self.vm = MemoryCellVM(memory: memory)
        self._isKeyboardPresented = isKeyboardPresented
        
        let thumbImage: UIImage = UIImage(named: UI.Icons.drower)!
        UISlider.appearance().minimumTrackTintColor = UIColor(Color.theme.c3)
        UISlider.appearance().maximumTrackTintColor = UIColor(Color.theme.c4)
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }

    var body: some View {
        SwipeItem(content: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 2.3)
                    .foregroundColor(chapterService.getEditingStatus(memory: memory) ? Color.theme.c8 : vm.sentimentColor)
                
                VStack(alignment: .leading, spacing: 8) {
                    switch memory.type {
                    case ItemType.photo.rawValue:
                        CollageLayoutView(images: memory.mediaArray,
                                          width: UI.cell_width)
                    case ItemType.text.rawValue:
                        memory.safeText.resolveHashtags(color: Color.theme.c6)
                            .memoryTextBaseStyle(editingMode: chapterService.getEditingStatus(memory: memory))
                            .blur(radius: quickActionSettings.isPrivateModeEnabled ? 4.5 : 0)
                        
                    case ItemType.audio.rawValue:
                        MemoryVoiceView()
                        
                    case ItemType.textWithPhoto.rawValue:
                        CollageLayoutView(images: memory.mediaArray,
                                          width: UI.cell_width)

                        memory.safeText.resolveHashtags(color: Color.theme.c6)
                            .memoryTextImageStyle(editingMode: chapterService.getEditingStatus(memory: memory))
                            .blur(radius: quickActionSettings.isPrivateModeEnabled ? 4.5 : 0)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.theme.c8)
                            )
                    default:
                        EmptyView()
                    }

                    HStack {
                        Text(memory.safeTimestampContent.dateToString("HH:mm"))
                            .memoryTimeStyle()
                        Spacer()
                        
                        if memory.type == ItemType.audio.rawValue {
                            if (audioPlayer.currentlyPlaying?.id == memory.mediaArray.first?.id) {
                                Text("-\(DateComponentsFormatter.positional.string(from: (audioPlayer.audioPlayer!.duration - audioPlayer.audioPlayer!.currentTime) ) ?? "0:00")")
                                    .memoryAudioTimeStyle()
                            } else {
                                if let recording = memory.mediaArray.first,
                                   let duration = getDuration(of: recording) {
                                    Text(DateComponentsFormatter.positional.string(from: duration) ?? "0:00")
                                        .memoryAudioTimeStyle()
                                }
                            }
                        }
                    }
                }
                .background (
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                let height = proxy.size.height
                                self.cellHeight = height
                            }
                            .onChange(of: memory.safeText) { _ in
                               let height = proxy.size.height
                               self.cellHeight = height
                           }
                    }
                )
            }
        },
        right: {
            HStack {
                Rectangle()
                    .foregroundColor(Color.theme.c8)
                    .frame(width: 2)
                
                Spacer()
                
                if memory.type != ItemType.audio.rawValue && memory.type != ItemType.photo.rawValue && memory.isEditable {
                    GeometryReader { geo in
                        HStack {
                            editBtnView
                                .frame(width: geo.size.width / 2, height: geo.size.height)
                            Spacer()
                            deleteBtnView
                                .frame(width: geo.size.width / 2, height: geo.size.height)
                        }
                    }
                } else {
                    GeometryReader { geo in
                        HStack {
                            if memory.type == ItemType.text.rawValue || memory.type == ItemType.textWithPhoto.rawValue {
                                blockedEditBtnView
                                    .frame(width: geo.size.width / 2, height: geo.size.height)
                                Spacer()
                                deleteBtnView
                                    .frame(width: geo.size.width / 2, height: geo.size.height)
                            } else {
                                deleteBtnView
                                    .frame(width: geo.size.width, height: geo.size.height)
                            }
                        }
                    }
                }
            }
        }, itemHeight: cellHeight, endSwipeAction: $isSwipeable, isKeyboardPresented: $isKeyboardPresented)
    }
    
    func MemoryVoiceView() -> some View {
        var isPlayingThisRecording: Bool {
            audioPlayer.currentlyPlaying?.id == memory.mediaArray.first?.id
        }
        
        var isChangeBtn: Bool {
            isPlayingThisRecording && audioPlayer.isPlaying
        }
        
        return HStack {
            Button {
                if audioPlayer.currentlyPlaying != nil {
                    if isPlayingThisRecording {
                        if audioPlayer.isPlaying {
                            audioPlayer.pausePlayback()
                        } else {
                            audioPlayer.resumePlayback()
                        }
                    } else {
                        audioPlayer.startPlayback(recording: memory.mediaArray.first!)
                    }
                } else {
                    audioPlayer.startPlayback(recording: memory.mediaArray.first!)
                }
            } label: {
                Image(isChangeBtn ? UI.Buttons.pause_audio : UI.Buttons.play_audio)
            }
            
            Slider(value: $sliderValue, in: 0...((audioPlayer.currentlyPlaying != nil && isPlayingThisRecording) ? audioPlayer.audioPlayer!.duration : 0)) { dragging in
                isDragging = dragging
                if !dragging && audioPlayer.currentlyPlaying != nil && isPlayingThisRecording {
                    audioPlayer.audioPlayer!.currentTime = sliderValue
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing, 8)
        }
        .onAppear {
            sliderValue = 0
        }
        .onChange(of: audioPlayer.currentlyPlaying) { newValue in
            sliderValue = 0
        }
        .onReceive(timer) { _ in
            guard let player = audioPlayer.audioPlayer, !isDragging && isPlayingThisRecording else { return }
            sliderValue = player.currentTime
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
   
    private var blockedEditBtnView: some View {
        Button(action: {
            withAnimation {
                isSwipeable = true
                popUp.enablePopUp()
            }
        }, label: {
            Image(UI.Icons.edit_locked)
        }).onChange(of: popUp.isVisible) { newValue in
            isSwipeable = false
        }
    }
    
    private var editBtnView: some View {
        Button(action: {
            withAnimation {
                isSwipeable = true
                self.edit()
            }
        }, label: {
            Image(UI.Icons.edit)
                .foregroundColor(Color.theme.c6)
        }).onChange(of: chapterService.isEditingMode) { newValue in
            isSwipeable = false
        }
    }
    
    private var deleteBtnView: some View {
        Button(action: {
            withAnimation {
                deleteSwipeAction.toggle()
                isSwipeable = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                   self.delete()
                }
            }
        }, label: {
            Image(UI.Icons.trash)
                .foregroundColor(Color.theme.c5)
        })
    }
}

struct MemoryEmptyCellView: View {
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 2)
                .foregroundColor(Color.theme.c8)
            
            VStack {
                Text(UI.Strings.empty_chapter_text)
                    .font(.memoryTextImage(18))
                    .foregroundColor(Color.theme.c7)
            }
            Spacer()
        }
    }
}
