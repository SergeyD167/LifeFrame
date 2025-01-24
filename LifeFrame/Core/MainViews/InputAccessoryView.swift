//
//  InputAccessoryView.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI
import PhotosUI

struct InputAccessoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let chapterService = ChapterDataService.shared
    
    @ObservedObject var itemViewModel: ItemDataService
    @ObservedObject var audioRecorder: AudioRecorder
    @ObservedObject var audioPlayerVM: AudioPlayer
    
    @Binding var isKeyboardPresented: Bool
    @Binding var isFloatingBtnPresented: Bool
    @Binding var isChapterAdded: Bool
    @Binding var scrollToBottom: Bool

    @State private var showCameraView: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showImagePickerInTF: Bool = false
    @State private var showPHPAlert: Bool = false
    @State private var showMicroAlert: Bool = false

    @State private var isRecording: Bool = false
    @State private var selectedItems: [UIImage] = []
    @State private var selectedImagesData: [Data] = []
    @State private var selectionsVideo = [URL]()
    @State private var containerHeight : CGFloat = 0

//    var message: Binding<String> {
//        Binding(
//            get: { chapterService.message },
//            set: { chapterService.message = $0 }
//        )
//    }
    
    @State var message: String = ""
    
    var chapter: ChapterMO
    
    init(chapter: ChapterMO, audioPlayer: AudioPlayer, isKeyboardPresented: Binding<Bool>, isFloatingBtnPresented: Binding<Bool>, isChapterAdded: Binding<Bool>, scrollToBottom: Binding<Bool>) {
        self.itemViewModel = ItemDataService(chapter: chapter)
        self.audioRecorder = AudioRecorder(itemModel: ItemDataService(chapter: chapter))
        self.audioPlayerVM = audioPlayer
        self.chapter = chapter
        
        self._isKeyboardPresented = isKeyboardPresented
        self._isFloatingBtnPresented = isFloatingBtnPresented
        self._isChapterAdded = isChapterAdded
        self._scrollToBottom = scrollToBottom
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isFloatingBtnPresented && !chapterService.isEditingMode {
                floatingButtonView
            }

            HStack(spacing: 0) {
                if !isKeyboardPresented {
                    if !isRecording {
                        attachmentBtnView
                    } else {
                        recordingDuration
                    }
                }

                VStack {
                    if !selectedItems.isEmpty && isKeyboardPresented {
                        selectedItemsView
                    }
                                        
                    AutosizingTextField(text: $message, containerHeight: $containerHeight, isFirstResponder: $isKeyboardPresented, send: {
                        if chapterService.isEditingMode == true {
                            self.editItem()
                        } else {
                            self.addItem()
                        }
                    }, media: {
                        handlePHPPermission(useTFVersion: true)
                    }, cancel: {
                        chapterService.endEdit()
                        withAnimation {
                            isKeyboardPresented = false
                        }
                    })
                    .frame(height: containerHeight < 150 ? containerHeight : 150)
                    .padding(.horizontal, 8)
                    .padding(.vertical, isKeyboardPresented ? 20 : 0)
                    .animation(.easeInOut(duration: 0.5), value: isKeyboardPresented)
                    .sheet(isPresented: $showImagePickerInTF) {
                        ImagesPicker(selections: $selectedItems, selectionsVideo: $selectionsVideo, addFunc: {})
                    }
                    .onTapGesture {
                        withAnimation {
                            isKeyboardPresented = true
                        }
                    }
                    .opacity(isRecording ? 0 : 1)
                }
                
                if !isKeyboardPresented {
                    audioBtnView
                }
            }
            .background(backgroundColor)
            .cornerRadius(isKeyboardPresented ? 8 : 16,
                          corners: isKeyboardPresented ? [.topLeft, .topRight] : [.allCorners])
            .shadowInputControl()
            .padding(.horizontal, isKeyboardPresented ? 0 : 16)
//            .shadowInputControl()
            .background(
                BlurView(style: .systemChromeMaterial, intensity: 0.1)
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.horizontal, 16)
            )
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    private var backgroundColor: Color {
        if isKeyboardPresented && !isRecording {
            return Color.theme.cW
        } else if !isKeyboardPresented && !isRecording {
            return Color.theme.c2
        } else {
            return Color.theme.c1
        }
    }
}

extension InputAccessoryView {
    private func addItem() {
        chapterService.addChapterIfNeeded()
        isChapterAdded = true

        let currentMessage = message
        
        if !currentMessage.isEmpty {
            if selectedItems.isEmpty {
                itemViewModel.addItemParagraph(chapter: chapter,
                                               text: currentMessage)
            } else {
                itemViewModel.addItemParagraphAndMedia(chapter: chapter,
                                                       attachments: selectedItems,
                                                       text: currentMessage)
            }
        } else if !selectedItems.isEmpty {
            itemViewModel.addItemMedia(chapter: chapter,
                                       attachments: selectedItems,
                                       type: ItemType.photo)
        }
        
        chapterService.updateStatusValue()
        selectedItems.removeAll()
        message = ""
    }
    
