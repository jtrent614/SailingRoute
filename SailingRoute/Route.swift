//
//  Route.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/20/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation
import MapKit

class Route: NSObject, NSCoding
{
    let viewDistanceMultiplier: CLLocationDegrees = 1.3
    
    var locations: [CLLocation] {
        didSet {
            if locations.count > 1 {
                distance += (locations.last!.distance(from: oldValue.last!) * UnitConversions.meterToNauticalMile)
            }
        }
    }
    
    var placemark: CLPlacemark?

    var distance: CLLocationDistance = 0.0
    var distanceDescription: String {
        get {
            let precision: Double = distance < 10.0 ? 100.0 : 10.0
            return String(describing: (distance * precision).rounded() / precision)
        }
    }
    
    var coordinates: [CLLocationCoordinate2D] { get { return locations.map { $0.coordinate } } }
    var polyline: MKPolyline { get { return MKPolyline(coordinates: coordinates, count: coordinates.count) } }
    var geodesicPolyline: MKGeodesicPolyline { get { return MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count) } }
    
    func mapRegion() -> MKCoordinateRegion {
        let xCoords = coordinates.map { $0.longitude }
        let yCoords = coordinates.map { $0.latitude }
        let maxX = xCoords.max()!
        let maxY = yCoords.max()!
        let minX = xCoords.min()!
        let minY = yCoords.min()!
        let span = MKCoordinateSpan(latitudeDelta: (maxY - minY) * viewDistanceMultiplier,
                                    longitudeDelta: (maxX - minX) * viewDistanceMultiplier)
        let center = CLLocation(latitude: (maxY + minY) / 2.0, longitude: (maxX + minX) / 2.0).coordinate
        return MKCoordinateRegion(center: center, span: span)
    }
    
    override init() {
        locations = [CLLocation]()
        super.init()
    }
    
    init(locations: [CLLocation]) {
        self.locations = locations
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.locations = aDecoder.decodeObject(forKey: "locations") as? [CLLocation] ?? [CLLocation]()
        self.distance = aDecoder.decodeDouble(forKey: "distance")
        self.placemark = aDecoder.decodeObject(forKey: "placemark") as? CLPlacemark
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(locations, forKey: "locations")
        aCoder.encode(distance, forKey: "distance")
        aCoder.encode(placemark, forKey: "placemark")
    }
    
}
