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
    var selectedPhnNum:String? = nil
    var existingGroupContacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        contacts = Utilities.getContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            searchActive = false
        } else {
            searchActive = true
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
        
        if(searchActive && filteredContacts.count > indexPath.row){
            selectedContact = filteredContacts[indexPath.row]
        }else{
            selectedContact = contacts[indexPath.row]
        }
        
        // SHOW DIALOG BOX TO SELECT WHICH # THEY WANT
        if((selectedContact?.phoneNumbers.count)! > 1){
            choosePhnNum(contact: selectedContact!)
        }else if (selectedContact?.phoneNumbers.count == 1){
            selectedPhnNum = (selectedContact?.phoneNumbers[0].value.stringValue)!
            self.processSelectedPhnNum()
        }
        else{
            let alert = Utilities.createOKAlertMsg(title: "Nice Try!", message: "This member has no phone numbers saved.")
            present(alert, animated: true, completion: nil)
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Exisitng group members will have only 1phn# so 0th index is fine
    func isSelectedContactPartOfGroup(conatctNum: String) -> Bool {
        return existingGroupContacts.contains(where: { (c) -> Bool in
            return Utilities.getContactPlainPhnNum(number: c.phoneNumbers[0].value.stringValue) == Utilities.getContactPlainPhnNum(number: conatctNum)
        })
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func choosePhnNum(contact: CNContact){
        if (contact.phoneNumbers.count <= 1){
            return
        }
        
        let optionMenu = UIAlertController(title: "Select a number", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        contact.phoneNumbers.forEach { (c) in
            let numStr = c.value.stringValue
            let numAction = UIAlertAction(title: numStr, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.selectedPhnNum = alert.title!
                self.processSelectedPhnNum()
            })
            optionMenu.addAction(numAction)
        }
        optionMenu.addAction(cancelAction)
        
        // below 2 statements are need for ipad
        // unlike iphone, ipad doesn't show a cancel btn. It's just a popover and needs a UI to hook onto
        // that's the reason we hook on to self.view
        optionMenu.popoverPresentationController?.sourceView = self.view;
        optionMenu.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 1, height: 1);
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func processSelectedPhnNum(){
        if(selectedPhnNum == nil){
            let alert = Utilities.createOKAlertMsg(title: "Error", message: "Pleae try again.")
            present(alert, animated: true, completion: nil)
        }else if(!Utilities.isPhnNumValid(number: selectedPhnNum!)){
            let alert = Utilities.createOKAlertMsg(title: "Nice Try!", message: "Member has invalid phone number.")
            present(alert, animated: true, completion: nil)
        }else if (isSelectedContactPartOfGroup(conatctNum: selectedPhnNum!)){
            let alert = Utilities.createOKAlertMsg(title: "Nice Try!", message: "Member already a part of the group.")
            present(alert, animated: true, completion: nil)
        }else{
            endEditing()
            self.performSegue(withIdentifier: "unwindToCreateTaskSegue", sender: self)
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
