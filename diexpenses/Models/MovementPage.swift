//
//  MovementPage.swift
//  diexpenses
//
//  Created by Diego Sepúlveda Blanco on 7/2/16.
//  Copyright © 2016 UPSA. All rights reserved.
//

import Gloss

public struct MovementPage {
    
    public let page: [Movement]!
    public let totalMovements: NSNumber!
    
    public init(page: [Movement]!, totalMovements: NSNumber) {
        self.page = page
        self.totalMovements = totalMovements
    }
}

extension MovementPage: Decodable {
    
    // MARK: - Deserialization
    public init?(json: JSON) {
        
        guard let page: [Movement] = Movement.modelsFromJSONArray((NSLocalizedString("common.page", comment: "The page message") <~~ json)!)
            else { return nil }
        
        guard let totalMovements: NSNumber = NSLocalizedString("common.totalMovements", comment: "The total movements message") <~~ json
            else { return nil }
        
        self.page = page
        self.totalMovements = totalMovements
    }
}

extension MovementPage: Encodable {

    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            "page" ~~> self.page,
            "totalMovements" ~~> self.totalMovements
        ])
    }
}
