//
//  LoginViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 13/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss
import SwiftValidator

class LoginViewController: UIViewController {

    let customValidator = CustomValidator();

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    // MARK: Method called when user push Sign in button
    @IBAction func onSignIn() {
        Diexpenses.switchButton(signInButton)
        customValidator.validate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        initVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Extension for legacy operations
extension LoginViewController {
    
    // MARK: Initialize the View Controller
    func initVC() {
        setTextFieldsDelegate()
        registerFieldsInValidator()
    }
    
    // MARK: Set the user loaded in NSUserDefaults
    static func setUserInPrefs() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(true, forKey: Constants.Session.IS_LOGGED_IN)
        prefs.setObject(Diexpenses.user.toJSON(), forKey: Constants.Session.USER)
    }
    
    // MARK: Redirection to HomeViewController. This method is called when the log in operation is performing succesfully
    func toHomeViewController() {
        self.performSegueWithIdentifier(Constants.Segue.TO_HOME_VC, sender: self)
    }

}

// MARK: - UITextFieldDelegate implementation for LoginViewController
extension LoginViewController: UITextFieldDelegate {
    
    // MARK: Set the UITextFields form delegate
    func setTextFieldsDelegate() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // MARK: Method called when the user push Next in the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue(), {
            if textField == self.usernameTextField {
                textField.resignFirstResponder()
                self.passwordTextField.becomeFirstResponder()
            } else if textField == self.passwordTextField {
                self.view.endEditing(true)
                self.onSignIn()
            }
        })
        return true;
    }

}

// MARK: - ValidationDelegate implementation for LoginViewController
extension LoginViewController: ValidationDelegate {
    
    // MARK: Register the required fields
    func registerFieldsInValidator() {
        let requiredString = NSLocalizedString("common.validator.required", comment: "The required field message")
        customValidator.registerField(usernameTextField, errorLabel: usernameErrorLabel, rules: [RequiredRule(message: requiredString)])
        customValidator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule(message: requiredString)])
    }
    
    // MARK: Method called when validation failed
    func validationFailed(errors:[UITextField:ValidationError]) {
        customValidator.validationFailed(errors)
        Diexpenses.switchButton(signInButton)
    }
    
    // MARK: Method called when form validation is succesfull
    func validationSuccessful() {
        doLogin()
        Diexpenses.switchButton(signInButton)
    }
}


// MARK: - API Request
extension LoginViewController {
    
    // MARK: Log in the user on the APP calling to diexpensesAPI
    func doLogin() {
        let user = usernameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let password = passwordTextField.text!
        let userPass = NameUserPass(name: nil, user: user, pass: password)
        let userPassJson = JsonUtils.JSONStringify(userPass.toJSON()!, prettyPrinted: true)
        
        Diexpenses.doRequest(Constants.API.LOGIN_URL, headers: Diexpenses.getTypicalHeaders(false), verb: HttpVerbs.POST.rawValue, body: userPassJson, completionHandler: {
            data, response, error in
            
            if let d = data {
                do {
                    let userJson: AnyObject! = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))
                    Diexpenses.user = User(json: userJson as! JSON)
                    if let _ = Diexpenses.user {
                        LoginViewController.setUserInPrefs()
                        dispatch_async(dispatch_get_main_queue(), {
                            self.toHomeViewController()
                        })
                    } else {
                        Diexpenses.dealWithGenericResponse(self, responseData: data)
                    }
                } catch let error as NSError {
                    NSLog("Error doing login: \(error.localizedDescription)")
                }
            } else {
                Diexpenses.showError(self, message: NSLocalizedString("common.noInternetConnection", comment: "No Internet connection message"))
            }
        })
    }

}