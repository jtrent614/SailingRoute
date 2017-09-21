//
//  BuoyLocation.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/22/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit
import MapKit


struct Buoy: Serializable {

    var identifier: String
    var usedInRace: Bool = false
    var buoyList: BuoyList?
    
    private var _latitude: Double
    private var _longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        get { return CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude) }
        set (coordinate) {
            _latitude = coordinate.latitude
            _longitude = coordinate.longitude
        }
    }
    
    var location: CLLocation {
        get { return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude) }
        set (location){ coordinate = location.coordinate }
    }

    var annotation: MKAnnotation {
        return Annotation(coordinate: self.coordinate, buoy: self)
    }
  
    init(identifier: String, coordinate: CLLocationCoordinate2D, usedInRace: Bool, buoyList: BuoyList) {
        self.identifier = identifier
        self._latitude = coordinate.latitude
        self._longitude = coordinate.longitude
        self.usedInRace = usedInRace
        self.buoyList = buoyList
    }
}



class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var buoy: Buoy
    
    init(coordinate: CLLocationCoordinate2D, buoy: Buoy) {
        self.coordinate = coordinate
        self.buoy = buoy
        super.init()
    }
}

