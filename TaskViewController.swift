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

class TaskViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var currentTask:PFObject?
    var pickerDataSource = [PFUser]()
    var titles = [String]()
    var contacts = [CNContact]()
    var selectedMemberTitle:String = ""
    var isTasksTableReloadRequired = false
    var currentSelectedRow = -1

    @IBOutlet weak var btnSendReminder: UIButton!
    @IBOutlet weak var nextTurnTxtField: UITextField!
    @IBOutlet weak var txtTaskName: UILabel!
    @IBOutlet weak var lblNextTurn: UILabel!
    @IBOutlet weak var membersPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextTurnTxtField.delegate = self
        nextTurnTxtField.setBottomBorder()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TaskViewController.dismissPickerAndKb))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        btnSendReminder.isEnabled = false
        
        self.membersPickerView.dataSource = self;
        self.membersPickerView.delegate = self;
        self.membersPickerView.showsSelectionIndicator = true
        navigationController?.delegate = self
        
        membersPickerView.removeFromSuperview()
        nextTurnTxtField.inputView = membersPickerView
        
        contacts = Utilities.getContacts()
        
        clearTaskDetails()
        
        if(currentTask != nil && !(currentTask?.objectId?.isEmpty)!){
            title = currentTask?["Name"]! as? String
            print(title ?? "ezy")
            if let nextTurnPhnNum = currentTask?["NextTurnUserName"] as? String {
                selectedMemberTitle = Utilities.getContactNameFromPhnNum(phnNum: nextTurnPhnNum)
                nextTurnTxtField.text = selectedMemberTitle != "" ? selectedMemberTitle.uppercased() : ""
                updateSendReminderBtnState(phnNum: nextTurnPhnNum)
            }
            loadMembers()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == nextTurnTxtField){
            currentSelectedRow = membersPickerView.selectedRow(inComponent: 0)
        }
    }
    
    func updateSendReminderBtnState(phnNum: String){
        btnSendReminder.isEnabled = phnNum != PFUser.current()?.username
    }
    
    func loadMembers(){
        let query = PFQuery(className: "Task")
        query.whereKey("objectId", equalTo: currentTask!.objectId!)
        query.includeKey("Members")
        query.includeKey("NextTurnMember")
        query.includeKey("Admin")
        
        query.getFirstObjectInBackground(block: { (task, error) in
            if(error == nil && task != nil){
                self.currentTask = task
                
                // sort as per the names in the client's contacts book
                // it's not necessary that the other users will have the same order as they can save the names differently
                var sortedContacts = task?["Members"] as! [PFUser]
                sortedContacts.sort(by: { (user1, user2) -> Bool in
                    let u1Name = Utilities.getContactNameFromPhnNum(phnNum: user1.username!)
                    let u2Name = Utilities.getContactNameFromPhnNum(phnNum: user2.username!)
                    
                    return u1Name <= u2Name
                })
                self.pickerDataSource = sortedContacts
                
                self.loadTitles()
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
    
    func loadTitles(){
        self.pickerDataSource.forEach { (user) in
            titles.append(Utilities.getContactNameFromPhnNum(phnNum: user.username!))
        }
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
        if(row >= 0 && row < titles.count){
            return titles[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if(currentSelectedRow == row && nextTurnTxtField.text != ""){
            return
        }
        let nextTurnMember = pickerDataSource[row]
        if let task = currentTask{
            setSelectedRowTitle()
            task["NextTurnMember"] = nextTurnMember
            task["NextTurnUserName"] = nextTurnMember.username
            task.saveEventually()
            updateSendReminderBtnState(phnNum: nextTurnMember.username!)
            notifyUser(userName: nextTurnMember.username!, isReminder: false)
        }
    }
    
    @IBAction func btnSendReminderAction(_ sender: UIButton) {
        currentSelectedRow = membersPickerView.selectedRow(inComponent: 0)
        if(currentSelectedRow > -1){
            let nextTurnMember = pickerDataSource[currentSelectedRow]
            notifyUser(userName: nextTurnMember.username!, isReminder: true)
            let alert = Utilities.createOKAlertMsg(title: "", message: (nextTurnTxtField.text ?? "Member") + " has been reminded!")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func notifyUser(userName: String, isReminder: Bool){
        // Do not notify the same user
        if(PFUser.current()?.username == userName){
            return
        }
        
        var params:[String : Any] = [:]
        params["username"] = userName
        params["taskName"] = currentTask?["Name"]
        params["isReminder"] = isReminder ? 1 : 0
        
        PFCloud.callFunction(inBackground: "sendNotification", withParameters: params){ (response, error) in
            if error == nil {
                print("Sent notification")
            } else {
                // TODO: show alert
                print("Error - couldn't send notification")
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 54
    }
    
    func clearTaskDetails(){
        pickerDataSource.removeAll()
        nextTurnTxtField.text = ""
        titles.removeAll()
    }
    
    func setSelectedRowTitle(){
        let selectedRow = membersPickerView.selectedRow(inComponent: 0)
        currentSelectedRow = selectedRow
        selectedMemberTitle = pickerView(membersPickerView, titleForRow: selectedRow, forComponent: 0)!
        print(selectedMemberTitle.capitalized)
        nextTurnTxtField.text = selectedMemberTitle.uppercased()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool){
        if(type(of: TasksTableVC()) == type(of: viewController) && (!selectedMemberTitle.isEmpty || isTasksTableReloadRequired)){
            (viewController as? TasksTableVC)?.selectedTaskNextUserName = selectedMemberTitle
            (viewController as? TasksTableVC)?.isReloadRequired = isTasksTableReloadRequired
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "sbGoToSettingsScreen"){
            let navController = segue.destination as! UINavigationController
            let destination = navController.topViewController as! CreateTask1VC
            destination.existingTask = currentTask
        }
    }
    
    @IBAction func unwindToTaskVCFromSettings(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CreateTask1VC, let existingTask = sourceViewController.existingTask {
            isTasksTableReloadRequired = true
            currentTask = existingTask
            viewDidLoad()
        }
        
    }

}
