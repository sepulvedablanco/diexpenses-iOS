//
//  BankCell.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 31/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

// MARK: - Custom UITableViewCell for BankAccountsViewController table view
class BankCell: UITableViewCell {
    
    internal static let identifier = "BankCell"

    var bankAccount : BankAccount!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bankAccountLabel: UILabel!
    @IBOutlet weak var bankLogoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
