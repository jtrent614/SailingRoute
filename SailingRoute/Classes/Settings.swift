//
//  Settings.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/23/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit

final class Settings: NSObject
{
    static let shared = Settings()
    
    var raceMode: Bool = false
    var showAllBuoys: Bool = false
    var mapViewDistance: Double = 3000
    
    private override init() {
        super.init()
    }
}
