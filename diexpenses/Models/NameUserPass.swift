//
//  NameUserPass.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 14/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Gloss

public struct NameUserPass {

    public let name: String!
    public let user: String
    public let pass: String
    
    public init(name: String?, user: String, pass: String) {
        self.name = name
        self.user = user
        self.pass = pass
    }
    
}

extension NameUserPass: Decodable {
    
    // MARK: - Deserialization
    public init?(json: JSON) {
        
        guard let name: String = "name" <~~ json
            else { return nil }
        
        guard let user: String = "user" <~~ json
            else { return nil }
        
        guard let pass: String = "pass" <~~ json
            else { return nil }
        
        self.name = name
        self.user = user
        self.pass = pass
    }
}

extension NameUserPass: Encodable {
    
    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> self.name,
            "user" ~~> self.user,
            "pass" ~~> self.pass
        ])
    }
    
}
