//
//  Utilities.swift
//  YourTurn
//
//  Created by Vamsi Punna on 5/14/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import Foundation
import ContactsUI
import libPhoneNumber_iOS

class Utilities{
    
    static var contacts = [CNContact]()
    static var phoneNumberUtil = NBPhoneNumberUtil.sharedInstance()
    static var countryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
    
    static func getContactFullName(cnConatct: CNContact?) -> String {
        if let contact = cnConatct{
        return contact.givenName.isEmpty ? contact.familyName : contact.givenName + " " + contact.familyName
        }
        return ""
    }
    
    static func getContactGivenName(cnConatct: CNContact?) -> String {
        if let contact = cnConatct{
            //print(contact.givenName.isEmpty ? contact.familyName : contact.givenName)
            return contact.givenName.isEmpty ? contact.familyName : contact.givenName
        }
        return ""
    }
    
    // TODO: convert this into an extension method
    static func getContactPlainPhnNum(number: String) -> String {
        if number.isEmpty {
            return ""
        }
        
        do{
            if let num = try phoneNumberUtil?.parse(number, defaultRegion: countryCode){
                // international std without formatting .... no leading zeroes as well
                return try phoneNumberUtil!.format(num, numberFormat: NBEPhoneNumberFormat.E164)
            }
        }catch {}
        
        return ""
    }
    
    static func isPhnNumValid(number: String)->Bool{
        do{
            if let num = try phoneNumberUtil?.parse(number, defaultRegion: countryCode){
                return phoneNumberUtil!.isValidNumber(num)
            }
        }catch {}
        return false
    }
    
    static func getCountryDialingCode(code: String) -> String? {
        let phoneCode: String? = "+\(phoneNumberUtil?.getCountryCode(forRegion: code) ?? 0)"
        return phoneCode
    }
    
    static func loadContacts() -> [CNContact]{
        if(contacts.count == 0 ){
            let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
            
            do {
                try CNContactStore().enumerateContacts(with: request) {
                    (contact, stop) in
                    
                    // Array containing all unified contacts from everywhere
                    if(contact.phoneNumbers.count > 0){
                        contacts.append(contact)
                    }
                }
                if self.contacts.count > 0{
                    self.contacts.sort(by: { (cn1, cn2) -> Bool in
                        return (cn1.givenName + cn1.familyName).lowercased() < (cn2.givenName + cn2.familyName).lowercased()
                    })
                }
            }
            catch {
                //print("unable to fetch contacts")
            }
        }
        return contacts
    }
    
    static func getContactNameFromPhnNum(phnNum: String) -> String{
        let contact = contacts.first { (c) -> Bool in
            c.phoneNumbers.contains(where: { (p) -> Bool in
                getContactPlainPhnNum(number: p.value.stringValue) == phnNum
            })
        }
        return contact != nil ? getContactGivenName(cnConatct: contact) : phnNum
    }
    
    static func createDummyContact(givenName: String, phnNum: String) -> CNContact{
        
        let formattedPhnNum = getContactPlainPhnNum(number: phnNum)
        let yourPhnNum = CNLabeledValue(label: CNLabelHome,value: CNPhoneNumber(stringValue: formattedPhnNum))
        
        let contactData = CNMutableContact()
        contactData.givenName = givenName
        contactData.phoneNumbers = [yourPhnNum]
        return contactData
    }
    
    static func createOKAlertMsg(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        return alert
    }
}
