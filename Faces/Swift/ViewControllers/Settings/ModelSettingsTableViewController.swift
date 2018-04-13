//
//  ModelSettingsTableViewController.swift
//  Faces
//
//  Created by Евгений Левин on 28.03.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit
import CoreData

class ModelSettingsTableViewController: UITableViewController, URLSessionDownloadDelegate {
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    //let modelURL = URL(string: "https://github.com/evglevin/test/raw/master/faces_model.mlmodel")!
    @IBOutlet weak var modelURLLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        //progressView.setProgress(0.0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        modelURLLabel.text = ModelManager.getModelURL()?.absoluteString
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundSession.finishTasksAndInvalidate()
    }
    
    func startDownload() {
//        downloadTask = backgroundSession.downloadTask(with: URL(string: modelURLLabel.text!)!)
//        downloadTask.resume()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let name = "Model0"
        FileDownloader.downloadZIPWithProgressView(onViewController: self, fromURL: modelURLLabel.text!, withName: name, toDir: documentsURL)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let identifier = cell?.reuseIdentifier ?? ""
        if identifier == "downloadButtonCell" {
            startDownload()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        let compiledUrl = ModelManager.compileModel(location: location)
        //ModelManager.moveModelToDocumentDir(from: compiledUrl, onlineURL: URL(string: modelURLLabel.text!)!)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        //progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //MARK: - URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?){
        downloadTask = nil
        //progressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            let alert = UIAlertController(title: "Model updated successfully", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

}
