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

class TaskViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate {
    
    var currentTask:PFObject?
    var pickerDataSource = [PFUser]()
    var contacts = [CNContact]()
    var selectedMemberTitle:String = ""

    @IBOutlet weak var nextTurnTxtField: UITextField!
    @IBOutlet weak var txtTaskName: UILabel!
    @IBOutlet weak var lblNextTurn: UILabel!
    @IBOutlet weak var membersPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TaskViewController.dismissPickerAndKb))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        self.membersPickerView.dataSource = self;
        self.membersPickerView.delegate = self;
        self.membersPickerView.showsSelectionIndicator = true
        navigationController?.delegate = self
        
        membersPickerView.removeFromSuperview()
        nextTurnTxtField.inputView = membersPickerView
        
        contacts = Utilities.loadContacts()
        
        clearTaskDetails()
        
        if(currentTask != nil && !(currentTask?.objectId?.isEmpty)!){
            title = currentTask?["Name"]! as? String
            
            // todo: async
            if let nextTurnPhnNum = currentTask?["NextTurnUserName"] as? String {
                selectedMemberTitle = Utilities.getContactNameFromPhnNum(phnNum: nextTurnPhnNum)
                nextTurnTxtField.text = selectedMemberTitle != "" ? selectedMemberTitle : ""
            }
            
            loadMembers()
            //lblNextTurn.text = "Next turn: " + selectedMemberTitle
        }
    }
    
    func dismissPickerAndKb() {
        view.endEditing(false)
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
        
        
        query.getFirstObjectInBackground(block: { (task, error) in
            if(error == nil && task != nil){
                self.pickerDataSource = task?["Members"] as! [PFUser]
                let nextTurnMemberIndex = self.getAndSelectCurrentNextTurnMember()
                DispatchQueue.main.async {
                    self.membersPickerView.reloadAllComponents()
                    if let index = nextTurnMemberIndex{
                        self.membersPickerView.selectRow(index, inComponent: 0, animated: true)
                    }
                    else if self.pickerDataSource.count > 0{
                        self.membersPickerView.selectRow(0, inComponent: 0, animated: true)
                    }
                }
            }
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == nextTurnTxtField){
            return false
        }
        return true
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
        
        // do we need to fetch it everytime?
        let phnNum = (pickerDataSource[row] as PFUser).username
        let x = Utilities.getContactNameFromPhnNum(phnNum: phnNum!)
        return x
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let nextTurnMember = pickerDataSource[row]
        
        if let task = currentTask{
            setSelectedRowTitle()
            task["NextTurnMember"] = nextTurnMember
            task["NextTurnUserName"] = nextTurnMember.username
            task.saveEventually()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 54
    }
    
    func clearTaskDetails(){
        //lblNextTurn.text = "Next Turn: "
        pickerDataSource.removeAll()
        nextTurnTxtField.text = ""
    }
    
    func setSelectedRowTitle(){
        let selectedRow = membersPickerView.selectedRow(inComponent: 0)
        selectedMemberTitle = pickerView(membersPickerView, titleForRow: selectedRow, forComponent: 0)!
        //lblNextTurn.text = "Next Turn: " + selectedMemberTitle
        nextTurnTxtField.text = selectedMemberTitle
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool){
        if(!selectedMemberTitle.isEmpty){
            (viewController as? TasksTableVC)?.selectedTaskNextUserName = selectedMemberTitle
        }
    }
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        
    }

}
