//
//  ContentView.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    // MARK: - Variables
    @EnvironmentObject private var vm: HomeVM
    
    @EnvironmentObject var quickActionSettings: QuickActionVM
    @EnvironmentObject var popUp: BottomPopUpVM
    @State var memory: Float = 0

    @StateObject var audioPlayer = AudioPlayer()
    
    let chapterService = ChapterDataService.shared

    //Presented variables
    @State private var isSearchPresented = false
    @State private var isStatsPresented = false
    @State private var isKeyboardPresented = false
    @State private var isFloatingBtnPresented = false
    @State private var isLoadingPresented = true
    
    @State private var isSearchMode = false
    @State private var searchText: String = ""
        
    @State private var scrollToBottom = false

    @State private var isChapterAdded = false

    @State private var scrollViewSize: CGSize = .zero
    
    @State var message = ""

    @Namespace var bottomID
    
    private let hieght: CGFloat = UI.screen_height / 2
    private let spaceName = "main_scroll"
    
    var chapter: ChapterMO?
    
    @State private var scrollToMemoryIndex: UUID? = nil

    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            Spacer(minLength: 16)
                            HStack(alignment: .center) {
                                Text("2023")
                                    .chapterYearStyle()
                            }
                            
                            ForEach(vm.allChapters) { chapter in
                                ChapterCellView(chapter: chapter,
                                                searchText: vm.searchText,
                                                audioPlayer: audioPlayer,
                                                isKeyboardPresented: $isKeyboardPresented,
                                                scrollToMemoryIndex: $scrollToMemoryIndex
                                )
                                Spacer(minLength: UI.chapters_spaces)
                            }
                            
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: isSearchMode ? 0 : (isKeyboardPresented ? 50 : 85))
                                .id(bottomID)
                        }
                        .modifier(FlipModifier())
                        .modifier(FloatingButtonModifier(isFloatingBtnPresented: $isFloatingBtnPresented, spaceName: spaceName))
                        
                        switch vm.state {
                        case .good:
                            Color.clear
                                .onAppear {
                                    vm.loadMore()
                                    print(isSearchPresented)
                                }
                        case .isLoading:
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(chapterService.isEditingMode)
                    .coordinateSpace(name: spaceName)
                    .modifier(FlipModifier())
                    .onChange(of: chapterService.isEditingMode) { newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.linear(duration: 0.1)) {
                                proxy.scrollTo(scrollToMemoryIndex, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: vm.allChapters.last?.safeContainsNumber) { newValue in
                        if isChapterAdded {
                            proxy.scrollTo(bottomID, anchor: .bottom)
                            isChapterAdded = false
                        }
                    }
                    .onChange(of: scrollToBottom) { newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.linear(duration: 0.1)) {
                                proxy.scrollTo(bottomID, anchor: .bottom)
                            }
                        }
                    }
                    .onTapGesture {
                        self.endEditing()
                    }
                    .edgesIgnoringSafeArea(isKeyboardPresented ? .top : .bottom)
                }
                .ignoresSafeArea(isSearchPresented ? .keyboard : [])
                .background(Color.theme.cW)
                .keyboardToolbar(isPresented: $isSearchMode, view: {
                    VStack {
//                        Text("Память: ") + Text(memory, format: .number.precision(.fractionLength(1)))
//                            .foregroundColor(.red)
//                            .bold()
                        
                        InputAccessoryView (
                            chapter: vm.currentChapter,
                            audioPlayer: audioPlayer,
                            isKeyboardPresented: $isKeyboardPresented,
                            isFloatingBtnPresented: $isFloatingBtnPresented,
                            isChapterAdded: $isChapterAdded,
                            scrollToBottom: $scrollToBottom
                        )
                    }
                })
                .searchable(text: $vm.searchText, isPresented: $isSearchPresented, inSearchMode: $isSearchMode, closeAddView: { isKeyboardPresented = false })
            }
            .navigationBarItems(
                leading:
                    statsBtn
                    .fullScreenCover(isPresented: $isStatsPresented) {
                        GeometryReader { proxy in
                            let topEdge = proxy.safeAreaInsets.top
                            StatisticsView(topEdge: topEdge)
                                .ignoresSafeArea(.all, edges: .top)
                        }
                    }
                ,trailing:
                    searchBtn
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(Date().dateToString("LLLL"))
                            .bold()
                            .foregroundColor(Color.theme.cB)
                    }
                }
            }
            .toolbar(isSearchPresented ? .hidden : .visible)
            .toolbarBackground(Color.theme.cW, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .modifier(PopUpModifier(type: ""))
        .task {
            for await _ in Timer.publish(every: 0.3, on: .main, in: .common).autoconnect().values {
                memory = reportMemory()
            }
        }
    }
    
    private func endEditing() {
        if chapterService.isEditingMode == false {
            UIApplication.shared.endEditing()
            withAnimation(.easeInOut) {
                isKeyboardPresented = false
            }
        }
    }

    private func beginEditing() {
        UIApplication.shared.beginEditing()
        if !isStatsPresented {
            withAnimation(.easeInOut) {
                isKeyboardPresented = true
            }
        }
    }

    private var statsBtn: some View {
        Button(action: {
            if isKeyboardPresented {
                withAnimation {
                    isKeyboardPresented = false
                }
            }
            self.isStatsPresented.toggle()
        }) {
            Image(vm.getStatusImage())
                .padding(.bottom, 14)
                .animation(.smooth, value: vm.statusValue)
        }
    }

    private var searchBtn: some View {
        Button(action: {
            if isSearchPresented {
                DispatchQueue.main.async {
                    withAnimation {
                        self.isSearchPresented = false
                        UIApplication.shared.endEditing()
                    }
                }
            } else {
                withAnimation {
                    self.isSearchPresented = true
                }
            }
        }) {
            Image(UI.Icons.search)
        }
    }
}

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    
    var body: some View {
        ZStack {
            content().background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: proxy.size
                    )
                }
            )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}



// Memory check

func reportMemory() -> Float {
    var taskInfo = task_vm_info_data_t()
    var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
    let _: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
        }
    }
    let usedMb = Float(taskInfo.phys_footprint) / 1048576.0
    return usedMb
}
