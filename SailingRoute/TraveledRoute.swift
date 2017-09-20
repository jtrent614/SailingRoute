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
    
    required init?(coder aDecoder: NSCoder) {
        self.dateCreated = aDecoder.decodeObject(forKey: "dateCreated") as? Date ?? Date()
        self.endDate = aDecoder.decodeObject(forKey: "endDate") as? Date ?? Date()
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(dateCreated, forKey: "dateCreated")
        aCoder.encode(endDate, forKey: "endDate")
        super.encode(with: aCoder)
    }


}
