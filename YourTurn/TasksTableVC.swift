//
//  TasksTableVC.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/3/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import ContactsUI

class TasksTableVC: UITableViewController {
    
    
    var tasks = [Task]()

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // ###################### WILL NEED TO INSERT TASKS IN TABLE- After Save btnCick ##########
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        loadTasks()
        
        setupRefreshControl()
    }
    
    func setupRefreshControl(){
        
        // UITableViewController has a defualt refresh control so no need to create it again
        // But you will need to /Users/vmzi/Documents/iOS Apps/YourTurn/YourTurn/TasksTableVC.swiftdeclare if you are trying to attach the refresh to a table view
        
        self.refreshControl?.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(TasksTableVC.refresh), for: UIControlEvents.valueChanged)
        
        // below line is not required when using UITableViewController
        //tableView.addSubview(refreshControl)
    }
    
    
    func refresh(sender:AnyObject) {
        
        loadTasks()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func loadTasks(){
        
        // get pfuser.current().taskIds
        // fetch tasks based upon these taskids
        
        let t1 = Task(name:"Clear Trash", description:"", displayImage: nil)
        let t2 = Task(name:"Mop Kitchen Floor", description:"", displayImage: nil)
        let t3 = Task(name:"Pay Rent", description:"", displayImage:nil)
        
        tasks.append(t1!)
        tasks.append(t2!)
        tasks.append(t3!)
        
    }
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        print("mytasks view will appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("mytasks view appeared")
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

        cell.taskImage.image = UIImage(named: "\((indexPath.row + 1) % 3)" + ".jpg")
        cell.taskNameLbl.text = task.name
        cell.taskWhosNextLbl.text = "Next turn: TBD"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "taskTableCellToDetails", sender: self)
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
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
