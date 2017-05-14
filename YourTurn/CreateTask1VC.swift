//
//  CreateTask1VC.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/7/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import ContactsUI

class CreateTask1VC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groupMembers = [CNContact]()

    @IBOutlet weak var groupMembersTbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupMembersTbl.delegate = self
        groupMembersTbl.dataSource = self
        
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
        
        
        heightConst?.constant = CGFloat(groupMembers.count * 44)

        groupMembersTbl.contentOffset = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
        
        return groupMembers.count
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "groupMemberCell"
        
        let contact = groupMembers[indexPath.row]
        let conactName = Utilities.getContactFullName(cnConatct: contact)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UITableViewCell  else {
            fatalError("The dequeued cell is not an instance of TasksTableViewCell.")
        }
        cell.textLabel?.text = conactName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    @IBAction func unwindToCreateTask(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CreateTaskVC, let selectedContact = sourceViewController.selectedContact {
                groupMembers.append(selectedContact)
                groupMembersTbl.reloadData()
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
