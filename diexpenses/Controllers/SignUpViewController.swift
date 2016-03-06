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
    
    let validator = Validator()

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
        validator.validate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scrollView.configure(view)
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

extension SignUpViewController: UITextFieldDelegate {
    
    func setTextFieldsDelegate() {
        nameTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
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

    /*
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 150
    }

    func setTextFieldsMoving(up: Bool, textField: UITextField) {
        if textField == self.confirmPasswordTextField {
            animateViewMoving(up, moveValue: 180)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
    //    setTextFieldsMoving(true, textField: textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
    //    setTextFieldsMoving(false, textField: textField)
    }
    
    func animateViewMoving(up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }*/

}

extension SignUpViewController: ValidationDelegate {
    
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
        validator.registerField(nameTextField, errorLabel: nameErrorLabel, rules: [RequiredRule(message: requiredString)])
        validator.registerField(usernameTextField, errorLabel: usernameErrorLabel, rules: [RequiredRule(message: requiredString)])
        validator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule(message: requiredString), CustomPasswordRule()])
        validator.registerField(confirmPasswordTextField, errorLabel: confirmPasswordErrorLabel, rules: [RequiredRule(message: requiredString), ConfirmationRule(confirmField: passwordTextField, message: NSLocalizedString("common.validator.password.confirmation", comment: "The password confirmation message"))])
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
        createUser()
    }
}

extension SignUpViewController {
    
    func toHomeViewController() {
        self.performSegueWithIdentifier(Constants.Segue.TO_HOME_VC, sender: self)
    }
}

extension SignUpViewController {
    
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