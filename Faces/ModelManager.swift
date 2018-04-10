//
//  ModelManager.swift
//  Faces
//
//  Created by Евгений Левин on 10.04.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import Foundation
import Vision
import CoreData
import UIKit

class ModelManager {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let model: VNCoreMLModel = loadModel()
    static let peopleNames: [String] = getModelClasses()
    static let people: [Person] = loadPeople()
    
    static func loadModel() -> VNCoreMLModel {
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()
        let models = try! context.fetch(fetchRequest)
        let mlModel = try! MLModel(contentsOf: models[0].path!)
        let model = try! VNCoreMLModel(for: mlModel)
        return model
    }
    
    static func saveModelToDB(permanentUrl: URL) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Model")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        let entity = NSEntityDescription.entity(forEntityName: "Model", in: context)
        let modelObject = NSManagedObject(entity: entity!, insertInto: context) as! Model
        modelObject.path = permanentUrl
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch {
            print("Can't save URL", permanentUrl, "to CoreData")
        }
        savePeopleInformationToDB()
    }
    
    static func moveModelToAppSupportDir(from compiledUrl: URL) {
        // find the app support directory
        let fileManager = FileManager.default
        let appSupportDirectory = try! fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: compiledUrl, create: true)
        // create a permanent URL in the app support directory
        let permanentUrl = appSupportDirectory.appendingPathComponent("faces_model.mlmodelc", isDirectory: false)
        do {
            // if the file exists, replace it. Otherwise, copy the file to the destination.
            if fileManager.fileExists(atPath: permanentUrl.path) {
                _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
            } else {
                try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
            }
            saveModelToDB(permanentUrl: permanentUrl)
        } catch {
            print("Error during copy: \(error.localizedDescription)")
        }
    }
    
    static func getModelClasses() -> [String] {
        var people = [String]()
        
        // Create Classification request
        let request = VNCoreMLRequest(model: self.model, completionHandler: {request, error in
            guard error == nil else {
                print("ML request error: \(error!.localizedDescription)")
                return
            }
            
            guard let classifications = request.results as? [VNClassificationObservation] else { 
                print("No classifications")
                return
            }
            for classification in classifications {
                let identifier = classification.identifier
                if identifier != "unknown" {
                    people.append(identifier)
                }
            }
        })
        request.imageCropAndScaleOption = .scaleFit // scale to size required by algorithm
        
        do {
            try VNImageRequestHandler(ciImage: CIImage(image: UIImage(named: "Evgeny Levin")!)!, options: [:]).perform([request])
        } catch {
            print("ML request handler error: \(error.localizedDescription)")
        }
        return people
    }
    
    static func savePeopleInformationToDB() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        for name in peopleNames {
            let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context) as! Person
            person.name = name
        }
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch {
            print("Can't save people to CoreData")
        }
    }
    
    static func printPeople() {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let people = try! context.fetch(fetchRequest)
        for person in people {
            print(person.name ?? "Unknown")
        }
    }
    
    static func loadPeople() -> [Person] {
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let people = try! context.fetch(fetchRequest)
        return people
    }
}
