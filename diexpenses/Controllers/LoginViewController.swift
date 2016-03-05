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

    let validator = Validator();

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBAction func onSignIn() {
        // Validate fields
        validator.validate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setTextFieldsDelegate()
        setValidationStyles()
        registerFieldsInValidator()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoginViewController {
    
    static func setUserInPrefs() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(true, forKey: Constants.Session.IS_LOGGED_IN)
        prefs.setObject(Diexpenses.user.toJSON(), forKey: Constants.Session.USER)
    }
    
    func toHomeViewController() {
        self.performSegueWithIdentifier(Constants.Segue.TO_HOME_VC, sender: self)
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func setTextFieldsDelegate() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
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

extension LoginViewController: ValidationDelegate {
    
    func setValidationStyles() {
        validator.styleTransformers(
            success:{ (validationRule) -> Void in
                self.setValidStyle(validationRule.textField, errorLabel: validationRule.errorLabel!)
            },
            error:{ (validationError) -> Void in
                self.setErrorStyle(validationError.textField, errorLabel: validationError.errorLabel!, errorMessage: validationError.errorMessage)
        })
    }
    
    func registerFieldsInValidator() {
        let requiredString = NSLocalizedString("common.validator.required", comment: "The required field message")
        validator.registerField(usernameTextField, errorLabel: usernameErrorLabel, rules: [RequiredRule(message: requiredString)])
        validator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule(message: requiredString)])
    }
    
    func validationFailed(errors:[UITextField:ValidationError]) {
        for (field, error) in validator.errors {
            setErrorStyle(field, errorLabel: error.errorLabel!, errorMessage: error.errorMessage)
        }
    }
    
    func setValidStyle(input: UIView, errorLabel: UILabel) {
        input.layer.borderColor = Diexpenses.greenColor.CGColor
        input.layer.borderWidth = 0.5
        // clear error label
        errorLabel.hidden = true
        errorLabel.text = ""
    }
    
    func setErrorStyle(input: UIView, errorLabel: UILabel, errorMessage: String) {
        input.layer.borderColor = Diexpenses.redColor.CGColor
        input.layer.borderWidth = 1.0
        errorLabel.text = errorMessage
        errorLabel.hidden = false
    }
    
    func validationSuccessful() {
        doLogin()
    }
}


extension LoginViewController {
    
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