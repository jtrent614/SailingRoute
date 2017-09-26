//
//  BuoyList.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/23/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation
import CoreLocation

// Must remain a class instead of struct since we're passing references around throughout the app
class BuoyList: NSObject, Codable
{
    var identifier: String = "main"
    
    var unused: [Buoy] = [Buoy]()
    var used: [Buoy] = [Buoy]()
    
    var buoys: [Buoy] {
        return (used + unused).sorted(by: { $0.identifier < $1.identifier })
    }

    override init() {
        super.init()
        for (name, location) in defaultBuoyDict {
            unused.append(Buoy(identifier: name, coordinate: location.coordinate, buoyList: self))
        }
        unused = buoys
    }
    
    func moveBuoyToUnused(buoy: Buoy) {
        guard let index = used.index(where: { $0.identifier == buoy.identifier }) else { return }
        
        used.remove(at: index)
        unused.insert(buoy, at: 0)
    }

    func buoyWithIdentifier(id: String) -> Buoy {
        return buoys.filter { $0.identifier == id }.first!
    }
    
    func addBuoy(_ buoy: Buoy) {
        unused.append(buoy)
    }
    
    func deleteUnusedBuoy(indexPath: IndexPath) {
        guard indexPath.section == 2 else { return }
        self.unused.remove(at: indexPath.row)
    }
    
    func getBuoyAt(indexPath: IndexPath) -> Buoy {
        return indexPath.section == 1 ? self.used[indexPath.row] : self.unused[indexPath.row]
    }
    
    func repositionBuoy(from: IndexPath, to: IndexPath) {
        let buoy = self.getBuoyAt(indexPath: from)
        
        switch (from.section, to.section) {
        case (1, 2):
            self.used.remove(at: from.row)
            self.unused.insert(buoy, at: to.row)
        case (2, 1):
            self.unused.remove(at: from.row)
            self.used.insert(buoy, at: to.row)
        case (2, 2):
            self.unused.remove(at: from.row)
            self.unused.insert(buoy, at: to.row)
        case (1, 1):
            self.used.remove(at: from.row)
            self.used.insert(buoy, at: to.row)
        default: return
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case identifier
        case unused
        case used
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(unused, forKey: .unused)
        try container.encode(used, forKey: .used)
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

