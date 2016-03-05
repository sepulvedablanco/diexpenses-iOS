//
//  Movement.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 7/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Gloss

public struct Movement {
    
    public let id: NSNumber!
    public let expense: Bool!
    public let concept: String!
    public let transactionDate: NSDate!
    public let amount: NSNumber!
    public let financialMovementType: ExpenseKind!
    public let financialMovementSubtype: ExpenseKind!
    public let bankAccount: BankAccount!
    
    public init(id: NSNumber!, expense: Bool, concept: String, transactionDate: NSDate, amount: NSNumber, financialMovementType: ExpenseKind, financialMovementSubtype: ExpenseKind, bankAccount: BankAccount) {
        self.id = id
        self.expense = expense
        self.concept = concept
        self.transactionDate = transactionDate
        self.amount = amount
        self.financialMovementType = financialMovementType
        self.financialMovementSubtype = financialMovementSubtype
        self.bankAccount = bankAccount
    }
    
    public init(expense: Bool, concept: String, transactionDate: NSDate, amount: NSNumber, financialMovementType: ExpenseKind, financialMovementSubtype: ExpenseKind, bankAccount: BankAccount) {
        self.init(id: nil, expense: expense, concept: concept, transactionDate: transactionDate, amount: amount, financialMovementType: financialMovementType, financialMovementSubtype: financialMovementSubtype, bankAccount: bankAccount)
    }
}

extension Movement: Decodable {
    
    // MARK: - Deserialization
    public init?(json: JSON) {

        guard let id: NSNumber = "id" <~~ json
            else { return nil }
        
        guard let expense: Bool = "expense" <~~ json
            else { return nil }

        guard let concept: String = "concept" <~~ json
            else { return nil }
        
        guard let transactionDate: NSDate = Diexpenses.formatDate(("transactionDate" <~~ json)!)
            else { return nil }
        
        guard let amount: NSNumber = "amount" <~~ json
            else { return nil }
        
        guard let financialMovementType: ExpenseKind = "financialMovementType" <~~ json
            else { return nil }

        let financialMovementSubtype: ExpenseKind? = "financialMovementSubtype" <~~ json

        guard let bankAccount: BankAccount = "bankAccount" <~~ json
            else { return nil }

        self.id = id
        self.expense = expense
        self.concept = concept
        self.transactionDate = transactionDate
        self.amount = amount
        self.financialMovementType = financialMovementType
        self.financialMovementSubtype = financialMovementSubtype
        self.bankAccount = bankAccount
    }
    
}

extension Movement: Encodable {

    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "expense" ~~> self.expense.description,
            "concept" ~~> self.concept,
            "transactionDate" ~~> Diexpenses.formatDate(self.transactionDate, format: Diexpenses.DAY_MONTH_YEAR_WITH_HOUR),
            "amount" ~~> self.amount,
            "financialMovementType" ~~> self.financialMovementType.toJSON()!,
            "financialMovementSubtype" ~~> self.financialMovementSubtype.toJSON()!,
            "bankAccount" ~~> self.bankAccount.toJSON()!
        ])
    }
}
