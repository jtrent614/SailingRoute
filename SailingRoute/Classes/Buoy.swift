//
//  BuoyLocation.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/22/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit
import MapKit


struct Buoy: Codable {

    var identifier: String
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
        return Annotation(buoy: self)
    }
  
    init(identifier: String, coordinate: CLLocationCoordinate2D, buoyList: BuoyList) {
        self.identifier = identifier
        self._latitude = coordinate.latitude
        self._longitude = coordinate.longitude
        self.buoyList = buoyList
    }
    
    private enum CodingKeys: String, CodingKey {
        case identifier
        case _latitude
        case _longitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(_latitude, forKey: ._latitude)
        try container.encode(_longitude, forKey: ._longitude)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self._latitude = try container.decode(Double.self, forKey: ._latitude)
        self._longitude = try container.decode(Double.self, forKey: ._longitude)
    }
}



class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var buoy: Buoy
    
    init(buoy: Buoy) {
        self.coordinate = buoy.coordinate
        self.buoy = buoy
        super.init()
    }
}

