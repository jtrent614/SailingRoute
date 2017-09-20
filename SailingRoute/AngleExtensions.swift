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
    
    func to360Scale() -> CLLocationDirection
    {
        guard self > 180.0 else { return self }
        return 360.0 - self
    }
    
}





// returns degrees, plus some magic trig that I have no idea about
//    private func getBearing(toPoint point: CLLocationCoordinate2D) -> CLLocationDirection
//    {
//        let lat1 = degreesToRadians(degrees: (currentLocation?.coordinate.latitude)!)
//        let lon1 = degreesToRadians(degrees: (currentLocation?.coordinate.longitude)!)
//
//        let lat2 = degreesToRadians(degrees: point.latitude);
//        let lon2 = degreesToRadians(degrees: point.longitude);
//
//        let dLon = lon2 - lon1;
//
//        let y = sin(dLon) * cos(lat2);
//        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
//        let degreesBearing = radiansToDegrees(radians: atan2(y, x))
//
//        return (degreesBearing + 360).truncatingRemainder(dividingBy: 360)  // equivalent to modulo for Doubles. % only works on Ints
//    }

//    private func getBearing(to point: CLLocationCoordinate2D) -> CLLocationDirection
//    {
//        let lat1 = currentLocation?.coordinate.latitude.toRadians()
//        let lon1 = currentLocation?.coordinate.longitude.toRadians()
//
//        let lat2 = point.latitude.toRadians()
//        let lon2 = point.longitude.toRadians()
//
//        let dLon = lon2 - lon1;
//
//        let y = sin(dLon) * cos(lat2);
//        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
//        let degreesBearing = atan2(y, x)
//
//        return (degreesBearing + 360).truncatingRemainder(dividingBy: 360)  // equivalent to modulo for Doubles. % only works on Ints
//    }
//    private func changeTo360Scale(degrees: CLLocationDirection) -> CLLocationDirection {
//        guard degrees > 180.0 else { return degrees }
//        return 360.0 - degrees
//    }
//    private func degreesToRadians(degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
//    private func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / Double.pi }
