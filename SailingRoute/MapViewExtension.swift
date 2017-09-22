//
//  MapViewExtension.swift
//  SailingRoute
//
//  Created by Jeff Trent on 9/22/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation
import MapKit


extension MKMapView {
    func drawBuoys(buoyList: BuoyList) {
        self.removeAnnotations(self.annotations)
        
        let buoys = Settings.shared.showAllBuoys ? buoyList.buoys : buoyList.used
        buoys.forEach { self.addAnnotation($0.annotation) }
    }
}
