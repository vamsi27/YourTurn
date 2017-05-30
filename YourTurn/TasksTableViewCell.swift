//
//  TasksTableViewCell.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/3/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit

class TasksTableViewCell: UITableViewCell {

    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskNameLbl: UILabel!
    @IBOutlet weak var taskWhosNextLbl: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        taskImage.clipsToBounds = true
        taskImage.layer.cornerRadius = 54/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
