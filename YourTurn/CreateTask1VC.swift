//
//  CreateTask1VC.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/7/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit

class CreateTask1VC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groupMembers = ["","","","","",""]

    @IBOutlet weak var groupMembersTbl: UITableView!
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        groupMembersTbl.delegate = self
        groupMembersTbl.dataSource = self
        
        /*
         // $$$$$ NOT WORKING $$$$
        // but it has a max height (6 rows) - after that it has to scroll
        groupMembersTbl.frame.size.height = CGFloat(groupMembers.count * 44)
         */
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
        return groupMembers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "groupMemberCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITableViewCell  else {
            fatalError("The dequeued cell is not an instance of TasksTableViewCell.")
        }
        cell.textLabel?.text = "Member " + "\(indexPath.row + 1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
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
