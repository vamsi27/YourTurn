//
//  ViewController.swift
//  YourTurn
//
//  Created by Vamsi Punna on 3/26/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import Parse
import libPhoneNumber_iOS

class PhoneNumberSetupVC: UIViewController {
    
    
    @IBOutlet weak var txtPhnNum: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addDoneButtonOnKeyboard()
        
        // uncomment below to start using
        //let phoneUtil = NBPhoneNumberUtil()
        
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //isTranslucent - true set in sb
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    var confirmCodeViewController:ConfirmCodeVC?
    
    @IBAction func continueToConfirmCodeAction(_ sender: Any) {
        
        let params = ["phoneNumber":txtPhnNum.text!] as [String : Any]
        
        PFCloud.callFunction(inBackground: "sendVerificationCode", withParameters: params){ (response, error) in
            if error == nil {
                self.confirmCodeViewController?.serverConfCode = response as! Int
                
            } else {
                print("Send code failed")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seguePhnSetupToConfirm") {
            confirmCodeViewController = (segue.destination as? ConfirmCodeVC)
        }
    }
    
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(PhoneNumberSetupVC.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.txtPhnNum.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.txtPhnNum.resignFirstResponder()
    }
}

