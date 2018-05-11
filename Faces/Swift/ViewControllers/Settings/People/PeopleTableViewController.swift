//
//  PeopleTableViewController.swift
//  Faces
//
//  Created by Евгений Левин on 10.04.2018.
//  Copyright © 2018 levin inc. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class PeopleTableViewController: UITableViewController, CNContactViewControllerDelegate {
    var people = PersonInfoManager.getPersonInfoFromDB()
    var searchResults = [Person]()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.searchResults = people
        
        // Configuring the search bar
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
        
        //self.tableView.backgroundView = UIView()
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "personTableCell", for: indexPath) as? PersonTableViewCell else {
            fatalError("The dequeued cell is not an instance of PersonTableViewCell.")
        }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        cell.nameLabel.text = "\(searchResults[indexPath.row].firstName ?? "") \(searchResults[indexPath.row].lastName ?? "")"
        cell.companyLabel.text = searchResults[indexPath.row].company
        cell.phoneLabel.text = searchResults[indexPath.row].phone
        cell.faceImageView.image = UIImage(contentsOfFile: documentsURL.appendingPathComponent(SettingsManager.getModelPath() + "/Avatars/" + searchResults[indexPath.row].photoTitle!).path)
        cell.faceImageView.layer.cornerRadius = 32.5
        cell.faceImageView.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPersonDetail(person: searchResults[indexPath.row])
        
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "personDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! PersonDetailTableViewController
                destinationViewController.person = self.people[indexPath.row]
            }
        }
    }
    
    func showPersonDetail(person: Person) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let store = CNContactStore()
        let contact = CNMutableContact()
        let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: (person.phone?.onlyDigits())!))
        let workEmail = CNLabeledValue(label: CNLabelWork, value: person.email! as! NSString)
        
        contact.phoneNumbers = [phone]
        contact.emailAddresses = [workEmail]
        contact.givenName = (person.firstName)!
        contact.familyName = (person.lastName)!
        contact.organizationName = (person.company)!
        contact.imageData = UIImagePNGRepresentation(UIImage(contentsOfFile: documentsURL.appendingPathComponent(SettingsManager.getModelPath() + "/Avatars/" + (person.photoTitle!)).path)!)
        contact.note = (person.information)!
        let controller = CNContactViewController(forUnknownContact: contact)
        controller.contactStore = store
        controller.delegate = self
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(controller, animated: true)
    }

}



extension PeopleTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            searchResults = people
        } else {
            searchResults = people.filter {($0.firstName! + " " + $0.lastName! + " " + $0.company!).lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        self.tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
}

extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeAColl() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

