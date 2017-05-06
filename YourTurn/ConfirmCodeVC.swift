//
//  ConfirmCodeVC.swift
//  YourTurn
//
//  Created by Vamsi Punna on 4/17/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import Parse

class ConfirmCodeVC: UIViewController, UITextFieldDelegate {
    
    var serverConfCode = 0
    var fullphoneNumer = ""
    
    @IBOutlet weak var btnConfirmCode: UIButton!
    @IBOutlet weak var txtFieldConfCode: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        btnConfirmCode.isEnabled = false
        txtFieldConfCode.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConfirmCodeVC.dismissKb))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKb(){
        view.endEditing(false)
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
            self.UserLoginOrSignUp()
        }
        else{
            
            self.showOKAlertMsg(title: "Error", message: "Invalid code entered")
        }
    }
    
    func UserLoginOrSignUp() -> Void {
        let query = PFUser.query() // or PFQuery(className: "_User") // observe the underscore
        query?.whereKey("username", equalTo: fullphoneNumer)
        query?.findObjectsInBackground{
            (users: [PFObject]?, error: Error?) -> Void in
            if error == nil && users != nil && (users?.count)! > 0 {
                
                let user = users?[0] as! PFUser
                let userName = user.username!
                
                
                self.loginUser(userName: userName)
            } else {
                self.signUpUser()
            }
        }
    }
    
    func loginUser(userName: String){
        
        let loginTask = PFUser.logInWithUsername(inBackground: userName, password: userName)
        
        loginTask.continue({_ in
            if PFUser.current() != nil {
                self.proceedToMyTasks()
            } else {
                self.showOKAlertMsg(title: "Error", message: "Unable to login. Please try again.")
            }
            return nil
        })
    }
    
    func signUpUser() {
        let user = PFUser()
        user.username = fullphoneNumer
        user.password = fullphoneNumer
        user["displayName"] = "You"
        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
                self.showOKAlertMsg(title: "Error", message: "Unable to sign up. Please try again.")
                print(error)
            } else {
                self.proceedToMyTasks()
            }
        }
    }
    
    func proceedToMyTasks(){
        
        let controllerId = "sbLoggedInNavCtrler";
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: controllerId) as UIViewController
        self.present(initViewController, animated: true, completion: nil)
        
    }
    
    func showOKAlertMsg(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
