//
//  PersonInfoManager.swift
//  Faces
//
//  Created by Евгений Левин on 04.05.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PersonInfoManager {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func savaToDB(fromJSON data: Data) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        
        let anyObj = try? JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        
        if anyObj is [AnyObject] {
            for json in anyObj as! [AnyObject] {
                let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context) as! Person
                person.id  =  Int64((json["id"]  as AnyObject? as? Int) ?? 0)
                person.firstName = (json["first_name"] as AnyObject? as? String) ?? ""
                person.lastName = (json["second_name"] as AnyObject? as? String) ?? ""
                person.company = (json["company"] as AnyObject? as? String) ?? ""
                person.phone = (json["phone"] as AnyObject? as? String) ?? ""
                person.email = (json["email"] as AnyObject? as? String) ?? ""
                person.information = (json["information"] as AnyObject? as? String) ?? ""
                person.photoTitle = (json["photo_title"] as AnyObject? as? String) ?? ""
            }
            do {
                try context.execute(deleteRequest)
                try context.save()
            }
            catch {
                print("[ERROR] Can't save people to CoreData")
            }
        }
    }
    
    static func getPeopleInfoFromDB() -> [Person] {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let people = try! context.fetch(fetchRequest)
        return people
    }
    
    static func getPerson(byId id: Int) -> Person {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == \(id)")
        let people = try! context.fetch(fetchRequest)
        return people[0]
    }
}
