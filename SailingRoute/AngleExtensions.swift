//
//  AngleExtensions.swift
//  SailingRoute
//
//  Created by Jeff Trent on 9/19/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import CoreLocation
import UIKit

public extension CLLocation {
    
    func bearingToLocationRadian(_ destinationLocation: CLLocation) -> CGFloat
    {
        let lat1 = self.coordinate.latitude.toRadians
        let lon1 = self.coordinate.longitude.toRadians
        
        let lat2 = destinationLocation.coordinate.latitude.toRadians
        let lon2 = destinationLocation.coordinate.longitude.toRadians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return CGFloat(radiansBearing)
    }
    
    func bearingToLocationDegrees(destinationLocation: CLLocation) -> CGFloat {
        return bearingToLocationRadian(destinationLocation).toDegrees
    }
}


extension CLLocationCoordinate2D {
    
    func calculateBearing(to coordinate: CLLocationCoordinate2D) -> Double
    {
        let a = sin(coordinate.longitude.toRadians - longitude.toRadians) * cos(coordinate.latitude.toRadians)
        let b = cos(latitude.toRadians) * sin(coordinate.latitude.toRadians) - sin(latitude.toRadians) * cos(coordinate.latitude.toRadians) * cos(coordinate.longitude.toRadians - longitude.toRadians)
        return atan2(a, b)
    }
    
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection
    {
        return self.calculateBearing(to: coordinate).toDegrees
    }
    
}

extension CGFloat {
    
    var toRadians: CGFloat
    {
        return self * .pi / 180
    }
    
    var toDegrees: CGFloat
    {
        return self * 180.0 / .pi
    }
    
    var toDouble: Double
    {
        return Double(self)
    }
}

extension Double {
    
    var toRadians: Double
    {
        return Double(CGFloat(self).toRadians)
    }
    
    var toDegrees: Double
    {
        return Double(CGFloat(self).toDegrees)
    }
}


extension CLLocationDirection {
    
    var to360Scale: CLLocationDirection
    {
        return (self + 360).truncatingRemainder(dividingBy: 360)
    }
    
    var stringify: String
    {
        return String(Int(self)) + "°"
    }
    
}
