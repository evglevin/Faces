//
//  ModelSettingsTableViewController.swift
//  Faces
//
//  Created by Евгений Левин on 28.03.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit
import CoreData

import Alamofire
import SSZipArchive

class ModelSettingsTableViewController: UITableViewController {
    @IBOutlet weak var modelURLLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let identifier = cell?.reuseIdentifier ?? ""
        if identifier == "downloadButtonCell" {
            startDownload()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func startDownload() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let name = "Model0"
        
        let destinationURL: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = documentsURL.appendingPathComponent(name+".zip")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        guard let url = modelURLLabel.text, url != "" else {
            AlertController.showMessageAlert(onViewController: self, withTitle: "Please enter the Model URL", withMessage: nil)
            return
        }
        
        let (alertController, progressView) = AlertController.createAlertControllerWithProgressView(withTitle: "Please wait...", withMessage: nil)
        self.present(alertController, animated: true, completion: nil)
        
        print("[INFO] Downloading file from [" + url + "].")
        Alamofire.download(url, to: destinationURL)
            .downloadProgress { progress in
                print("[INFO] Download Progress: \(progress.fractionCompleted)")
                progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            .responseData { response in
                alertController.dismiss(animated: true, completion: nil)
                if response.error == nil, let filePath = response.destinationURL?.path {
                    print("[INFO] Downloaded file to [" + filePath + "].")
                    let permanentPath = documentsURL.appendingPathComponent("Models", isDirectory: true).appendingPathComponent(name, isDirectory: false)
                    print("[INFO] File will be unpacked to [" + permanentPath.path + "].")
                    print("[INFO] Starting unpacking...")
                    SSZipArchive.unzipFile(atPath: filePath, toDestination: permanentPath.path)
                    print("[INFO] The file was successfully unpacked to [" + permanentPath.path + "].")
                    let modelPath = permanentPath.appendingPathComponent("model.mlmodel", isDirectory: false)
                    print("[INFO] Compiling model [" + modelPath.path + "].")
                    let compiledpath = ModelManager.compileModel(location: modelPath, saveTo: "Models/" + name)
                    print("[INFO] Compiled succesfully to [" + compiledpath + "].")
                    print("[INFO] Saving model to DB...")
                    ModelManager.saveModelToDB(onlineURL: URL(string: url)!, localPermanentURL: compiledpath)
                    print("[INFO] Saved succesfully.")
                    print("[INFO] Saving people to DB...")
                    let jsonPath = documentsURL.appendingPathComponent(compiledpath.replacingOccurrences(of: "model.modelc", with: "")).path + "/info.json"
                    print(jsonPath)
                    let personLoader = PersonInfoLoader(fromJSON: try! Data(contentsOf: URL(fileURLWithPath: jsonPath)))
                    personLoader.getPersonInfos()
                    print("[INFO] Saved succesfully.")
                    AlertController.showMessageAlert(onViewController: self, withTitle: "Download complete", withMessage: nil)
                } else {
                    AlertController.showMessageAlert(onViewController: self, withTitle: "Error :(", withMessage: "Something went wrong")
                    print("[ERROR] an error occurred while downloading the file")
                }
        }
    }
}
