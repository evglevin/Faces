//
//  LanguageTableViewController.swift
//  Faces
//
//  Created by Евгений Левин on 22.05.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit

class LanguageTableViewController: UITableViewController {
    
    //let languages = ["English", "Русский"]

    
    @IBOutlet weak var englishCell: UITableViewCell!
    @IBOutlet weak var russianCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        englishCell.accessoryType = Language.language == Language.english ? .checkmark : .none
        russianCell.accessoryType = Language.language == Language.russian ? .checkmark : .none
//        englishCell.accessoryType = Localize.currentLanguage() == "en" ? .checkmark : .none
//        russianCell.accessoryType = Localize.currentLanguage() == "ru" ? .checkmark : .none
        
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            tableView.deselectRow(at: indexPath, animated: true)
            russianCell.accessoryType = .checkmark
            englishCell.accessoryType = .none
            Language.language = Language.russian
            //Localize.setCurrentLanguage("ru", restartFromRoot: StartScreenViewController)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
            englishCell.accessoryType = .checkmark
            russianCell.accessoryType = .none
            Language.language = Language.english
            //Localize.setCurrentLanguage("en", restartFromRoot: StartScreenViewController)
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
