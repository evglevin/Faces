//
//  UpdateModelViewController.swift
//  Faces
//
//  Created by Евгений Левин on 27.03.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit
import CoreML
import CoreData

class UpdateModelViewController: UIViewController, URLSessionDownloadDelegate {

    @IBOutlet weak var progressView: UIProgressView!
    
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    let modelURL = "https://github.com/evglevin/test/raw/master/faces_model.mlmodel"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        progressView.setProgress(0.0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundSession.finishTasksAndInvalidate()
    }
    

    @IBAction func startDownload(_ sender: UIButton) {
        let url = URL(string: modelURL)!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
    //MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        let compiledUrl = try! MLModel.compileModel(at: location)
        moveModelToAppSupportDir(from: compiledUrl)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //MARK: - URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        downloadTask = nil
        progressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            let alert = UIAlertController(title: "Model updated successfully", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func moveModelToAppSupportDir(from compiledUrl: URL) {
        // find the app support directory
        let fileManager = FileManager.default
        let appSupportDirectory = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: compiledUrl, create: true)
        // create a permanent URL in the app support directory
        let permanentUrl = appSupportDirectory.appendingPathComponent("faces_model.mlmodelc", isDirectory: false)
        do {
            // if the file exists, replace it. Otherwise, copy the file to the destination.
            if fileManager.fileExists(atPath: permanentUrl.path) {
                _ = try fileManager.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
            } else {
                try fileManager.copyItem(at: compiledUrl, to: permanentUrl)
            }
            saveModelToCoreData(permanentUrl: permanentUrl)
        } catch {
            print("Error during copy: \(error.localizedDescription)")
        }
    }
    
    func saveModelToCoreData(permanentUrl: URL) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Model", in: context)
        let modelObject = NSManagedObject(entity: entity!, insertInto: context) as! Model
        modelObject.path = permanentUrl.path
        
        do {
            try context.save()
        }
        catch {
            print("Can't save URL", permanentUrl, "to CoreData")
        }
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
