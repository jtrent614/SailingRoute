//
//  UserDefaultSaver.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/23/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation


enum Keys: String {
    case savedRoutes = "savedRoutes"
    case buoyList = "buoyList"
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
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: list)
        set(encodedData, forKey: Keys.buoyList.rawValue)
    }
    
    func getBuoyList() -> BuoyList {
        var buoyList = BuoyList()
        if let encodedData = data(forKey: Keys.buoyList.rawValue) {
            buoyList = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as! BuoyList
        }
        return buoyList
    }
    
}

