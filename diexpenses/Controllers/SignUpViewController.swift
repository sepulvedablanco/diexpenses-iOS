//
//  SignUpViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 13/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss
import SwiftValidator

class SignUpViewController: UIViewController {
    
    let customValidator = CustomValidator()

    @IBOutlet weak var scrollView: CustomScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    
    @IBAction func onSignUp() {
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
extension SignUpViewController {
    
    // MARK: Initialize the View Controller
    func initVC() {
        scrollView.configure(view)
        setTextFieldsDelegate()
        registerFieldsInValidator()
    }
    
    // MARK: Redirection to HomeViewController. This method is called when new user is created
    func toHomeViewController() {
        self.performSegueWithIdentifier(Constants.Segue.TO_HOME_VC, sender: self)
    }
}

// MARK: - UITextFieldDelegate implementation for SignUpViewController
extension SignUpViewController: UITextFieldDelegate {
    
    // MARK: Set the UITextFields form delegate
    func setTextFieldsDelegate() {
        nameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    // MARK: Method called when the user push Next in the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dispatch_async(dispatch_get_main_queue(), {
            if textField == self.nameTextField {
                textField.resignFirstResponder()
                self.usernameTextField.becomeFirstResponder()
            } else if textField == self.usernameTextField {
                textField.resignFirstResponder()
                self.passwordTextField.becomeFirstResponder()
            } else if textField == self.passwordTextField {
                textField.resignFirstResponder()
                self.confirmPasswordTextField.becomeFirstResponder()
            } else if textField == self.confirmPasswordTextField {
                self.view.endEditing(true)
                self.onSignUp()
            }
        })
        return true;
    }
}

// MARK: - ValidationDelegate implementation for SignUpViewController
extension SignUpViewController: ValidationDelegate {
    
    // MARK: Register the required fields
    func registerFieldsInValidator() {
        let requiredString = NSLocalizedString("common.validator.required", comment: "The required field message")
        customValidator.registerField(nameTextField, errorLabel: nameErrorLabel, rules: [RequiredRule(message: requiredString)])
        customValidator.registerField(usernameTextField, errorLabel: usernameErrorLabel, rules: [RequiredRule(message: requiredString)])
        customValidator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule(message: requiredString), CustomPasswordRule()])
        customValidator.registerField(confirmPasswordTextField, errorLabel: confirmPasswordErrorLabel, rules: [RequiredRule(message: requiredString), ConfirmationRule(confirmField: passwordTextField, message: NSLocalizedString("common.validator.password.confirmation", comment: "The password confirmation message"))])
    }
    
    // MARK: Method called when validation failed
    func validationFailed(errors:[UITextField:ValidationError]) {
        customValidator.validationFailed(errors)
    }
    
    // MARK: Method called when form validation is succesfull
    func validationSuccessful() {
        createUser()
    }
}

// MARK: - API Request
extension SignUpViewController {
    
    // MARK: Create a new user on the APP calling to diexpensesAPI
    func createUser() {
        let name = nameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let user = usernameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let password = passwordTextField.text!
        let nameUserPass = NameUserPass(name: name, user: user, pass: password)
        let nameUserPassJson = JsonUtils.JSONStringify(nameUserPass.toJSON()!, prettyPrinted: true)
        
        Diexpenses.doRequest(Constants.API.CREATE_USER_URL, headers: Diexpenses.getTypicalHeaders(false), verb: HttpVerbs.POST.rawValue, body: nameUserPassJson, completionHandler: {
            data, response, error in
            
            if let d = data {
                if Diexpenses.dealWithGenericResponse(self, responseData: d, expectedCode: 3) {
                    self.doLogin(nameUserPass)
                }
            } else {
                Diexpenses.showError(self, message: NSLocalizedString("common.noInternetConnection", comment: "No Internet connection message"))
            }
        })
    }

    // MARK: Log in the user on the APP calling to diexpensesAPI
    func doLogin(nameUserPass: NameUserPass) {
        let userPassJson = JsonUtils.JSONStringify(nameUserPass.toJSON()!, prettyPrinted: true)
        NSLog("\(userPassJson)")
        
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
                        Diexpenses.dealWithGenericResponse(self, responseData: d)
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