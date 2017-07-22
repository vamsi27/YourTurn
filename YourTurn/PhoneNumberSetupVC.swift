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

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}


class PhoneNumberSetupVC: UIViewController, UITextFieldDelegate, CountryPhoneCodePickerDelegate {
    
    @IBOutlet weak var txtFieldCode: UITextField!
    @IBOutlet weak var txtFlagImage: UITextField!
    @IBOutlet weak var txtPhnNum: UITextField!
    @IBOutlet weak var pickerViewCountry: CountryPicker!
    @IBOutlet weak var btnContinue: UIButton!
    var txtCountryCode:String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhoneNumberSetupVC.dismissPickerAndKb))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        
        btnContinue.isEnabled = false
        btnContinue.adjustsImageWhenDisabled = true
        
        pickerViewCountry.removeFromSuperview()
        
        txtPhnNum.delegate = self
        
        txtFlagImage.borderStyle = UITextBorderStyle.none
        txtFlagImage.delegate = self
        txtFlagImage.inputView = pickerViewCountry
        
        pickerViewCountry.countryPhoneCodeDelegate = self
        let defaultCountry = pickerViewCountry.setCountry(code)
        
        setCountryFlagToButton(code: code)
        txtCountryCode = (defaultCountry?.phoneCode)!
        txtFieldCode.text = txtCountryCode
        
        txtFieldCode.setBottomBorder()
        txtPhnNum.setBottomBorder()
    }
    
    func dismissPickerAndKb() {
        view.endEditing(false)
    }
    
    func setCountryFlagToButton(code: String){
        let btnImage = UIImage(named: code.lowercased())
        txtFlagImage.background = btnImage
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == txtFlagImage){
            return false
        }
        
        if(textField == txtPhnNum){
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            btnContinue.isEnabled = newLength >= 10
            
            return newLength <= 10 && !txtCountryCode.isEmpty
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        btnContinue.isEnabled = false
        return true
    }
    
    
    // MARK: - CountryPhoneCodePicker Delegate
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String) {
        setCountryFlagToButton(code: countryCode)
        txtCountryCode = phoneCode
        txtFieldCode.text = txtCountryCode
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.        
    }
    
    var confirmCodeViewController:ConfirmCodeVC?
    
    @IBAction func continueToConfirmCodeAction(_ sender: Any) {
        
        let fullPhnNum = txtCountryCode + txtPhnNum.text!
        let params = ["phoneNumber":fullPhnNum] as [String : Any]
        
        PFCloud.callFunction(inBackground: "sendVerificationCode", withParameters: params){ (response, error) in
            if error == nil {
                print("###############\(response as! Int)##################")
                self.confirmCodeViewController?.serverConfCode = response as! Int
                self.confirmCodeViewController?.fullphoneNumer = fullPhnNum
                
            } else {
                print("Send code failed")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seguePhnSetupToConfirm") {
            confirmCodeViewController = (segue.destination as? ConfirmCodeVC)
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
}

