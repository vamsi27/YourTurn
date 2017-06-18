//
//  AppDelegate.swift
//  YourTurn
//
//  Created by Vamsi Punna on 3/26/17.
//  Copyright © 2017 Vamsi Punna. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // ****************************************************************************
        // Initialize Parse SDK
        // ****************************************************************************
        
        let configuration = ParseClientConfiguration {
            
            $0.applicationId = "yourTurn3262017"
            
            $0.server = "https://your-turn.herokuapp.com/parse"
            
            // Enable storing and querying data from Local Datastore.
            // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
            //$0.isLocalDatastoreEnabled = true
        }
        Parse.initialize(with: configuration)
        
        if(PFUser.current() != nil){
            //PFUser.logOut()
            DispatchQueue.main.async() {
                _ = Utilities.loadContacts()
            }
        }
        
        if(PFUser.current() == nil){
            setUpInitialViewController(viewIdentifier: "sbLogInNavCtrler")
        }
        else{
            setUpInitialViewController(viewIdentifier: "sbLoggedInNavCtrler")
        }
        
        setupNavigationBarStyling()
        
        
        return true
    }
    
    func setupNavigationBarStyling(){
        //0091FF
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0, green: 145/255, blue: 255/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]

        
    }
    
    func setUpInitialViewController(viewIdentifier: String){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: viewIdentifier)
        
        self.window?.rootViewController = initialViewController
        //self.window?.makeKeyAndVisible()
        
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

