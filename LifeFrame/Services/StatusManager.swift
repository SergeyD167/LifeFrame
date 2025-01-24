//
//  StatusManager.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation
import CoreData

class StatusManager {
    
    // MARK: Public
    
    static let shared = StatusManager()
    
    func getStatusMO() -> StatusMO {
        let context = PersistenceController.shared.container.viewContext
        
        if let existingStatus = try? context.fetch(StatusMO.fetchRequest()).first {
            return existingStatus
        } else {
            let newStatus = StatusMO(context: context)
            newStatus.value = 0
            newStatus.isChanged = false
            try? context.save()
            return newStatus
        }
    }
    
    func updateValue(newValue: Int) {
        let status = self.getStatusMO()
        status.value = Int16(newValue)
        try? status.managedObjectContext?.save()
    }
    
    func updateIsChanged(newValue: Bool) {
        let status = self.getStatusMO()
        status.isChanged = newValue
        try? status.managedObjectContext?.save()
    }
    
    func updateStatus(newValue: Int, newIsChange: Bool) {
        let status = self.getStatusMO()
        status.value = Int16(newValue)
        status.isChanged = newIsChange
        try? status.managedObjectContext?.save()
    }
}
