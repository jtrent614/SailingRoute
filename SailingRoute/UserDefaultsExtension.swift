//
//  UserDefaultSaver.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/23/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation


enum Keys: String {
    case savedRoutes = "savedRoutes2"
    case buoyList = "buoyList2"
//    case buoys = "buoys"
}

extension UserDefaults {
    
    func getRoutes() -> [TraveledRoute] {
        var routes = [TraveledRoute]()
        if let encodedData = data(forKey: Keys.savedRoutes.rawValue) {
            routes = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as! [TraveledRoute]
        }
        return routes
    }
    
    func updateSavedRoutes(_ routes: [TraveledRoute]) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: routes)
        set(encodedData, forKey: Keys.savedRoutes.rawValue)
    }
    
    func saveRoute(_ route: TraveledRoute) {
        var routes = getRoutes()
        routes.insert(route, at: 0)
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: routes)
        set(encodedData, forKey: Keys.savedRoutes.rawValue)
    }
    
    func saveBuoyList(_ list: BuoyList) {
//        let buoys: [EncodableBuoy] = list.buoys.map { EncodableBuoy(buoy: $0, buoyList: list) }
//        let newList = BuoyList()
//        newList.unused = encodedBuoys.flatMap{ $0.buoy }.filter { !$0.usedInRace }
//        newList.used = encodedBuoys.flatMap{ $0.buoy }.filter { $0.usedInRace }
//        list.unused = [Buoy]()
//        list.used = [Buoy]()
//        let encodedBuoys = NSKeyedArchiver.archivedData(withRootObject: buoys)
//        let encodedBuoyList = NSKeyedArchiver.archivedData(withRootObject: list)
//        set(encodedBuoys, forKey: Keys.buoys.rawValue)
//        set(encodedBuoyList, forKey: Keys.buoyList.rawValue)
        let encodedBuoyList = list.serialize()
        if let encodedBuoyList = encodedBuoyList {
            let archivedData = NSKeyedArchiver.archivedData(withRootObject: encodedBuoyList)
            set(archivedData, forKey: Keys.buoyList.rawValue)
        }
    }
    
    func getBuoyList() -> BuoyList {
//        guard let encodedBuoyList = data(forKey: Keys.buoyList.rawValue),
//            let encodedBuoys = data(forKey: Keys.buoys.rawValue) else { return BuoyList() }
//        let buoyList = NSKeyedUnarchiver.unarchiveObject(with: encodedBuoyList) as! BuoyList
//       let buoys = NSKeyedUnarchiver.unarchiveObject(with: encodedBuoys) as! [EncodableBuoy]
//        buoyList.unused = buoys.map { Buoy(encodedBuoy: $0) }.filter{ !$0.usedInRace }
//        buoyList.used = buoys.map { Buoy(encodedBuoy: $0) }.filter{ !$0.usedInRace }
//        return buoyList
        guard let archivedBuoyList = data(forKey: Keys.buoyList.rawValue) else { return BuoyList() }
        
        let decoder = JSONDecoder()
        return try! decoder.decode(BuoyList.self, from: archivedBuoyList)
    }
    
}

