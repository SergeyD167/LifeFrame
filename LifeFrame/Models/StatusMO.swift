//
//  StatusMO.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import CoreData
import SwiftUI

@objc(StatusMO)
public class StatusMO: NSManagedObject {
    @NSManaged public var value: Int16
    @NSManaged public var isChanged: Bool
}

extension StatusMO {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StatusMO> {
        return NSFetchRequest<StatusMO>(entityName: "StatusMO")
    }
    
    @nonobjc public class func resultsController(moc: NSManagedObjectContext) -> NSFetchedResultsController<StatusMO> {
        let request = NSFetchRequest<StatusMO>(entityName: "StatusMO")
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    }
     
    public var safeValue: Int {
        get { Int(value) }
        set { value = Int16(newValue) }
    }
    
    public var safeIsChanged: Bool {
        get { isChanged }
        set { isChanged = newValue }
    }


    public var safeStringValue: String {
        switch value {
        case 0...7:
            return "\(value)"
        default:
            return "inactive-long-time"
        }
    }
}
