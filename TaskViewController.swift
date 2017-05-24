//
//  TaskViewController.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/21/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import Parse
import ContactsUI

class TaskViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var currentTask:PFObject?
    var pickerDataSource = [PFUser]()
    var contacts = [CNContact]()

    @IBOutlet weak var txtTaskName: UILabel!
    @IBOutlet weak var txtTaskDescription: UITextView!
    @IBOutlet weak var lblNextTurn: UILabel!
    @IBOutlet weak var membersPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.membersPickerView.dataSource = self;
        self.membersPickerView.delegate = self;
        self.membersPickerView.showsSelectionIndicator = true
        
        contacts = Utilities.loadContacts()

        clearTaskDetails()
        
        if(currentTask != nil && !(currentTask?.objectId?.isEmpty)!){
            title = currentTask?["Name"]! as? String
            txtTaskDescription.text = currentTask?["Description"]! as? String
            loadMembers()
        }
    }
    
    func getAndSelectCurrentNextTurnMember() -> Int?{
        if let task = currentTask, let nextTurnMember = task["NextTurnMember"] {
            let member = nextTurnMember as! PFUser
            let memberIndex = pickerDataSource.index(where: { (u) -> Bool in
                u.objectId == member.objectId
            })
            return memberIndex
        }
        return nil
    }
    
    func loadMembers(){
        
        let query = PFQuery(className: "Task")
        query.whereKey("objectId", equalTo: currentTask!.objectId!)
        query.includeKey("Members")
        query.includeKey("NextTurnMember")
        
        //currentTask?.fetchInBackground not fetching username
        
        query.getFirstObjectInBackground(block: { (task, error) in
            if(error == nil && task != nil){
                self.pickerDataSource = task?["Members"] as! [PFUser]
                let nextTurnMemberIndex = self.getAndSelectCurrentNextTurnMember()
                DispatchQueue.main.async {
                    self.membersPickerView.reloadAllComponents()
                    if let index = nextTurnMemberIndex{
                        self.membersPickerView.selectRow(index, inComponent: 0, animated: true)
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // move this to didLoad method as we do not fetch names everytime
        // or fetch when a new member is added
        let phnNum = (pickerDataSource[row] as PFUser).username
        
        let contact = contacts.first { (c) -> Bool in
            c.phoneNumbers.contains(where: { (p) -> Bool in
                Utilities.getContactPlainPhnNum(number: p.value.stringValue) == phnNum
            })
        }
        
        return contact != nil ? Utilities.getContactGivenName(cnConatct: contact) : phnNum
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let nextTurnMember = pickerDataSource[row]
        
        if let task = currentTask{
            task["NextTurnMember"] = nextTurnMember
            task.saveEventually()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 54
    }
    
    func clearTaskDetails(){
        //txtTaskName.text = ""
        txtTaskDescription.text = ""
        lblNextTurn.text = "Next Turn: "
        pickerDataSource.removeAll()
        
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
