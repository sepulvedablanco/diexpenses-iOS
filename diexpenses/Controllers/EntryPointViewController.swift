//
//  EntryPointViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 28/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss

class EntryPointViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        checkUserLoggedIn()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Extension for legacy operations
extension EntryPointViewController {
    
    // MARK: Check if the user is logged in. If so, redirect to HomeViewController else to LoginViewController
    func checkUserLoggedIn() {
        let prefs = NSUserDefaults.standardUserDefaults()
        let isLoggedIn = prefs.boolForKey(Constants.Session.IS_LOGGED_IN) as Bool
        if isLoggedIn {
            toHomeViewController()
            loadUserFromPrefs()
        } else {
            toLoginViewController()
        }
    }
    
    // MARK: Load user data from NSUserDefaults to memory if the user is logged in
    func loadUserFromPrefs() {
        let prefs = NSUserDefaults.standardUserDefaults()
        let userJson = prefs.valueForKey(Constants.Session.USER) as! JSON
        Diexpenses.user = User(json: userJson)
    }

    // MARK: Redirection to HomeViewController. This method is called if the user is logged in
    func toHomeViewController() {
        self.performSegueWithIdentifier(Constants.Segue.FROM_EPVC_TO_HOME_VC, sender: self)
    }

    // MARK: Redirection to LoginViewController. This method is called if the user is not logged in
    func toLoginViewController() {
        self.performSegueWithIdentifier(Constants.Segue.FROM_EPVC_TO_LOGIN_VC, sender: self)
    }
}