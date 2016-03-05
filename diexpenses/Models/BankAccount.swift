//
//  BankAccount.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 31/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Gloss

public struct BankAccount {
    
    public let id: NSNumber!
    public let iban: String!
    public let entity: String
    public let office: String!
    public let controlDigit: String!
    public let accountNumber: String!
    public let balance: NSNumber!
    public let description: String!
    public let completeBankAccount: String!

    public init(id: NSNumber!, iban: String!, entity: String, office: String, controlDigit: String, accountNumber: String, balance: NSNumber, description: String) {
        self.id = id
        self.iban = iban
        self.entity = entity
        self.office = office
        self.controlDigit = controlDigit
        self.accountNumber = accountNumber
        self.balance = balance
        self.description = description
        self.completeBankAccount = nil
    }

    public init(iban: String!, entity: String, office: String, controlDigit: String, accountNumber: String, balance: NSNumber, description: String) {
        self.init(id: nil, iban: iban, entity: entity, office: office, controlDigit: controlDigit, accountNumber: accountNumber, balance: balance, description: description)
    }
}

extension BankAccount: Decodable {
    
    // MARK: - Deserialization
    public init?(json: JSON) {
        
        guard let id: NSNumber = "id" <~~ json
            else { return nil }
        
        guard let iban: String = "iban" <~~ json
            else { return nil }
        
        guard let entity: String = "entity" <~~ json
            else { return nil }
        
        guard let office: String = "office" <~~ json
            else { return nil }
        
        guard let controlDigit: String = "controlDigit" <~~ json
            else { return nil }

        guard let accountNumber: String = "accountNumber" <~~ json
            else { return nil }

        guard let balance: NSNumber = "balance" <~~ json
            else { return nil }

        guard let description: String = "description" <~~ json
            else { return nil }
        
        guard let completeBankAccount: String = "completeBankAccount" <~~ json
            else { return nil }

        self.id = id
        self.iban = iban
        self.entity = entity
        self.office = office
        self.controlDigit = controlDigit
        self.accountNumber = accountNumber
        self.balance = balance
        self.description = description
        self.completeBankAccount = completeBankAccount

    }
}

extension BankAccount: Encodable {
    
    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "iban" ~~> self.iban,
            "entity" ~~> self.entity,
            "office" ~~> self.office,
            "controlDigit" ~~> self.controlDigit,
            "accountNumber" ~~> self.accountNumber,
            "balance" ~~> self.balance,
            "description" ~~> self.description,
            "completeBankAccount" ~~> self.completeBankAccount
        ])
    }
}