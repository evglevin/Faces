////
////  ModelController.swift
////  Faces
////
////  Created by Евгений Левин on 27.03.2018.
////  Copyright © 2018 levin inc. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class ModelManager: UIViewControllerURLSessionDownloadDelegate {
//    var downloadTask: URLSessionDownloadTask!
//    var backgroundSession: URLSession!
//    var downloadModelProgressView: UIProgressView
//    let modelName = "faces_model.mlmodel"
//    let modelUrl: String
//    
//    init(downloadModelProgressView downloadModelProgressView: UIProgressView, midelUrl URL: String) {
//        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
//        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
//        self.downloadModelProgressView = downloadModelProgressView
//        self.modelUrl = URL
//    }
//    
//    @IBAction func startDownload(_ sender: AnyObject) {
//        let url = URL(string: "http://publications.gbdirect.co.uk/c_book/thecbook.pdf")!
//        downloadTask = backgroundSession.downloadTask(with: url)
//        downloadTask.resume()
//    }
//    
//    //MARK: URLSessionDownloadDelegate
//    // 1
//    func urlSession(_ session: URLSession,
//                    downloadTask: URLSessionDownloadTask,
//                    didFinishDownloadingTo location: URL){
//        
//        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//        let documentDirectoryPath:String = path[0]
//        let fileManager = FileManager()
//        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/file.pdf"))
//        
//        if fileManager.fileExists(atPath: destinationURLForFile.path){
//            //showFileWithPath(path: destinationURLForFile.path)
//        }
//        else{
//            do {
//                try fileManager.moveItem(at: location, to: destinationURLForFile)
//                // show file
//                //showFileWithPath(path: destinationURLForFile.path)
//            }catch{
//                print("An error occurred while moving file to destination url")
//            }
//        }
//    }
//    // 2
//    func urlSession(_ session: URLSession,
//                    downloadTask: URLSessionDownloadTask,
//                    didWriteData bytesWritten: Int64,
//                    totalBytesWritten: Int64,
//                    totalBytesExpectedToWrite: Int64){
//        downloadModelProgressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
//    }
//    
//    
//}

