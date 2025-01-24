//
//  Chapter.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import CoreData

@objc(ChapterMO)
public class ChapterMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var items: NSSet?
}

extension ChapterMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChapterMO> {
        return NSFetchRequest<ChapterMO>(entityName: "ChapterMO")
    }
    
    @nonobjc public class func resultsController(
        moc: NSManagedObjectContext,
        sortDescriptors: [NSSortDescriptor]) -> NSFetchedResultsController<ChapterMO> 
    {
        let request = NSFetchRequest<ChapterMO>(entityName: "ChapterMO")
        request.sortDescriptors = sortDescriptors
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    public var safeDateContent: Date {
        get { date ?? Date() }
        set { date = newValue }
    }
    
    public var safeContainsNumber: Int {
        let items = items as? Set<ItemMO> ?? []
        return items.count
    }
    
    public var itemsArray: [ItemMO] {
        let itemsSet = items as? Set<ItemMO> ?? []
        
        return itemsSet.sorted {
            $0.safeTimestampContent < $1.safeTimestampContent
        }
    }
}

extension ChapterMO {
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ItemMO)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ItemMO)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}

extension ChapterMO: Identifiable {
    
}
