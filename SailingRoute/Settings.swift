//
//  Settings.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/23/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit

class Settings: NSObject
{
    static let shared = Settings()
    
    var raceMode: Bool = true
    var showAllBuoys: Bool = false
    var mapViewDistance: Double = 3000
    
}
