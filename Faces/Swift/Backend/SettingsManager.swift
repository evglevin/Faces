//
//  SettingsManager.swift
//  Faces
//
//  Created by Евгений Левин on 09.05.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingsManager {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func savaModelPathToDB(path: String) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        let settings = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: context) as! Settings
        
        settings.modelPath = path
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch {
            print("[ERROR] Can't save people to CoreData")
        }
    }
    
    static func getModelPath() -> String {
        let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
        let settings = try! context.fetch(fetchRequest)
        return settings[0].modelPath!
    }
}
