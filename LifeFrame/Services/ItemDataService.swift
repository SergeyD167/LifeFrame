//
//  ItemVM.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import NaturalLanguage
import Foundation
import CoreData
import CoreML
import SwiftUI

enum ItemType: String {
    case text = "text"
    case textWithPhoto = "textWithPhoto"
    case photo = "photo"
    case audio = "audio"
}

class ItemDataService: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private let controller: NSFetchedResultsController<ItemMO>
    
    private var alert: Bool = false
    private var alertMessage: String = ""
    
    @Published var items: [ItemMO] = []

    private var chapterVM: ChapterDataService
    private var chapter: ChapterMO
    
    init(chapter: ChapterMO) {
        let sortDescriptors = [NSSortDescriptor(keyPath: \ItemMO.timestamp, ascending: true)]
        controller = ItemMO.resultsController(moc: persistenceController.viewContext, 
                                              sortDescriptors: sortDescriptors,
                                              predicate: NSPredicate(format: "chapter = %@", chapter))
        
        self.chapter = chapter
        self.chapterVM = ChapterDataService.shared

        fetchItems()
    }
    
    func addItemParagraph(chapter: ChapterMO, text: String) {
        let item = ItemMO(context: controller.managedObjectContext)
        item.id = UUID()
        item.timestamp = Date()
        item.text = text
        item.type = ItemType.text.rawValue
        item.sentiment = ""
        item.chapter = chapter
        
        chapter.addToItems(item)
        saveContext()
        fetchItems()
        setMemorySentiment(item)
    }
    
    func addItemMedia(chapter: ChapterMO, id: String, attachment: String, type: ItemType) {
        let item = ItemMO(context: controller.managedObjectContext)
        let mediaVM = MediaVM(item: item)
        
        mediaVM.addRecord(item: item, id: id, url: attachment)
        
        item.id = UUID()
        item.timestamp = Date()
        item.type = type.rawValue
        item.sentiment = "neutral"
        item.chapter = chapter
        
        chapter.addToItems(item)
        saveContext()
        fetchItems()
    }
    
    func addItemMedia(chapter: ChapterMO, attachments: [UIImage], type: ItemType) {
        if !attachments.isEmpty && attachments.count <= 3 {
            let item = ItemMO(context: controller.managedObjectContext)
            let mediaVM = MediaVM(item: item)
            
            for attachment in attachments {
                mediaVM.addImage(item: item, image: attachment)
            }
            
            item.id = UUID()
            item.timestamp = Date()
            item.type = type.rawValue
            item.sentiment = "neutral"
            item.chapter = chapter
            
            chapter.addToItems(item)
            saveContext()
            fetchItems()
        } else {
            self.alert =  true
            self.alertMessage = "You can't add more than 3 photos"
        }
    }
    
    func addItemParagraphAndMedia(chapter: ChapterMO, attachments: [UIImage], text: String) {
        if !attachments.isEmpty && attachments.count <= 3 {
            let item = ItemMO(context: controller.managedObjectContext)
            let mediaVM = MediaVM(item: item)
            
            for attachment in attachments {
                mediaVM.addImage(item: item, image: attachment)
            }
            
            item.id = UUID()
            item.timestamp = Date()
            item.type = ItemType.textWithPhoto.rawValue
            item.text = text
            item.sentiment = ""
            item.chapter = chapter
            
            chapter.addToItems(item)
            saveContext()
            fetchItems()
            setMemorySentiment(item)
        } else {
            self.alert =  true
            self.alertMessage = "You can't add more than 3 photos"
        }
    }
    
    func deleteAll() {
        for item in items {
            controller.managedObjectContext.delete(item)
        }
        saveContext()
        fetchItems()
    }
    
    func deleteItem(_ item: ItemMO) {
        let mediaVM = MediaVM(item: item)
        
        for attachment in item.mediaArray {
            mediaVM.deleteMedia(attachment, type: item.safeType)
        }
        
        controller.managedObjectContext.delete(item)
        saveContext()
        fetchItems()
        
        if chapter.itemsArray.isEmpty && !chapter.safeDateContent.isToday {
            chapterVM.deleteChapter(chapter)
        }
    }
    
    private func fetchItems() {
        items = chapter.itemsArray
    }
    
    private func saveContext() {
        do {
            try controller.managedObjectContext.save()
            alert = false
        } catch {
            alert =  true
            alertMessage = Errors.savingDataError
        }
    }
    
    private func applyChanges() {
        saveContext()
        fetchItems()
    }
}

extension ItemDataService {
    func editItem(_ item: ItemMO, text: String) {
        if item.isEditable {
            item.text = text
            saveContext()
            fetchItems()
        }
    }
}

extension ItemDataService {
    func setMemorySentiment(_ item: ItemMO) {
        DispatchQueue.main.async {
            do {
                let mlModel = try SentimentClassifier(configuration: MLModelConfiguration()).model
                let customModel = try NLModel(mlModel: mlModel)
                
                DispatchQueue.main.async {
                    item.sentiment = customModel.predictedLabel(for: item.safeText) ?? ""
                    self.saveContext()
                }
            } catch {
                DispatchQueue.main.async {
                    self.alert =  true
                    self.alertMessage = "Can't load model"
                }
            }
        }
    }
}
