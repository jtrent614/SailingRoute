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
        guard let encodedData = data(forKey: Keys.savedRoutes.rawValue),
            let routeList = try? [TraveledRoute].decode(from: encodedData) else { return [TraveledRoute]() }
        return routeList
    }
    
    func updateSavedRoutes(_ routes: [TraveledRoute]) {
        do {
            let encodedData = try routes.encode()
            set(encodedData, forKey: Keys.savedRoutes.rawValue)
        } catch { print(error) }
    }
    
    func saveRoute(_ route: TraveledRoute) {
        var routes = getRoutes()
        routes.insert(route, at: 0)
        do {
            let encodedData = try routes.encode()
            set(encodedData, forKey: Keys.savedRoutes.rawValue)
        } catch { print(error) }
    }

    
    func saveBuoyList(_ list: BuoyList) {
        do {
            let encodedData = try list.encode()
            set(encodedData, forKey: Keys.buoyList.rawValue)
        } catch { print(error) }
    }
    
    func getBuoyList() -> BuoyList {
        guard let encodedData = data(forKey: Keys.buoyList.rawValue),
            let buoyList = try? BuoyList.decode(from: encodedData) else { return BuoyList() }
        return buoyList
    }
    
}


/*
 Printing JSON:
 
 let json = try? JSONSerialization.jsonObject(with: encodedData, options: .allowFragments)
 if let json = json {
 print(String(describing: json))
 }
 */

