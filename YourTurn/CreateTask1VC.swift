//
//  CreateTask1VC.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/7/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import ContactsUI
import Parse
import RSKImageCropper
import DKImagePickerController
import libPhoneNumber_iOS


class CreateTask1VC: UIViewController, UITableViewDelegate, UITableViewDataSource, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
    
    var groupMembers = [CNContact]()
    var initialGroupMembersOnSettingsScreen = [CNContact]()
    var imageSelected:Bool = false
    var existingTask:PFObject?
    var initialMembersCountOnSettingsScreen = -1
    
    @IBOutlet weak var taskImageBtn: UIButton!
    @IBOutlet weak var taskNameTxtField: UITextField!
    @IBOutlet weak var groupMembersTbl: UITableView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    var isCurrentUserAdmin = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupMembersTbl.delegate = self
        groupMembersTbl.dataSource = self
        
        // precautionary check so that if settings screen is opened even before the task is fully loaded in the background in the previous view
        fetchIfNeededForExistingTask()
        
        isCurrentUserAdmin = isCurrentUserTheAdmin()
        setupTaskName()
        setupTaskImageBtn()
        setupGroupMembers()
        setupRightBarButton()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateTask1VC.endEditing))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func fetchIfNeededForExistingTask(){
        if(existingTask == nil){
            return
        }
        
        let admin = existingTask?["Admin"] as! PFObject
        do{
            try admin.fetchIfNeeded()
        }catch{
        }
        let members = existingTask?["Members"] as! [PFUser]
        members.forEach { (member) in
            do{
                try member.fetchIfNeeded()
            }catch{
            }
        }
    }
    
    func endEditing(){
        view.endEditing(true)
    }
    
    func isCurrentUserTheAdmin() -> Bool {
        if(existingTask == nil){
            return true
        }
        return (existingTask?["Admin"] as! PFUser).objectId == PFUser.current()?.objectId
    }
    
    func setupTaskName(){
        taskNameTxtField.setBottomBorder()
        
        if(existingTask != nil){
            taskNameTxtField.text = existingTask!["Name"] as? String
        }else{
            taskNameTxtField.text = ""
        }
    }
    
    func setupGroupMembers(){
        if groupMembers.count == 0 && existingTask == nil {
            initialMembersCountOnSettingsScreen = -1
            initialGroupMembersOnSettingsScreen.removeAll()
            let contactData = Utilities.createDummyContact(givenName: "You", phnNum: (PFUser.current()?.username)!)
            groupMembers.append(contactData)
            groupMembersTbl.reloadData()
        }else if existingTask != nil {
            let members = existingTask?["Members"] as! [PFUser]
            members.forEach({ (member) in
                let c = Utilities.createDummyContact(phnNum: member.username!)
                groupMembers.append(c)
            })
            initialMembersCountOnSettingsScreen = groupMembers.count
            initialGroupMembersOnSettingsScreen = groupMembers
            groupMembersTbl.reloadData()
        }
    }
    
    func setupTaskImageBtn(){
        taskImageBtn.clipsToBounds = true
        taskImageBtn.layer.cornerRadius = taskImageBtn.layer.frame.width/2
        taskImageBtn.layer.borderWidth = 1
        taskImageBtn.layer.borderColor = UIColor.lightGray.cgColor
        taskImageBtn.titleLabel!.lineBreakMode = .byWordWrapping
        taskImageBtn.titleLabel!.textAlignment = .center
        taskImageBtn.setTitle("add\nphoto", for: .normal)
        
        if existingTask != nil {
            if let taskImage = existingTask?["DisplayImage"] as? PFFile {
                taskImage.getDataInBackground(block: { (imageData, error) in
                    if (error == nil && imageData != nil) {
                        let image = UIImage(data:imageData!)
                        self.taskImageBtn.setBackgroundImage(image, for: UIControlState.normal)
                        self.taskImageBtn.setTitle("", for: .normal)
                        self.imageSelected = true
                    }
                })
            }
        }
    }
    
    func setupRightBarButton(){
        rightBarButtonItem.title = existingTask != nil ? "Save" : "Create"
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        endEditing()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let heightConst = groupMembersTbl.constraints.first(where: { (x) -> Bool in
            x.firstAttribute == NSLayoutAttribute.height
        })
        
        heightConst?.constant = CGFloat(groupMembers.count * 60)
        groupMembersTbl.contentOffset = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
        return groupMembers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "groupMemberCell"
        
        let contact = groupMembers[indexPath.row]
        let conactName = Utilities.getFullNameFromContact(cnConatct: contact)
        let contactPhnNum = contact.phoneNumbers[0].value.stringValue
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GroupMemberTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TasksTableViewCell.")
        }
        
        cell.conatctNameLbl.text = conactName
        
        if(conactName != contactPhnNum){
            cell.contactPhnNumLbl.text = contactPhnNum
        }
        cell.btnRemoveMember.isHidden = !isCurrentUserAdmin
        cell.btnRemoveMember.tag = indexPath.row
        cell.btnRemoveMember.addTarget(self, action: #selector(deleteGroupMember), for: .touchDown)
        
        return cell
    }
    
    func deleteGroupMember(_ sender: Any){
        let btn = sender as! UIButton
        let indexPath = IndexPath(row: btn.tag, section: 0)
        
        groupMembers.remove(at: indexPath.row)
        groupMembersTbl.reloadData()
        // below line was causing entire table to flash
        //groupMembersTbl.deleteRows(at: [indexPath], with: .none)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // a non-admin should be able to remove the member added by him/her on the settings screen
        return existingTask == nil || isCurrentUserAdmin || indexPath.row >= initialMembersCountOnSettingsScreen
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            groupMembers.remove(at: indexPath.row)
            groupMembersTbl.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // contacts list passes contact only with selected# if contact has multiple, so check only for 0 index
    @IBAction func unwindToCreateTask(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CreateTaskVC, let selectedContact = sourceViewController.selectedContact, let selectedPhnNum = sourceViewController.selectedPhnNum {
            
            // do not add selectedContact directly, or else we wouldn't know which num was selected
            let contactData = Utilities.createDummyContact(givenName: Utilities.getGivenNameFromContact(cnConatct: selectedContact), phnNum: selectedPhnNum)
            
            groupMembers.append(contactData)
            groupMembersTbl.reloadData()
        }
    }
    
    @IBAction func createTaskAction(_ sender: Any) {
        
        if(!validateTask()){
            return
        }
        
        if existingTask == nil{
            createTask()
        }else{
            updateTask()
        }
    }
    
    func validateTask() -> Bool {
        if(taskNameTxtField.text == nil || taskNameTxtField.text!.isEmpty){
            let alert = Utilities.createOKAlertMsg(title: "Task Name", message: "Hey, how about a name for your task?")
            present(alert, animated: true, completion: nil)
            return false
        }
        if(groupMembers.count == 0){
            let alert = Utilities.createOKAlertMsg(title: "Members?", message: "Come on, add at least one member to your task!")
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func updateTask(){
        
        self.endEditing()
        existingTask?["Name"] = taskNameTxtField.text!
        let displayImage = self.taskImageBtn.backgroundImage(for: UIControlState.normal)
        
        if(displayImage != nil && imageSelected){
            if let imageData = displayImage!.jpeg(.lowest) {
                print("size of image in KB: %f ", Double(NSData(data: imageData).length) / 1024.0)
                let imageFile = PFFile(name:"taskImage.jpg", data:imageData)
                existingTask?["DisplayImage"] = imageFile
            }
        }
        
        let bfTask = existingTask?.saveInBackground()
        
        bfTask?.continue({ (antecedent) -> Any? in
            
            if let res = antecedent.result?.boolValue {
                
                if res == false{
                    return nil
                }
                
                var params:[String : Any] = [:]
                params["taskId"] = self.existingTask?.objectId
                params["isNewTask"] = 0
                
                // get task members
                var addedMembers:[String] = []
                var removedMembers:[String] = []
                
                let addedContacts = self.groupMembers.filter({ (c) -> Bool in
                    !self.initialGroupMembersOnSettingsScreen.contains(c)
                })
                
                addedContacts.forEach({ (c) in
                    let uName = Utilities.getContactPlainPhnNum(number: c.phoneNumbers[0].value.stringValue)
                    
                    if(uName == PFUser.current()?.username){
                        // existingTask cannot be null at this point
                        PFUser.current()?.remove(self.existingTask!, forKey: "Tasks")
                        PFUser.current()?.saveEventually()
                    }
                    
                    addedMembers.append(uName)
                    print(uName)
                })
                
                // as only admin can delete members
                if self.isCurrentUserAdmin {
                    let removedContacts = self.initialGroupMembersOnSettingsScreen.filter({ (c) -> Bool in
                        !self.groupMembers.contains(c)
                    })
                    
                    removedContacts.forEach({ (c) in
                        let uName = Utilities.getContactPlainPhnNum(number: c.phoneNumbers[0].value.stringValue)
                        removedMembers.append(uName)
                        print(uName)
                    })
                }
                
                if(addedMembers.count > 0 || removedMembers.count > 0){
                    params["tskMembers"] = addedMembers
                    params["tskMembersRemoved"] = removedMembers
                    
                    PFCloud.callFunction(inBackground: "addMembersToTask", withParameters: params){ (response, error) in
                        if error == nil {
                            PFCloud.callFunction(inBackground: "deleteUserFromTask", withParameters: params){ (response, error) in
                                if error == nil {
                                    if (!removedMembers.contains(PFUser.current()!.username!)){
                                        self.performSegue(withIdentifier: "unwindToTaskVCFromSettings", sender: self)
                                    }else{
                                        self.performSegue(withIdentifier: "unwindToCreateTaskList", sender: self)
                                    }
                                } else {
                                    print("Error - couldn't remove members from the task")
                                }
                            }
                        } else {
                            // TODO: show alert
                            print("Error - couldn't add members to the task")
                        }
                    }
                }else{
                    // Only a name/pic change
                    self.performSegue(withIdentifier: "unwindToTaskVCFromSettings", sender: self)
                }
            }
            return nil
        })
    }
    
    // TODO: can be modified to be used for update as well
    func createTask(){
        
        var params:[String : Any] = [:]
        var members:[String] = []
        
        for member in groupMembers {
            let uName = Utilities.getContactPlainPhnNum(number: member.phoneNumbers[0].value.stringValue)
            members.append(uName)
        }
        
        params["tskMembers"] = members
        params["isNewTask"] = 1

        
        let task = PFObject(className:"Task")
        task["Name"] = taskNameTxtField.text!
        
        let displayImage = self.taskImageBtn.backgroundImage(for: UIControlState.normal)
        
        if(displayImage != nil && imageSelected){
            if let imageData = displayImage!.jpeg(.lowest) {
                print("size of image in KB: %f ", Double(NSData(data: imageData).length) / 1024.0)
                let imageFile = PFFile(name:"taskImage.jpg", data:imageData)
                task["DisplayImage"] = imageFile
            }
        }
        
        task["Admin"] = PFUser.current()
        
        // adding only current user to task's members list
        // Cloud code will take care of adding rest of the selected users to the task's members list
        // It will also take care of adding task to the user's tasks list
        task["Members"] = [PFUser.current()]
        
        let bfTask = task.saveInBackground()
        
        bfTask.continue({ (antecedent) -> Any? in
            
            if let res = antecedent.result?.boolValue {
                
                if res == false{
                    return nil
                }
                
                let currentUser = PFUser.current()
                
                currentUser?.add(task, forKey: "Tasks")
                
                currentUser?.saveInBackground {
                    (succeeded: Bool, error: Error?) -> Void in
                    if let error = error {
                        print(error)
                    } else {
                        // Cloud code to fetch other users (create accounts if required) and add to task
                        print(task.objectId!)
                        params["taskId"] = task.objectId
                        self.addMemebersToTheTask(params: params)
                        self.endEditing()
                        self.performSegue(withIdentifier: "unwindToCreateTaskList", sender: self)
                    }
                }}
            return nil
        })
    }
    
    // params -> "taskId", "Members" (usernames (E164 phnnums))
    func addMemebersToTheTask(params:[String : Any]){
        PFCloud.callFunction(inBackground: "addMembersToTask", withParameters: params){ (response, error) in
            if error == nil {                
            } else {
                // Couldn't add members to task
            }
        }
    }
    
    @IBAction func taskImageAction(_ sender: Any) {
        showSelectPhotoPopupMenu()
    }
    
    func showSelectPhotoPopupMenu(){
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.startPhotoPicker(useCamera: true)
        })
        
        let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.startPhotoPicker(useCamera: false)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(choosePhotoAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    func startPhotoPicker(useCamera:Bool){
        
        let pickerController = DKImagePickerController()
        pickerController.singleSelect = true
        pickerController.sourceType = useCamera ? .camera : .photo
        pickerController.assetType = .allPhotos
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            
            if (assets.count == 0){
                return
            }
            
            let asset = assets[0]
            
            //sync -> true (synchronous), false (asynchronous) to the completion block
            asset.fetchOriginalImage(true, completeBlock: { (selectedImage, info) in
                let imageCropVC = RSKImageCropViewController(image: selectedImage!)
                imageCropVC.delegate = self
                self.navigationController?.pushViewController(imageCropVC, animated: true)
            })
        }
        
        self.present(pickerController, animated: true) {
        }
    }
    
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    // The original image has been cropped.
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        taskImageBtn.setBackgroundImage(croppedImage, for: UIControlState.normal)
        navigationController?.popViewController(animated: true)
    }
    
    // The original image has been cropped. Additionally provides a rotation angle used to produce image.
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        imageSelected = true
        taskImageBtn.setTitle("", for: .normal)
        taskImageBtn.setBackgroundImage(croppedImage, for: UIControlState.normal)
        navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        var maskSize: CGSize
        if controller.isPortraitInterfaceOrientation() {
            maskSize = CGSize(width: CGFloat(250), height: CGFloat(250))
        }
        else {
            maskSize = CGSize(width: CGFloat(220), height: CGFloat(220))
        }
        let viewWidth: CGFloat = controller.view.frame.width
        let viewHeight: CGFloat = controller.view.frame.height
        let maskRect = CGRect(x: CGFloat((viewWidth - maskSize.width) * 0.5), y: CGFloat((viewHeight - maskSize.height) * 0.5), width: CGFloat(maskSize.width), height: CGFloat(maskSize.height))
        return maskRect
    }
    
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        let rect: CGRect = controller.maskRect
        let point1 = CGPoint(x: CGFloat(rect.minX), y: CGFloat(rect.maxY))
        let point2 = CGPoint(x: CGFloat(rect.maxX), y: CGFloat(rect.maxY))
        let point3 = CGPoint(x: CGFloat(rect.midX), y: CGFloat(rect.minY))
        let triangle = UIBezierPath()
        triangle.move(to: point1)
        triangle.addLine(to: point2)
        triangle.addLine(to: point3)
        triangle.close()
        return triangle
    }
    
    // Returns a custom rect in which the image can be moved.
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        // If the image is not rotated, then the movement rect coincides with the mask rect.
        return controller.maskRect
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "sbAddMemberSegue"){
            let navController = segue.destination as! UINavigationController
            let destination = navController.topViewController as! CreateTaskVC
            destination.existingGroupContacts = groupMembers
        }
    }
    
}
