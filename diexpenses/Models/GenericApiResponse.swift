//
//  GenericApiResponse.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 1/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Gloss

public struct GenericApiResponse {
    
    public let code: NSNumber
    public let message: String
    
    public init(code: NSNumber, message: String) {
        self.code = code
        self.message = message
    }
}

extension GenericApiResponse: Decodable {
    
    // MARK: - Deserialization
    public init?(json: JSON) {
        
        guard let code: NSNumber = "code" <~~ json
            else { return nil }
        
        guard let message: String = "message" <~~ json
            else { return nil }
        
        self.code = code
        self.message = message
    }
    
}

extension GenericApiResponse: Encodable {
    
    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            "code" ~~> self.code,
            "message" ~~> self.message
        ])
    }
}
