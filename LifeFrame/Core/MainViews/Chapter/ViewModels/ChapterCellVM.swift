//
//  ChapterCellVM.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import Combine
import SwiftUI

class ChapterCellVM: ObservableObject {
    @Published var searchResult: [ItemMO] = []
    @Published var searchText: String = ""

    private let chapter: ChapterMO
    private let itemService: ItemDataService
    private let audioPlayer: AudioPlayer
    
    private var searchSubject = PassthroughSubject<String, Never>()
    private var cancellable: AnyCancellable?
    
    init(chapter: ChapterMO, searchText: String, audioPlayer: AudioPlayer) {
        self.chapter = chapter
        self.itemService = ItemDataService(chapter: chapter)
        self.audioPlayer = audioPlayer
        self.searchText = searchText
       
        self.setupSearch()
        self.updateAll()
    }
    
    func updateAll() {
        if searchText.isEmpty {
            searchResult = itemService.items
        } else {
            self.searchSubject.send(searchText)
        }
    }
    
    private func setupSearch() {
         cancellable = searchSubject
             .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
             .sink { text in
                 self.searchResult = self.itemService.items.filter {
                     $0.safeText.localizedCaseInsensitiveContains(text)
                 }
             }
     }
    
    func deleteItem(_ item: ItemMO) {
        itemService.deleteItem(item)
    }
}
