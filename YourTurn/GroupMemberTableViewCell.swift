//
//  GroupMemberTableViewCell.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/9/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit

class GroupMemberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactPhnNumLbl: UILabel!
    @IBOutlet weak var conatctNameLbl: UILabel!
    
    @IBOutlet weak var btnRemoveMember: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
