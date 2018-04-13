//
//  FileDownloader.swift
//  Faces
//
//  Created by Евгений Левин on 13.04.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import Alamofire
import SSZipArchive

class FileDownloader {
    
    static func downloadZIPWithProgressView(onViewController viewController: UIViewController, fromURL url: String, withName name: String, toDir destination: URL) {
        let destinationURL: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = destination.appendingPathComponent(name+".zip")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let (alertController, progressView) = AlertController.createAlertControllerWithProgressView(withTitle: "Please wait...", withMessage: nil)
        viewController.present(alertController, animated: true, completion: nil)

        print("INFO: Downloading file from [" + url + "].")
        Alamofire.download(url, to: destinationURL)
            .downloadProgress { progress in
                print("INFO: Download Progress: \(progress.fractionCompleted)")
                progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            .responseData { response in
                alertController.dismiss(animated: true, completion: nil)
                if response.error == nil, let filePath = response.destinationURL?.path {
                    print("INFO: Downloaded file to [" + filePath + "].")
                    let permanentPath = destination.appendingPathComponent("Models", isDirectory: true).appendingPathComponent(name, isDirectory: false)
                    print("File will be unpacked to [" + permanentPath.path + "].")
                    print("INFO: Starting unpacking...")
                    SSZipArchive.unzipFile(atPath: filePath, toDestination: permanentPath.path)
                    print("INFO: The file was successfully unpacked to [" + permanentPath.path + "].")
                    let modelPath = permanentPath.appendingPathComponent("model.mlmodel", isDirectory: false)
                    print("INFO: Compiling model [" + modelPath.path + "].")
                    let compiledModel = ModelManager.compileModel(location: modelPath)
                    print("INFO: Compiled succesfully to [" + compiledModel.path + "].")
                    print("INFO: Saving model to DB...")
                    ModelManager.saveModelToDB(onlineURL: URL(string: url)!, localPermanentURL: compiledModel)
                    print("INFO: Saved succesfully.")
                    AlertController.showMessageAlert(onViewController: viewController, withTitle: "Download complete", withMessage: nil)
                } else {
                    print("ERROR: an error occurred while downloading the file")
                    AlertController.showMessageAlert(onViewController: viewController, withTitle: "Error :(", withMessage: "Something went wrong")
                }
            }
        }
}

