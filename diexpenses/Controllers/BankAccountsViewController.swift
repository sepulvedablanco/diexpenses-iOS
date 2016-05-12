//
//  BankAccountsViewController.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 25/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit
import Gloss

class BankAccountsViewController: UIViewController {
    
    static let path = NSBundle.mainBundle().pathForResource("Entities", ofType: "plist")
    static let dataDictionary = NSDictionary(contentsOfFile: path!)!

    var bankAccounts : [BankAccount] = []

    var refreshControl: UIRefreshControl!

    @IBOutlet weak var bankAccountsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initVC()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Extension for legacy operations
extension BankAccountsViewController {
    
    // MARK: Initialize the View Controller
    func initVC() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BankAccountsViewController.loadBankAccounts), name:Constants.Notifications.BANK_ACCOUNTS_CHANGED, object: nil)
        refreshControl = Diexpenses.createRefreshControl(self, actionName: #selector(BankAccountsViewController.refreshBankAccounts(_:)))
        bankAccountsTableView.addSubview(self.refreshControl)
        self.loadBankAccounts()
    }
    
    // MARK: Refresh the bank accounts table data
    func refreshBankAccounts(refreshControl: UIRefreshControl) {
        loadBankAccounts()
        refreshControl.endRefreshing()
    }
    
    // MARK: Return the name of the image for the bank entity
    func getBankLogo(entity: String) -> String {
        let entityImageOpt = BankAccountsViewController.dataDictionary[entity]
        if let entityImage = entityImageOpt {
            return entityImage as! String
        }
        
        return Constants.Images.UNKNOW_ENTITY;
    }
    
    // MARK: System method called when new bank account button is pushed
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            if identifier == Constants.Segue.TO_NEW_BANK_ACCOUNT_VC {
                if let newBankAccountViewController = segue.destinationViewController as? NewBankAccountViewController {
                    let bankCell = sender as? BankCell
                    if let cell = bankCell {
                        newBankAccountViewController.bankAccount = cell.bankAccount
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate implementation for BankAccountsViewController
extension BankAccountsViewController: UITableViewDelegate {
    
    // MARK: Menu showed when row is swiped
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .Destructive, title: NSLocalizedString("common.delete", comment: "The delete title")) {
            action, index in
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let bankCell = cell as! BankCell

            let alert = UIAlertController(title: NSLocalizedString("bankAccounts.delete", comment: "Delete bank account title"), message: NSLocalizedString("bankAccounts.delete.message", comment: "Delete bank account message"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("common.delete", comment: "The common message delete"), style: .Destructive, handler: {
                (action) -> Void in
                
                self.removeBankAccount(bankCell.bankAccount.id)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: "The common cancel message"), style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        remove.backgroundColor = Diexpenses.redColor
        
        let edit = UITableViewRowAction(style: .Normal, title: NSLocalizedString("common.edit", comment: "The edit title")) {
            action, index in
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let bankCell = cell as! BankCell
            self.performSegueWithIdentifier(Constants.Segue.TO_NEW_BANK_ACCOUNT_VC, sender: bankCell)
            
        }
        edit.backgroundColor = Diexpenses.greenColor
        
        return [remove, edit]
    }
}

// MARK: - UITableViewDataSource implementation for BankAccountsViewController
extension BankAccountsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankAccounts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCellWithIdentifier(BankCell.identifier, forIndexPath: indexPath) as UITableViewCell
        
        let bankCell = cell as! BankCell
        let bankAccount = bankAccounts[indexPath.row]
        bankCell.bankAccount = bankAccount
        bankCell.bankLogoImageView.image = UIImage(named: getBankLogo(bankAccount.entity))
        bankCell.descriptionLabel.text = bankAccount.description + " (" + Diexpenses.formatCurrency(bankAccount.balance) + ")"
        bankCell.bankAccountLabel.text = bankAccount.completeBankAccount
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if bankAccounts.isEmpty {
            return NSLocalizedString("bankAccounts.noData", comment: "The no bank accounts message")
        }
        
        return nil
    }
}

// MARK: - API Request
extension BankAccountsViewController {
    
    // MARK: Load bank accounts calling to diexpensesAPI
    func loadBankAccounts() {
        
        let bankAccountsURL = String.localizedStringWithFormat(Constants.API.LIST_BANK_ACCOUNTS_URL, Diexpenses.user.id)
        Diexpenses.doRequest(bankAccountsURL, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.GET.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if let d = data {
                do {
                    let bankAccountsJson: AnyObject! = (try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions(rawValue: 0))  as? NSArray)!
                    self.bankAccounts = BankAccount.modelsFromJSONArray(bankAccountsJson as! [JSON])!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.bankAccountsTableView.reloadData()
                    })
                } catch let error as NSError {
                    NSLog("An error has occurred: \(error.localizedDescription)")
                }
            } else {
                Diexpenses.showError(self, message: NSLocalizedString("common.noInternetConnection", comment: "No Internet connection message"))
            }
        })
    }

    // MARK: Remove a bank account calling to diexpensesAPI
    func removeBankAccount(id: NSNumber) {
        let bankAccountsURL = String.localizedStringWithFormat(Constants.API.UD_BANK_ACCOUNT_URL, Diexpenses.user.id, id)
        Diexpenses.doRequest(bankAccountsURL, headers: Diexpenses.getTypicalHeaders(), verb: HttpVerbs.DELETE.rawValue, body: nil, completionHandler: {
            data, response, error in
            
            if Diexpenses.dealWithGenericResponse(self, responseData: data, expectedCode: 44) {
                Notificator.fireNotification(notificationName: Constants.Notifications.BANK_ACCOUNTS_CHANGED)
                self.loadBankAccounts()
            }
        })
    }

}

