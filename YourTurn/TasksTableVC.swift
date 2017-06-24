//
//  TasksTableVC.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/3/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import ContactsUI
import Parse

class TasksTableVC: UITableViewController {
    
    
    var tasks = [PFObject]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // ###################### WILL NEED TO INSERT TASKS IN TABLE- After Save btnCick ##########
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = true
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        loadTasksInDetail(refreshCtrl: false)
        
        setupRefreshControl()
    }
    
    
    
    func setupRefreshControl(){
        self.refreshControl?.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(TasksTableVC.refresh), for: UIControlEvents.valueChanged)
    }
    
    
    func refresh(sender:AnyObject) {
        
        loadTasksInDetail(refreshCtrl: true)
    }
    
    func loadTasksInDetail(refreshCtrl: Bool){
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: (PFUser.current()?.objectId)!)
        query?.includeKey("Tasks")
        
        query?.getFirstObjectInBackground(block: { (u, error) in
            if(error == nil && u != nil){
                
                self.tasks = u?["Tasks"] as! [PFObject]
                
                if self.tasks.count > 0 {
                    self.tasks.sort(by: { (t1, t2) -> Bool in
                        t1.createdAt! > t2.createdAt!
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if(refreshCtrl){
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
        })
    }
    
    var selectedTaskNextUserName:String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        // call to super will auto deselect table rows
        super.viewWillAppear(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(selectedTaskCellRow >= 0){
            tasks[selectedTaskCellRow]["NextTurnUserName"] = selectedTaskNextUserName
            self.tableView.reloadRows(at: [IndexPath(row: selectedTaskCellRow, section: 0)], with: UITableViewRowAnimation.top)
        }
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
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "taskCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TasksTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TasksTableViewCell.")
        }
        
        let task = tasks[indexPath.row]
        cell.taskNameLbl.text = task["Name"] as? String
        
        let nextTurnUserName = task["NextTurnUserName"] as? String
        
        let backgroundQueue = DispatchQueue(label: "getContactNameFromPhnNum", qos: .background)
        backgroundQueue.async {
            let uName = (nextTurnUserName == nil || nextTurnUserName!.isEmpty) ? "" : Utilities.getContactNameFromPhnNum(phnNum: nextTurnUserName!)
            DispatchQueue.main.async(execute: { () -> Void in
                cell.taskWhosNextLbl.text = uName.isEmpty ? "Next turn: TBD" : "Next turn: " + uName
            })
        }
        
        // TDOD: Cache Image
        if let taskImage = task["DisplayImage"] as? PFFile {
            taskImage.getDataInBackground(block: { (imageData, error) in
                if (error == nil && imageData != nil) {
                    cell.taskImage.image = UIImage(data:imageData!)
                }
            })
        }else{
            
            cell.taskImage.image = UIImage(named: "EmptyTask.png")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    var selectedTaskCellRow:Int = -1
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTaskCellRow = indexPath.row
        performSegue(withIdentifier: "taskTableCellToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "taskTableCellToDetails" && selectedTaskCellRow >= 0 && selectedTaskCellRow < tasks.count){
            let taskVC = segue.destination as! TaskViewController
            taskVC.currentTask = tasks[selectedTaskCellRow]
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Leave"
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmTaskDeletion(indexPath: indexPath)
        }
    }
    
    func confirmTaskDeletion(indexPath: IndexPath){
        let alert = UIAlertController(title: "Leave Task", message: "Are you sure you want to leave this task group?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteTask(indexPath: indexPath)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            self.tableView.setEditing(false, animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteTask(indexPath: IndexPath){
        let taskToDelete = tasks[indexPath.row]
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        disassociateTaskFromUser(task: taskToDelete)
    }
    
    func disassociateTaskFromUser(task:PFObject){
        let currentUser = PFUser.current()
        currentUser?.remove(task, forKey: "Tasks")
        currentUser?.saveEventually()
        
        var params:[String : Any] = [:]
        params["taskId"] = task.objectId
        params["userId"] = currentUser?.objectId
        deleteUserFromTask(params: params)
    }
    
    func deleteUserFromTask(params:[String : Any]){
        PFCloud.callFunction(inBackground: "deleteUserFromTask", withParameters: params)
    }


    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        loadTasksInDetail(refreshCtrl: false)
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
}
