//
//  Utilities.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/14/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import Foundation
import ContactsUI

class Utilities{
    static func getContactFullName(cnConatct: CNContact?) -> String {
        
        
        if let contact = cnConatct{
        
        return contact.givenName.isEmpty ? contact.familyName : contact.givenName + " " + contact.familyName
        }
        
        return ""
    }
}
