//
//  PersonDetailTableViewController.swift
//  Faces
//
//  Created by Евгений Левин on 10.05.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import MessageUI

class PersonDetailTableViewController: UITableViewController, CNContactViewControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var companyCell: UITableViewCell!
    @IBOutlet weak var contactsCell: UITableViewCell!
    @IBOutlet weak var informationCell: UITableViewCell!
    
    
    var person: Person?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        self.navigationItem.title = "\(person?.firstName ?? "") \(person?.lastName ?? "")"
        self.faceImageView.image = UIImage(contentsOfFile: documentsURL.appendingPathComponent(SettingsManager.getModelPath() + "/Avatars/" + (person?.photoTitle!)!).path)
        faceImageView.layer.cornerRadius = 35
        faceImageView.clipsToBounds = true
        
        //self.companyLabel.text = person?.company
        self.contactsCell.textLabel?.numberOfLines = 0
        self.contactsCell.textLabel?.numberOfLines = 0
        self.informationCell.textLabel?.numberOfLines = 0
        self.companyCell.textLabel?.text = person?.company
        self.contactsCell.textLabel?.text = (person?.phone)! + "\n" + (person?.email)!
        self.informationCell.textLabel?.text = person?.information
        
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    
        // Configure the cell...
    
        return cell
    }
    */

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

    
    @IBAction func makePhoneCall(_ sender: Any) {
        self.person?.phone?.makeAColl()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.recipients = [person?.phone] as! [String]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        } else {
            AlertController.showMessageAlert(onViewController: self, withTitle: NSLocalizedString("Oops!", comment: ""), withMessage: NSLocalizedString("Can't send message :(", comment: ""))
        }
    }
    
    
    @IBAction func sendEMail(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([(person?.email)!])
            present(mail, animated: true)
        } else {
            AlertController.showMessageAlert(onViewController: self, withTitle: NSLocalizedString("Oops!", comment: ""), withMessage: NSLocalizedString("Can't send e-mail :(", comment: ""))
        }
    }
    
}
