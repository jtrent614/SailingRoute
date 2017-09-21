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
    weak var buoyList: BuoyList?
    
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







//    init(encodedBuoy: EncodableBuoy) {
//        let identifier = (encodedBuoy.buoy?.identifier)!
//        let coordinate = (encodedBuoy.buoy?.coordinate)!
//        let usedInRace = (encodedBuoy.buoy?.usedInRace)!
//        let buoyList = (encodedBuoy.buoy?.buoyList)!
//        self.init(identifier: identifier, coordinate: coordinate, usedInRace: usedInRace, buoyList: buoyList)
//    }
//
//    init(identifier: String, coordinate: CLLocationCoordinate2D, usedInRace: Bool, buoyList: BuoyList) {
//        self.identifier = identifier
//        self.coordinate = coordinate
//        self.usedInRace = usedInRace
//        self.buoyList = buoyList
//    }


//class EncodableBuoy: NSObject, NSCoding {
//
//    var buoy: Buoy?
//    var buoyList: BuoyList?
//
//    init(buoy: Buoy?, buoyList: BuoyList) {
//        self.buoy = buoy
//        self.buoyList = buoyList
//    }
//
//    required init?(coder decoder: NSCoder) {
//        guard
//            let identifier = decoder.decodeObject(forKey: "identifier") as? String,
//            let usedInRace = decoder.decodeObject(forKey: "usedInRace") as? Bool,
//            let latitude = decoder.decodeObject(forKey: "latitude") as? Double,
//            let longitude = decoder.decodeObject(forKey: "longitude") as? Double
//            else { return nil }
//        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        buoy = Buoy(identifier: identifier, coordinate: coordinate, usedInRace: usedInRace, buoyList: buoyList!)
//    }
//
//    func encode(with encoder: NSCoder) {
//        encoder.encode(buoy?.identifier, forKey: "identifier")
//        encoder.encode(buoy?.usedInRace, forKey: "usedInRace")
//        encoder.encode(buoy?.coordinate.latitude, forKey: "latitude")
//        encoder.encode(buoy?.coordinate.longitude, forKey: "longitude")
//    }
//}
//
//protocol Encoded {
//    associatedtype Encoder: NSCoding
//    
//    var encoder: Encoder { get }
//}
//
//protocol Encodable {
//    associatedtype Value
//    
//    var value: Value? { get }
//}
//
//extension EncodableBuoy: Encodable {
//    var value: Buoy? {
//        return buoy
//    }
//}
//
//extension Buoy: Encoded {
//    var encoder: EncodableBuoy {
//        return EncodableCoordinate(buoy: self, buoyList: self.buoyList)
//    }
//}

