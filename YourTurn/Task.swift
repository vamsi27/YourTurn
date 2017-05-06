//
//  Task.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/6/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import Parse

class Task {
    
    //MARK: Properties
    
    var name: String
    var description: String?
    var displayImage: UIImage?
    
    //MARK: Initialization
    
    init?(name: String, description: String?, displayImage: UIImage?) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.displayImage = displayImage
        self.description = description
        
    }
}

