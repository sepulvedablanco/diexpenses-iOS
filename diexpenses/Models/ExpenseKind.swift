//
//  ExpenseKind.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 6/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Gloss

public struct ExpenseKind {
    
    var id: NSNumber!
    var description: String
    
    public init(id: NSNumber!, description: String) {
        self.id = id
        self.description = description
    }
    
    public init(description: String) {
        self.init(id: nil, description: description)
    }
}

extension ExpenseKind: Decodable {

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

extension ExpenseKind: Encodable {
    
    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "description" ~~> self.description
        ])
    }
    
}