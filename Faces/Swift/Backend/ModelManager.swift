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
    
    static func loadModel() -> VNCoreMLModel? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()
        do {
            let models = try context.fetch(fetchRequest)
            guard models.count > 0, let path = models[0].path else {
                print("ERROR: Can't load a model.")
                return nil
            }
            print("INFO: Trying to load model from [" + documentsURL.appendingPathComponent(path).path + "].")
            let mlModel = try MLModel(contentsOf: documentsURL.appendingPathComponent(path))
            let model = try VNCoreMLModel(for: mlModel)
            return model
        } catch {
            print("ERROR: Can't load a model.")
            return nil
        }
    }
    
    static func getModelURL() -> URL? {
        let fetchRequest: NSFetchRequest<Model> = Model.fetchRequest()
        let models = try! context.fetch(fetchRequest)
        if models.count > 0 {
            return models[0].url
        }
        else {
            return nil
        }
    }
    
    static func saveModelToDB(onlineURL: URL, localPermanentURL: String) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Model")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        let entity = NSEntityDescription.entity(forEntityName: "Model", in: context)
        let modelObject = NSManagedObject(entity: entity!, insertInto: context) as! Model
        
        modelObject.url = onlineURL
        modelObject.path = localPermanentURL
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("OK")
        }
        catch {
            print("Can't save Model to DB")
        }
        savePeopleInformationToDB()
    }
    
    static func compileModel(location: URL, saveTo: String) -> String {
        let compiledUrl = try! MLModel.compileModel(at: location)
        return moveModelDocumentsDir(from: compiledUrl, toReletivePath: saveTo)
    }
    
    static func moveModelDocumentsDir(from compiledUrl: URL, toReletivePath relativeURL: String) -> String {
        let destination = relativeURL + "/model.modelc"
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // create a permanent URL in the app support directory
        let permanentUrl = documentsURL.appendingPathComponent(destination)
        do {
            // if the file exists, replace it. Otherwise, copy the file to the destination.
            if fileManager.fileExists(atPath: permanentUrl.path) {
                _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
            } else {
                try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
            }
        } catch {
            print("Error during copy: \(error.localizedDescription)")
        }
        return destination
    }
    
    static func getModelClasses() -> [String] {
        var people = [String]()
        
        // Create Classification request
        guard let model = loadModel() else {
            return []
        }
        let request = VNCoreMLRequest(model: model, completionHandler: {request, error in
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
        
        for name in getModelClasses() {
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
