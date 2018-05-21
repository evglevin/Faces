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

class PersonDetailTableViewController: UITableViewController, CNContactViewControllerDelegate {
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var phoneCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var informationCell: UITableViewCell!
    @IBOutlet weak var companyLabel: UILabel!
    
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
        
        self.companyLabel.text = person?.company
        self.phoneCell.textLabel?.text = person?.phone
        self.emailCell.textLabel?.text = person?.email
        self.informationCell.textLabel?.numberOfLines = 0
        self.informationCell.textLabel?.text = person?.information
        
        self.tableView.tableFooterView = UIView()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            showPhoneAlert()
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
    }
    
    func showPhoneAlert() {
        let ac = UIAlertController(title: nil, message: "\(person?.phone ?? "")", preferredStyle: .actionSheet)
        let call = UIAlertAction(title: NSLocalizedString("Call", comment: ""), style: .default, handler: { _ in
            self.person?.phone?.makeAColl()
        })
        let createContact = UIAlertAction(title: NSLocalizedString("Add contact", comment: ""), style: .default, handler: { _ in
            let store = CNContactStore()
            let contact = CNMutableContact()
            let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: (self.person?.phone?.onlyDigits())!))
            let workEmail = CNLabeledValue(label: CNLabelWork, value: self.person?.email! as! NSString)
            
            contact.phoneNumbers = [phone]
            contact.emailAddresses = [workEmail]
            contact.givenName = (self.person?.firstName)!
            contact.familyName = (self.person?.lastName)!
            contact.organizationName = (self.person?.company)!
            contact.imageData = UIImagePNGRepresentation(self.faceImageView.image!)
            contact.note = (self.person?.information)!
            let controller = CNContactViewController(forUnknownContact: contact)
            controller.contactStore = store
            controller.delegate = self
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(controller, animated: true)
        })
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        ac.addAction(cancel)
        ac.addAction(call)
        ac.addAction(createContact)
        present(ac, animated: true, completion: nil)
    }

}

//extension String {
//
//    enum RegularExpressions: String {
//        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
//    }
//
//    func isValid(regex: RegularExpressions) -> Bool {
//        return isValid(regex: regex.rawValue)
//    }
//
//    func isValid(regex: String) -> Bool {
//        let matches = range(of: regex, options: .regularExpression)
//        return matches != nil
//    }
//
//    func onlyDigits() -> String {
//        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
//        return String(String.UnicodeScalarView(filtredUnicodeScalars))
//    }
//
//    func makeAColl() {
//        if isValid(regex: .phone) {
//            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
//                if #available(iOS 10, *) {
//                    UIApplication.shared.open(url)
//                } else {
//                    UIApplication.shared.openURL(url)
//                }
//            }
//        }
//    }
//}
