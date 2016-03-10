//
//  MovementCell.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 16/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import UIKit

// MARK: - Custom UITableViewCell for MovementsViewController table view
class MovementCell: UITableViewCell {
    
    internal static let identifier = "MovementCell"
    
    var movement : Movement!
    
    @IBOutlet weak var expenseIncomeImageView: UIImageView!
    @IBOutlet weak var descriptionAmountLabel: UILabel!
    @IBOutlet weak var kindSubkindLabel: UILabel!
    @IBOutlet weak var bankAccountLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
