//
//  ConfirmCodeVC.swift
//  YourTurn
//
//  Created by Vamsi Punna on 4/17/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit

class ConfirmCodeVC: UIViewController, UITextFieldDelegate {
    
    var serverConfCode = 0
    
    @IBOutlet weak var btnConfirmCode: UIButton!
    @IBOutlet weak var txtFieldConfCode: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        btnConfirmCode.isEnabled = false
        txtFieldConfCode.delegate = self
        
        addDoneButtonOnKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == txtFieldConfCode){
            
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            
            btnConfirmCode.isEnabled = newLength == 5
            
            return newLength <= 5
        }
        
        return true
    }
    
    @IBAction func btnConfirmCode(_ sender: Any) {
        
        print("Server code - \(serverConfCode)")
        print("Entered code - " + txtFieldConfCode.text!)
        
        if("\(serverConfCode)" == txtFieldConfCode.text){
            let controllerId = "sbLoggedInNavCtrler";
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: controllerId) as UIViewController
            self.present(initViewController, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Error!", message: "Invalid code entered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
        
        self.txtFieldConfCode.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.txtFieldConfCode.resignFirstResponder()
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
