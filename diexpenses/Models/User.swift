//
//  User.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 28/1/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Gloss

public struct User {

    public let id: NSNumber!
    public let authToken: String!
    public let user: String
    public let name: String!
    
    public init(user: String) {
        self.init(id: nil, authToken: nil, user: user, name: nil)
    }
    
    public init(id: NSNumber?, authToken: String?, user: String, name: String?) {
        self.id = id
        self.authToken = authToken
        self.user = user
        self.name = name
    }
}

extension User: Decodable {
    
    // MARK: - Deserialization
    public init?(json: JSON) {
        
        guard let id: NSNumber = "id" <~~ json
            else { return nil }
        
        guard let authToken: String = "authToken" <~~ json
            else { return nil }
        
        guard let user: String = "user" <~~ json
            else { return nil }
        
        guard let name: String = "name" <~~ json
            else { return nil }
        
        self.id = id
        self.authToken = authToken
        self.user = user
        self.name = name
    }
}

extension User: Encodable {

    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "authToken" ~~> self.authToken,
            "user" ~~> self.user,
            "name" ~~> self.name
        ])
    }

}
