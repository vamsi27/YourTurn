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

class PhoneNumberSetupVC: UIViewController, UITextFieldDelegate, CountryPhoneCodePickerDelegate {
    
    @IBOutlet weak var textFieldCountry: UITextField!
    
    @IBOutlet weak var txtPhnNum: UITextField!
    
    @IBOutlet weak var txtCountryCode: UITextField!
    
    @IBOutlet weak var pickerViewCountry: CountryPicker!
    
    @IBOutlet weak var btnContinue: UIButton!
    
    override func viewDidLoad() {
        
                super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        
        
        btnContinue.isEnabled = false
        btnContinue.adjustsImageWhenDisabled = true
        
        pickerViewCountry.removeFromSuperview()
        
        textFieldCountry.delegate = self
        txtPhnNum.delegate = self
        
        // so that the cursor looks hidden
        textFieldCountry.tintColor = UIColor.clear
        
        textFieldCountry.inputView = pickerViewCountry
        
        
        
        pickerViewCountry.countryPhoneCodeDelegate = self
        let defaultCountry = pickerViewCountry.setCountry(code)
        
        textFieldCountry.text = defaultCountry?.name
        txtCountryCode.text = defaultCountry?.phoneCode
        
        addDoneButtonOnKeyboard()
        addDoneButtonOnCountryKeyboard()
        
        
        // uncomment below to start using
        //let phoneUtil = NBPhoneNumberUtil()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // so that country text field looks like readonly without being disabled or un-editable
        if (textField == textFieldCountry)
        {
            return false
        }
        
        if(textField == txtPhnNum){
            
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            
            btnContinue.isEnabled = newLength == 10
            
            return newLength <= 10
        }
        
        return true
    }
    
    
    // MARK: - CountryPhoneCodePicker Delegate
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String) {
        
        textFieldCountry.text = name
        txtCountryCode.text = phoneCode
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
    
    func addDoneButtonOnCountryKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(PhoneNumberSetupVC.doneButtonActionCountry))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.textFieldCountry.inputAccessoryView = doneToolbar
    }
    
    func doneButtonActionCountry() {
        self.textFieldCountry.resignFirstResponder()
    }
}

