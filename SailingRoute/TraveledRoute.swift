//
//  TraveledRoute.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/23/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit
import MapKit

class TraveledRoute: Route {
    
    var dateCreated: Date
    var endDate: Date
    
    var dateDescription: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "MM/dd/yy - h:mm a"
            return dateFormatter.string(from: dateCreated)
        }
    }
    
    var averageSpeed: Double {
        let timeElapsedInHours = endDate.timeIntervalSince(dateCreated) / 60.0 / 60.0
        return (distance / timeElapsedInHours * 100).rounded() / 100
    }
    
    override init() {
        dateCreated = Date()
        endDate = Date()
        super.init()
    }
    
    init(locations: [CLLocation], dateCreated: Date) {
        self.dateCreated = dateCreated
        self.endDate = dateCreated
        super.init(locations: locations)
    }
    
    private enum CodingKeys: String, CodingKey {
        case dateCreated
        case endDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(endDate, forKey: .endDate)
    }
    
}
