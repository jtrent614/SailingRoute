//
//  SailingRouteTabBarController.swift
//  SailingRoute
//
//  Created by Jeff Trent on 9/19/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit

class SailingRouteTabBarController: UITabBarController {

    var buoyList = BuoyList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buoyList = UserDefaults.standard.getBuoyList()
        Settings.shared.raceMode = UserDefaults.standard.bool(forKey: "raceMode")
    }

}
