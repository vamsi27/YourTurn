//
//  ViewController.swift
//  YourTurn
//
//  Created by Vamsi Punna on 3/26/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import Parse

class PhoneNumberSetupVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
}

