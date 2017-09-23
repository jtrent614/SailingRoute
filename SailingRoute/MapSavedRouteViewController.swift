//
//  MapSavedRouteViewController.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/20/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit
import MapKit

class MapSavedRouteViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var route: Route!
    var buoyList: BuoyList!
    var delegate = MapDelegate()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabBar = self.tabBarController as! SailingRouteTabBarController
        buoyList = tabBar.buoyList
        
        mapView.delegate = delegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.add(route.polyline)
        mapView.setRegion(route.mapRegion(), animated: false)
        navigationItem.title = "Distance: \(route.distance.distanceToString) nm"

        mapView.drawBuoys(buoyList: buoyList)
    }
    

}
