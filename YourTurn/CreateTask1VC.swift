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

class CreateTask1VC: UIViewController, UITableViewDelegate, UITableViewDataSource, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
    
    var groupMembers = [CNContact]()
    
    @IBOutlet weak var taskImageBtn: UIButton!
    @IBOutlet weak var taskNameTxtField: UITextField!
    @IBOutlet weak var groupMembersTbl: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupMembersTbl.delegate = self
        groupMembersTbl.dataSource = self
        taskImageBtn.clipsToBounds = true
        taskImageBtn.layer.cornerRadius = 45
        
        if groupMembers.count == 0 {
            
            let yourPhnNum = CNLabeledValue(label: CNLabelHome,value: CNPhoneNumber(stringValue: (PFUser.current()?.username)!))
            
            let contactData = CNMutableContact()
            contactData.givenName = "You"
            
            contactData.phoneNumbers = [yourPhnNum]
            groupMembers.append(contactData)
            groupMembersTbl.reloadData()
            
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateTask1VC.endEditing))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
    }
    
    func endEditing(){
        view.endEditing(true)
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
    
    @IBAction func unwindToCreateTask(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CreateTaskVC, let selectedContact = sourceViewController.selectedContact {
            groupMembers.append(selectedContact)
            groupMembersTbl.reloadData()
        }
    }
    
    @IBAction func createTaskAction(_ sender: Any) {
        // Create Task here
        createTask()
    }
    
    func createTask(){
        
        
        var params:[String : Any] = [:]
        var members:[String] = []
        
        for member in groupMembers {
            var uName = member.phoneNumbers[0].value.stringValue.replacingOccurrences(of: " ", with: "")
            uName = uName.replacingOccurrences(of: "(", with: "")
            uName = uName.replacingOccurrences(of: ")", with: "")
            uName = uName.replacingOccurrences(of: "-", with: "")
            print(uName)
            members.append(uName)
        }
        
        params["tskMembers"] = members
        
        let task = PFObject(className:"Task")
        task["Name"] = taskNameTxtField.text!
        
        if(self.taskImageBtn.backgroundImage(for: UIControlState.normal) != nil){
            let imageData = UIImagePNGRepresentation(self.taskImageBtn.backgroundImage(for: UIControlState.normal)!)
            let imageFile = PFFile(name:"taskImage.png", data:imageData!)
            task["DisplayImage"] = imageFile
        }
        
        task["Admin"] = PFUser.current()
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
                        //self.showOKAlertMsg(title: "Error", message: "Unable to sign up. Please try again.")
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
                print(error ?? "zzz")
            }
        }
    }
    
    @IBAction func taskImageAction(_ sender: Any) {
        
        let image = UIImage(named: "sjobs.png")
        let imageCropVC = RSKImageCropViewController(image: image!)
        imageCropVC.delegate = self
        navigationController?.pushViewController(imageCropVC, animated: true)
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
        //imageView?.image = croppedImage
        taskImageBtn.setBackgroundImage(croppedImage, for: UIControlState.normal)
        navigationController?.popViewController(animated: true)
    }
    
    // The original image will be cropped.
    
    //  The converted code is limited by 1 KB.
    //  Please Sign Up (Free!) to remove this limitation.
    
    //  Converted with Swiftify v1.0.6341 - https://objectivec2swift.com/
    // Returns a custom rect for the mask.
    
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

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
