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
    var imageSelected:Bool = false
    var existingTask:PFObject?
    
    @IBOutlet weak var taskImageBtn: UIButton!
    @IBOutlet weak var taskNameTxtField: UITextField!
    @IBOutlet weak var groupMembersTbl: UITableView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupMembersTbl.delegate = self
        groupMembersTbl.dataSource = self
        
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
    
    func endEditing(){
        view.endEditing(true)
    }
    
    func setupTaskName(){
        if(existingTask != nil){
            taskNameTxtField.text = existingTask!["Name"] as? String
        }else{
            taskNameTxtField.text = ""
        }
    }
    
    func setupGroupMembers(){
        if groupMembers.count == 0 && existingTask == nil {
            let contactData = Utilities.createDummyContact(givenName: "You", phnNum: (PFUser.current()?.username)!)
            groupMembers.append(contactData)
            groupMembersTbl.reloadData()
        }
    }
    
    func setupTaskImageBtn(){
        taskImageBtn.clipsToBounds = true
        taskImageBtn.layer.cornerRadius = 45
        taskImageBtn.layer.borderWidth = 1
        taskImageBtn.layer.borderColor = UIColor.gray.cgColor
        taskImageBtn.titleLabel!.lineBreakMode = .byWordWrapping
        taskImageBtn.titleLabel!.textAlignment = .center
        taskImageBtn.setTitle("add\nphoto", for: .normal)
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
        let conactName = Utilities.getContactFullName(cnConatct: contact)
        let contactPhnNum = contact.phoneNumbers[0].value.stringValue
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GroupMemberTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TasksTableViewCell.")
        }
        cell.conatctNameLbl.text = conactName
        cell.contactPhnNumLbl.text = contactPhnNum
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // contacts list passes contact only with selected# if contact has multiple, so check only for 0 index
    @IBAction func unwindToCreateTask(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CreateTaskVC, let selectedContact = sourceViewController.selectedContact, let selectedPhnNum = sourceViewController.selectedPhnNum {
            
            // do not add selectedContact directly, or else we wouldn't know which num was selected
            let contactData = Utilities.createDummyContact(givenName: Utilities.getContactGivenName(cnConatct: selectedContact), phnNum: selectedPhnNum)
            
            groupMembers.append(contactData)
            groupMembersTbl.reloadData()
        }
    }
    
    @IBAction func createTaskAction(_ sender: Any) {
        // Create Task here
        createTask()
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
        
        let task = PFObject(className:"Task")
        task["Name"] = taskNameTxtField.text!
        
        if(self.taskImageBtn.backgroundImage(for: UIControlState.normal) != nil && imageSelected){
            let imageData = UIImagePNGRepresentation(self.taskImageBtn.backgroundImage(for: UIControlState.normal)!)
            let imageFile = PFFile(name:"taskImage.png", data:imageData!)
            
            // TODO: Compress image to a reasonable size
            task["DisplayImage"] = imageFile
        }
        
        task["Admin"] = PFUser.current()
        
        // adding only cuurent user to task's members list
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
                        params["tskId"] = task.objectId
                        self.addMemebersToTheTask(params: params)

                        self.endEditing()
                        self.performSegue(withIdentifier: "unwindToCreateTaskList", sender: self)
                    }
                }}
            return nil
        })
    }
    
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
