//
//  ExpenseSubkind.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 10/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Gloss

public struct ExpenseSubkind: ExpenseKindBaseProtocol {
    
    var id: NSNumber!
    var description: String
    
    public init(id: NSNumber!, description: String) {
        self.id = id
        self.description = description
    }
    
    public init(description: String) {
        self.init(id: nil, description: description)
    }
    
    // MARK: - Deserialization
    public init?(json: JSON) {
        
        guard let id: NSNumber = "id" <~~ json
            else { return nil }
        
        guard let description: String = "description" <~~ json
            else { return nil }
        
        self.id = id
        self.description = description
    }
}

extension ExpenseSubkind {
    
    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "description" ~~> self.description
        ])
    }

}