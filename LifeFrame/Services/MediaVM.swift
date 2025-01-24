//
//  MediaVM.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import SwiftUI
import CoreData
import Foundation

class MediaVM: ObservableObject {
    private let persistenceController = PersistenceController.shared
    private let controller: NSFetchedResultsController<MediaMO>
    @Published var alert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var mediaItems: [MediaMO] = []
    
    private var item: ItemMO
    
    init(item: ItemMO) {
        let sortDescriptors = [NSSortDescriptor(keyPath: \MediaMO.date, ascending: true)]
        controller = MediaMO.resultsController(moc: persistenceController.viewContext, sortDescriptors: sortDescriptors, predicate: NSPredicate(format: "item = %@", item))
        
        self.item = item        
        fetchItems()
    }
    
    func fetchItems() {
        mediaItems = item.mediaArray
    }
    
    func save() {
        do {
            try controller.managedObjectContext.save()
            alert = false
        } catch {
            alert =  true
            alertMessage = Errors.savingDataError
        }
    }
    
    func addImage(item: ItemMO, image: UIImage) {
        let mediaItem = MediaMO(context: controller.managedObjectContext)
        mediaItem.id = UUID().uuidString
        mediaItem.date = Date()
        mediaItem.item = item
        
        FileManager().saveImage(with: mediaItem.safeID, image: image)
        
        mediaItem.url = FileManager().retrieveURLString(with: mediaItem.safeID)
        
        item.addToAttachments(mediaItem)
        save()
        fetchItems()
    }
    
    func addRecord(item: ItemMO, id: String, url: String) {
        let mediaItem = MediaMO(context: controller.managedObjectContext)
        mediaItem.id = id
        mediaItem.date = Date()
        mediaItem.url = url
        mediaItem.item = item
                
        item.addToAttachments(mediaItem)
        save()
        fetchItems()
    }
    
    func deleteAll() {
        for mediaItem in mediaItems {
            controller.managedObjectContext.delete(mediaItem)
        }
        save()
        fetchItems()
    }
    
    func deleteMedia(_ mediaItem: MediaMO, type: String) {
        controller.managedObjectContext.delete(mediaItem)
        
        switch type {
        case ItemType.textWithPhoto.rawValue, ItemType.photo.rawValue:
            FileManager().delete(with: mediaItem.safeImageURL)
        case ItemType.audio.rawValue:
            FileManager().delete(with: mediaItem.safeAudioURL)
        default:
            break
        }
        
        save()
        fetchItems()
    }
}
