//
//  Route.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/20/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation
import MapKit

class Route: NSObject, Serializable
{
    let viewDistanceMultiplier: CLLocationDegrees = 1.3
    var latitudes = [Double]()
    var longitudes = [Double]()
    var placemarkName: String = ""
    
    var coordinates: [CLLocationCoordinate2D] {
        get {
            var coords = [CLLocationCoordinate2D]()
            for index in 0..<latitudes.count {
                coords.append(CLLocationCoordinate2D(latitude: latitudes[index], longitude: longitudes[index]))
            }
            return coords
        }
        set {
            latitudes = newValue.map { $0.latitude }
            longitudes = newValue.map { $0.longitude }
        }
    }

    var locations: [CLLocation] {
        get { return coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) } }
        set {
            if locations.count > 0 {
                distance += (newValue.last!.distance(from: locations.last!) * UnitConversions.meterToNauticalMile)
            }
            coordinates = newValue.map { $0.coordinate }
        }
    }

    
    var distance: CLLocationDistance = 0.0
//    var distanceDescription: String {
//        get {
//            let precision: Double = distance < 10.0 ? 100.0 : 10.0
//            return String(describing: (distance * precision).rounded() / precision)
//        }
//    }
    
    var polyline: MKPolyline { get { return MKPolyline(coordinates: coordinates, count: coordinates.count) } }
    var geodesicPolyline: MKGeodesicPolyline { get { return MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count) } }
    
    func mapRegion() -> MKCoordinateRegion {
        let xCoords = coordinates.map{ $0.longitude }
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
        super.init()
    }
    
    init(locations: [CLLocation]) {
        super.init()
        self.locations = locations
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitudes
        case longitudes
        case placemarkName
        case distance
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitudes, forKey: .latitudes)
        try container.encode(longitudes, forKey: .longitudes)
        try container.encode(placemarkName, forKey: .placemarkName)
        try container.encode(distance, forKey: .distance)
    }

}
