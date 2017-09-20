//
//  BuoyLocation.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/22/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit
import MapKit


class Buoy: NSObject, MKAnnotation, NSCoding {

    var identifier: String
    var location: CLLocation
    weak var buoyList: BuoyList?
    
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    var usedInRace: Bool = false
    

    init(identifier: String, location: CLLocation, buoyList: BuoyList) {
        self.identifier = identifier
        self.location = location
        self.buoyList = buoyList
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.identifier = aDecoder.decodeObject(forKey: "identifier") as! String
        self.location = aDecoder.decodeObject(forKey: "location") as! CLLocation
        self.usedInRace = aDecoder.decodeBool(forKey: "usedInRace")
        self.buoyList = aDecoder.decodeObject(forKey: "buoyList") as? BuoyList
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(usedInRace, forKey: "usedInRace")
        aCoder.encode(buoyList, forKey: "buoyList")
    }

    

}


