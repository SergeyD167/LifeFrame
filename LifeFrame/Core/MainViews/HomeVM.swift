//
//  HomeVM.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import Combine
import CoreData

class HomeVM: ObservableObject {
    @Published var allChapters: [ChapterMO] = []
    @Published var searchText: String = ""
    @Published var statusValue: Int = 0
    @Published var state: State = .good {
        didSet {
            print("state changed to: \(state)")
        }
    }
    
    private let chapterService = ChapterDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    public var currentChapter: ChapterMO {
        return chapterService.chapters.last ?? ChapterMO()
    }
    
    enum SortOption {
        case media, audio, none
    }
    
    enum State: Comparable {
        case good
        case isLoading
    }
    
    init() {
        self.addSubscribers()
    }
    
    func addSubscribers() {
        $searchText
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] term in
                self?.state = .good
                self?.filterChapters(for: term)
            }.store(in: &cancellables)
        
        chapterService.$statusValue
            .sink { [weak self] statusValue in
                self?.statusValue = statusValue
                print("обновил statusValue")
            }
            .store(in: &cancellables)
        
        chapterService.objectWillChange
            .sink { [weak self] in
                self?.allChapters = self?.chapterService.chapters ?? []
                print("обновил allChapters")
            }
            .store(in: &cancellables)
    }
    
    func loadMore() {
        self.filterChapters(for: searchText)
    }
    
    private func filterChapters(for text: String) {
        guard !text.isEmpty else {
            self.allChapters = chapterService.chapters
            return
        }
        
        guard state == State.good else {
            return
        }
        
        state = .isLoading
        
        DispatchQueue.main.async {
            self.allChapters = self.chapterService.chapters.filter { chapter in
                let hasMatchingItem = chapter.itemsArray.contains { item in
                    return item.safeText.localizedCaseInsensitiveContains(text)
                }
                return hasMatchingItem
            }
            self.state = .good
        }
    }
    
    func getStatusImage() -> String {
        switch statusValue {
        case 0...7:
            return "\(statusValue)"
        default:
            return "inactive-long-time"
        }
    }
}
