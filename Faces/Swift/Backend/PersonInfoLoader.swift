//
//  JSONHelper.swift
//  Faces
//
//  Created by Евгений Левин on 04.05.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import Foundation

class PersonInfoLoader {
    let data: Data
    let persons: [PersonInfo]
    
    init(fromJSON data: Data) {
        self.data = data
        self.persons = []
    }
    
    func getPersonInfos() {
        print("start")
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        let persons = parseJSON(anyObj: json as AnyObject)
        print(persons)
        
        print("end")
    }
    
    func parseJSON(anyObj: AnyObject) -> [PersonInfo] {
        var persons = [PersonInfo]()
        if anyObj is [AnyObject] {
            var personInfo = PersonInfo()
            for json in anyObj as! [AnyObject] {
                personInfo.id  =  (json["id"]  as AnyObject? as? Int) ?? 0
                personInfo.name = (json["name"] as AnyObject? as? String) ?? ""
                personInfo.phone = (json["phone"] as AnyObject? as? String) ?? ""
                personInfo.email = (json["email"] as AnyObject? as? String) ?? ""
                personInfo.information = (json["information"] as AnyObject? as? String) ?? ""
                personInfo.photoTitle = (json["photo_title"] as AnyObject? as? String) ?? ""
                
                persons.append(personInfo)
            }
        }
        return persons
    }
    
//    func savaToDB() {
//        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//
//        for personInfo in persons {
//            let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context) as! Person
//            person.name = name
//        }
//
//        do {
//            try context.execute(deleteRequest)
//            try context.save()
//        }
//        catch {
//            print("[ERROR] Can't save people to CoreData")
//        }
//    }
}