    private func editItem() {
        chapterService.editItem(itemVM: itemViewModel, text: message)
    }
    
    private func handlePHPPermission(useTFVersion: Bool) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                if useTFVersion {
                    self.showImagePickerInTF.toggle()
                } else {
                    self.showImagePicker.toggle()
                }
            case .denied, .restricted, .notDetermined:
                self.showPHPAlert.toggle()
            @unknown default:
                break
            }
        }
    }
    
    private func handleAudioPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            if !audioRecorder.isRecording {
                withAnimation {
                    self.isRecording = true
                }
                startRecording()
            }
        case .denied, .undetermined:
            self.showMicroAlert.toggle()
        @unknown default:
            break
        }
    }
    
    private func startRecording() {
        if audioPlayerVM.audioPlayer?.isPlaying ?? false {
            audioPlayerVM.stopPlayback()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                audioRecorder.startRecording()
            }
        } else {
            audioRecorder.startRecording()
        }
    }
    
    private func stopRecording() {
        audioRecorder.stopRecording(chapter: chapter)
    }
}

extension InputAccessoryView {
    private var selectedItemsView: some View {
        HStack(alignment: .bottom, spacing: 20) {
            ForEach(selectedItems, id: \.self) { item in
                Image(uiImage: item)
                    .imageInTFStyle(w: 42, h: 42)
                    .overlay(
                        Button(action: {
                            withAnimation {
                                selectedItems.removeAll(where: { $0 == item })
                            }
                        }, label: {
                            Image(UI.Icons.cross)
                        })
                        .offset(x: 18, y: -18)
                    )
            }
            Spacer()
        }
        .transition(.opacity)
        .padding(.top, 28)
        .padding(.leading, 16)
        .transition(.opacity)
    }
    
    private var floatingButtonView: some View {
        HStack {
            Spacer()
            Button(action: {
                self.scrollToBottom.toggle()
            }, label: {
                Image(UI.Buttons.scroll_to_bottom)
                    .font(.system(size: 25))
                    .foregroundColor(.black)
            })
            .transition(.scale)
            .padding(.trailing, 26)
            .padding(.bottom, 26)
        }
    }
    
    private var attachmentBtnView: some View {
        Button {
            handlePHPPermission(useTFVersion: false)
        } label: {
            HStack(spacing: 0) {
                Image(UI.Icons.attachments)
                    .padding(16)
                    .foregroundColor(Color.theme.cW)
                Rectangle()
                    .frame(width: 2, height: 44)
                    .foregroundColor(Color.theme.c3)
            }
        }
        .alert(isPresented: $showPHPAlert) {
            Alert(title: Text(UI.Alearts.php_alert_title),
                  message: Text(UI.Alearts.php_message_text),
                  primaryButton: .default(Text(UI.Alearts.php_primaryBtn_text)),
                  secondaryButton: .default(Text(UI.Alearts.php_secondaryBtn_text), action: {
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                              UIApplication.shared.open(settingsURL)
                  }))
        }
        .transition(.scale)
        .sheet(isPresented: $showImagePicker) {
            ImagesPicker(selections: $selectedItems, selectionsVideo: $selectionsVideo, addFunc: withAnimation { addItem })
        }
        .opacity(isRecording ? 0 : 1)
    }
    
    private var audioBtnView: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 2, height: 44)
                .foregroundColor(Color.theme.c3)
                .opacity(isRecording ? 0 : 1)
            ZStack {
                Image(UI.Icons.audio_message)
                    .padding(16)
                    .foregroundColor(isRecording ? Color.theme.c5 : Color.theme.cW)
            }
        }
        .alert(isPresented: $showMicroAlert) {
            Alert(
                title: Text(UI.Alearts.micro_alert_title),
                message: Text(UI.Alearts.micro_message_text),
                primaryButton: .default(Text(UI.Alearts.micro_primaryBtn_text)),
                secondaryButton: .default(Text(UI.Alearts.micro_secondaryBtn_text)) {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            )
        }
        .transition(.scale)
        .onTapGesture {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async { }
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            handleAudioPermission()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onEnded { _ in
                if audioRecorder.isRecording {
                    stopRecording()
                    withAnimation {
                        self.isRecording = false
                    }
                }
            }
        )
    }
    
    private var recordingDuration: some View {
        HStack(spacing: 8) {
            if let audioRecorder = audioRecorder.audioRecorder, audioRecorder.isRecording {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text("-\(DateComponentsFormatter.positional.string(from: audioRecorder.currentTime) ?? "0:00")")
                        .memoryRecordingDurationStyle()
                }
            }
            Circle()
                .frame(width: 10)
                .foregroundColor(Color.theme.c5)
        }.padding(.leading, 16)
    }
}



//if showCameraView {
//    CameraView()
//        .environmentObject(cameraModel)
//        .background(BlurView(style: .systemMaterialDark, intensity: 1))
//        .ignoresSafeArea()
//}
