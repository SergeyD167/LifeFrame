//
//  MediaData.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import CoreData
import UIKit

@objc(MediaMO)
public class MediaMO: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var url: String?
    @NSManaged public var item: ItemMO?
}

extension MediaMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaMO> {
        return NSFetchRequest<MediaMO>(entityName: "MediaMO")
    }
    
    @nonobjc public class func resultsController(
        moc: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate) -> NSFetchedResultsController<MediaMO>
    {
        let request =  NSFetchRequest<MediaMO>(entityName: "MediaMO")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    public var safeID: String {
        get { id ?? UUID().uuidString }
        set { id = newValue }
    }
    
    public var safeDate: Date {
        get { date ?? Date() }
        set { date = newValue }
    }
    
    public var safeURL: String {
        get { url ?? String() }
        set { url = newValue }
    }
    
    public var safeImageURL: URL {
        FileManager().retrieveURL(with: safeID)!
    }
    
    public var safeAudioURL: URL {
        FileManager().retrieveAudioURL(with: safeID)!
    }
    
    public var safeDateString: String {
        safeDate.dateToString("dd-MM-YY_'at'_HH:mm:ss")
    }
    
    public var uiImage: UIImage {
        if !safeID.isEmpty,
           let image = FileManager().retrieveImage(with: safeID) {
            return image
        } else {
            return UIImage(systemName: "photo")!
        }
    }
}

extension MediaMO: Identifiable {
}
