//
//  BuoyList.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/23/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation
import CoreLocation

class BuoyList: NSObject, NSCoding
{
    var unused = [Buoy]()
    var used = [Buoy]()
    var buoys: [Buoy] {
        return (used + unused).sorted(by: { $0.identifier < $1.identifier })
    }

    override init() {
        super.init()
        for (name, location) in defaultBuoyDict {
            unused.append(Buoy(identifier: name, location: location, buoyList: self))
        }
        unused = buoys
    }

    func buoyWithIdentifier(id: String) -> Buoy {
        return buoys.filter { $0.identifier == id }.first!
    }
    
    func addBuoy(_ buoy: Buoy) {
        unused.append(buoy)
    }
    
    
    // MARK: - Coding

    required init?(coder aDecoder: NSCoder) {
        self.unused = aDecoder.decodeObject(forKey: "unused") as? [Buoy] ?? [Buoy]()
        self.used = aDecoder.decodeObject(forKey: "used") as? [Buoy] ?? [Buoy]()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(unused, forKey: "unused")
        aCoder.encode(used, forKey: "used")
    }


}


// MARK: - Buoy Data Import

let defaultBuoyDict: [String:CLLocation] = [
    "A": CLLocation(latitude: 27.90366667, longitude: -82.45466667),
    "B": CLLocation(latitude: 27.89766667, longitude: -82.44383333),
    "C": CLLocation(latitude: 27.8805,  longitude: -82.44466667),
    "D": CLLocation(latitude: 27.86366667, longitude: -82.44633333),
    "E": CLLocation(latitude: 27.88816667, longitude: -82.45283333),
    "F": CLLocation(latitude: 27.87783333, longitude: -82.45966667),
    "G": CLLocation(latitude: 27.883, longitude: -82.472),
    "H": CLLocation(latitude: 27.89333333, longitude: -82.46333333),
    "I": CLLocation(latitude: 27.912, longitude: -82.485),
    "O": CLLocation(latitude: 27.90833333, longitude: -82.453),
    "DEBUG": CLLocation(latitude: 27.0, longitude: -83.453),
]

