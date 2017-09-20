//
//  MapSavedRouteViewController.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/20/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit
import MapKit

import IVBezierPathRenderer

class MapSavedRouteViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var route: Route!
    var ssss = "git branch test"
    
    override func viewDidAppear(_ animated: Bool) {
        mapView.add(route.polyline)
        mapView.setRegion(route.mapRegion(), animated: false)
        navigationItem.title = "Distance: \(route.distanceDescription) nm"        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = IVBezierPathRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue.withAlphaComponent(0.4)
            renderer.lineWidth = 4.0
            renderer.borderColor = UIColor.red
            renderer.borderMultiplier = 0.1
            return renderer
        }
        return MKOverlayRenderer()
    }
    

}
