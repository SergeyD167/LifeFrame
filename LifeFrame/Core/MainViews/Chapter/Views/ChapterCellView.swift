//
//  ChapterCellView.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI

struct ChapterCellView: View {
    let persistenceController = PersistenceController.shared
    let chapterService = ChapterDataService.shared
    
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject private var vm: ChapterCellVM

    @Binding var isKeyboardPresented: Bool
    @Binding var scrollToMemoryIndex: UUID?
    
    var chapter: ChapterMO
    
    init(chapter: ChapterMO,
         searchText: String,
         audioPlayer: AudioPlayer,
         isKeyboardPresented: Binding<Bool>,
         scrollToMemoryIndex: Binding<UUID?>) {
        self.chapter = chapter
        self.audioPlayer = audioPlayer
        self._isKeyboardPresented = isKeyboardPresented
        self._scrollToMemoryIndex = scrollToMemoryIndex
        
        self.vm = ChapterCellVM(chapter: chapter, 
                                searchText: searchText,
                                audioPlayer: audioPlayer
        )
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .center) {
                Text(chapter.safeDateContent.dateToString("d MMMM. EEEE"))
                    .chapterDateStyle()
                Spacer()
            }
            .frame(width: UI.cell_width)
            .background(Color.theme.c8)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 16) {
                if chapter.safeContainsNumber != 0 {
                    ForEach(vm.searchResult, id: \.self) { item in
                        MemoryCellView(memory: item,
                                       isKeyboardPresented: $isKeyboardPresented, 
                                       audioPlayer: audioPlayer,
                                       delete: { vm.deleteItem(item) },
                                       edit: {
                                            chapterService.changeMessage(chapter: chapter, item: item)
                                            scrollToMemoryIndex = item.id
                                            isKeyboardPresented = true
                        })
                        .id(item.id)
                        .frame(width: UI.cell_width - 32)
                    }
                } else {
                    MemoryEmptyCellView()
                        .frame(width: UI.cell_width - 32)
                }
            }
            .padding(.vertical, 16)
            .frame(width: UI.cell_width)
            .background(Color.theme.cW)
            .cornerRadius(16)
            .shadowMemoryStatic()
        }
        .frame(width: UI.cell_width)
    }
}
