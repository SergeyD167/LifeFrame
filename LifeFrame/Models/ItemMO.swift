//
//  Item.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import CoreData
import SwiftUI

@objc(ItemMO)
public class ItemMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var text: String?
    @NSManaged public var type: String?
    @NSManaged public var sentiment: String?
    @NSManaged public var attachments: NSSet?
    @NSManaged public var chapter: ChapterMO?
}

extension ItemMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemMO> {
        return NSFetchRequest<ItemMO>(entityName: "ItemMO")
    }

    @nonobjc public class func resultsController(
        moc: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate) -> NSFetchedResultsController<ItemMO>
    {
        let request = NSFetchRequest<ItemMO>(entityName: "ItemMO")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    public var safeTimestampContent: Date {
        get { timestamp ?? Date() }
        set { timestamp = newValue }
    }
    
    public var safeID: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    public var safeText: String {
        get { text ?? String() }
        set { text = newValue }
    }
    
    public var safeType: String {
        get { type ?? String() }
        set { type = newValue }
    }
    
    public var safeSentiment: String {
        get { sentiment ?? String() }
        set { sentiment = newValue }
    }
    
    public var safeSentimentColor: Color {
        switch sentiment {
        case "positive":
            return Color.theme.c3
        case "negative":
            return Color.theme.c5
        default:
            return Color.theme.c4
        }
    }
    
    public var safeSentimentValue: Double {
        switch sentiment {
        case "positive":
            return 10.0
        case "negative":
            return 1.0
        default:
            return 5.0
        }
    }
    
    public var isEditable: Bool {
        guard let timestamp = timestamp else { return true }
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(timestamp)
        let twentyFourHoursInSeconds: TimeInterval = 24 * 60 * 60
        return timeInterval <= twentyFourHoursInSeconds
    }
    
    public var mediaArray: [MediaMO] {
        let itemsSet = attachments as? Set<MediaMO> ?? []
        
        return itemsSet.sorted {
            $0.safeDate < $1.safeDate
        }
    }
    
}

extension ItemMO {
    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: MediaMO)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: MediaMO)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSSet)
}

extension ItemMO: Identifiable {
}
