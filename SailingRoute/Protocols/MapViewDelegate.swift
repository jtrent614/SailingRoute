//
//  MapViewDelegate.swift
//  SailingRoute
//
//  Created by Jeff Trent on 9/22/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import Foundation
import MapKit
import IVBezierPathRenderer

protocol MapViewDelegate: MKMapViewDelegate { }

extension MapViewDelegate where Self: NSObject {
    
    func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
        guard let annotation = annotation as? Annotation else { return nil }
        
        let buoyId = annotation.buoy.identifier
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: buoyId)
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: buoyId) {
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: buoyId)
        }
        view?.image = UIImage(named: buoyId)
        return view
    }
    
    func renderer(for overlay: MKOverlay, in mapView: MKMapView) -> MKOverlayRenderer {
        // The route between buoys is a geodesic polyline because I don't know how to
        // render two different lines with different settings with the same delegate call
        // so I made them slightly different classes to separate them
        
        if overlay is MKGeodesicPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.black.withAlphaComponent(0.4)
            renderer.lineWidth = 1.0
            return renderer
        } else if overlay is MKPolyline {
            let renderer = IVBezierPathRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue.withAlphaComponent(0.7)
            renderer.lineWidth = 10.0
            renderer.borderColor = UIColor.red
            renderer.borderMultiplier = 0.05
            return renderer
        }
        return MKOverlayRenderer()
    }
    
}


final class MapDelegate: NSObject, MapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return renderer(for: overlay, in: mapView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return annotationView(for: annotation, in: mapView)
    }

}

