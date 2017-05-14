//
//  CreateTaskVC.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/4/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import ContactsUI

class CreateTaskVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var contacts = [CNContact]()
    var filteredContacts = [CNContact]()
    var searchActive : Bool = false
    var selectedContact:CNContact? = nil
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchBar.delegate = self

        // Do any additional setup after loading the view.
        
        loadContacts()
    }
    
    func endEditing(){
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredContacts = contacts.filter({ (contact) -> Bool in
            let tmp: String = contact.givenName.isEmpty ? contact.familyName : contact.givenName + " " + contact.familyName
            
            let range = tmp.range(of:searchText, options: .caseInsensitive)
            return range != nil
        })
        
        if(filteredContacts.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        endEditing()
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadContacts(){
        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try CNContactStore().enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                self.contacts.append(contact)
            }
            
            if contacts.count > 0{
                contacts.sort(by: { (cn1, cn2) -> Bool in
                    return (cn1.givenName + cn1.familyName) < (cn2.givenName + cn2.familyName)
                })
            }
        }
        catch {
            print("unable to fetch contacts")
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 1
        tableView.separatorStyle = .singleLine
        tableView.backgroundView = nil
        
        if (!(searchBar.text?.isEmpty)! && filteredContacts.count == 0)
        {
            numOfSections = 0
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Stop the madness"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return filteredContacts.count
        }
        
        return contacts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "contactsCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContactsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TasksTableViewCell.")
        }
        
        let contact:CNContact
        
        if(searchActive){
            contact = filteredContacts[indexPath.row]
        } else {
            contact = contacts[indexPath.row];
        }
        
        cell.nameLbl.text = contact.givenName.isEmpty ? contact.familyName : contact.givenName + " " + contact.familyName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(searchActive){
            selectedContact = filteredContacts[indexPath.row]
            filteredContacts.remove(at: indexPath.row)
        }else{
            selectedContact = contacts[indexPath.row]
            contacts.remove(at: indexPath.row)
        }
        
        endEditing()
        self.performSegue(withIdentifier: "unwindToCreateTaskSegue", sender: self)
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // tasks.remove(at: indexPath.row)
            // tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
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
