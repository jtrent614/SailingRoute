//
//  MapViewController.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/19/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

// https://github.com/zntfdr/Compass/blob/master/compass/UserDefauts%2BExtensions.swift  compass
// Use JLTGradientPathRenderer in the future? Rainbow bezier paths


import UIKit
import MapKit
import IVBezierPathRenderer

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate
{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedStackView: UIStackView!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var nextMarkLabel: UILabel!
    @IBOutlet weak var nextMarkStackView: UIStackView!
    
    private let locationManager = CLLocationManager()
    
    var buoyList: BuoyList = BuoyList()
    
    private var mapIsFollowingUser = true
    private var trackingInProgress = false
    
    var currentRoute = TraveledRoute()
    var currentRouteOverlay: MKPolyline?
    var currentRaceRouteOverlay: MKGeodesicPolyline?
    
    var nextMarkLocation: CLLocation { return buoyList.raceOrder.first?.location ?? CLLocation(latitude: 90, longitude: 0) }
    
    var latestHeading: CLLocationDirection?
    var latestLocation: CLLocation?
    var latestBearing: CLLocationDirection { return latestLocation?.bearingToLocationRadian(nextMarkLocation).toDouble ?? 0 }

    
    
    // MARK: - Compass
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let coordinate = buoyList.raceOrder.first?.coordinate, latestLocation != nil,
            Settings.shared.raceMode else { return }
        
        let formattedHeading = Int(latestLocation!.coordinate.direction(to: coordinate))
        
        headingLabel.isHidden = false
        headingLabel.text = String(formattedHeading) + "°"
        
        func computeNewAngle(with newAngle: CGFloat) -> CGFloat
        {
            return CGFloat(self.latestBearing) - newAngle.toRadians
        }
        
        let angle = computeNewAngle(with: CGFloat(newHeading.trueHeading))
        arrowImage.transform = CGAffineTransform(rotationAngle: angle)
        
    }
    
    
    private func angleBetween(bearing: CLLocationDirection, heading: CLLocationDirection) -> CLLocationDirection
    {
        return abs(bearing - heading).to360Scale()
    }
    
    func toggleFollow()
    {
        navigationItem.rightBarButtonItem?.title = mapIsFollowingUser ? "Follow" : "Unfollow"
        mapIsFollowingUser = !mapIsFollowingUser
    }
    
    func toggleTracking()
    {
        if !trackingInProgress {
            resetRoute()
            nextMarkStackView.isHidden = Settings.shared.raceMode ? false : true
            
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
            speedStackView.isHidden = false
            arrowImage.isHidden = false
            
            mapIsFollowingUser = true
            trackingInProgress = true
        } else {
            speedStackView.isHidden = true
            nextMarkStackView.isHidden = true
            arrowImage.isHidden = true
            
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
            
//            mapIsFollowingUser = false
            trackingInProgress = false
            saveRoute()

        }
        navigationItem.rightBarButtonItem?.title = trackingInProgress ? "Unfollow" : ""
        navigationItem.leftBarButtonItem?.title = trackingInProgress ? "Stop" : "Start"
        
    }

    
    private func saveRoute() {
        UserDefaults.standard.saveRoute(currentRoute)
    }
    
    private func resetRoute() {
        currentRoute = TraveledRoute()
        if currentRouteOverlay != nil {
            mapView.remove(currentRouteOverlay!)
        }
    }
    

    
    // MARK: - VC Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocationManager()
        mapView.delegate = self

        updateMap()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startButton = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(toggleTracking))
        navigationItem.setLeftBarButton(startButton, animated: true)
        let followButton = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(toggleFollow))
        navigationItem.setRightBarButton(followButton, animated: true)
        
        let tabBarController = self.tabBarController as! SailingRouteTabBarController
        buoyList = tabBarController.buoyList
        
        
    }

    
    // MARK: - Racing
    
    
    private func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String) {
        guard CLLocationManager.authorizationStatus() == .authorizedAlways,
            CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        
        let regionRadius: CLLocationDistance = 30.0
        let region = CLCircularRegion(center: center, radius: regionRadius, identifier: identifier)
        
        region.notifyOnExit = false
        region.notifyOnEntry = true
        
        locationManager.startMonitoring(for: region)
    }

    
    private func setRaceRoute() {
        guard Settings.shared.raceMode else { return }
        
        let raceOrder = buoyList.raceOrder
        if raceOrder.count > 0 {
            var routeLocations = raceOrder.map { $0.location }
            if latestLocation != nil {
                routeLocations.insert(latestLocation!, at: 0)
            }
            let route = Route(locations: routeLocations)
            print(route.coordinates)
            nextMarkLabel.text = raceOrder.first!.identifier.uppercased()
            currentRaceRouteOverlay = route.geodesicPolyline
            monitorRegionAtLocation(center: raceOrder.first!.coordinate, identifier: raceOrder.first!.identifier)
            drawRaceRoute()
        }
    }
    

    // MARK: - Drawing
    
    private func updateMap() {
        mapView.removeOverlays(mapView.overlays)
        setRaceRoute()
        drawTraveledRoute()
        drawAnnotations()
        updateNavBarDistance()
    }
    
    private func updateNavBarDistance()
    {
        navigationItem.title = "Distance: \(currentRoute.distanceDescription) nm"
    }
    
    private func drawRaceRoute()
    {
        if currentRaceRouteOverlay != nil {
            mapView.add(currentRaceRouteOverlay!)
        }
    }
    
    private func drawTraveledRoute()
    {
        if currentRouteOverlay != nil {
            mapView.add(currentRouteOverlay!)
        }
    }
    
    private func drawAnnotations()
    {
        mapView.removeAnnotations(mapView.annotations)
        let buoys = Settings.shared.showAllBuoys ? buoyList.buoys :
            (Settings.shared.raceMode ? buoyList.raceOrder : buoyList.used)
        
        for buoy in buoys {
            mapView.addAnnotation(buoy)
        }
    }
    
    
    
    // MARK: - Map View


    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Buoy else {return nil}
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier)
       
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) {
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
        }
        view?.image = UIImage(named: annotation.identifier)
        return view
    }
    
    
    
    
    
    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let firstBuoy = buoyList.raceOrder.first else { return }

        if let region = region as? CLCircularRegion {
            if region.identifier == firstBuoy.identifier {
                buoyList.raceOrder.removeFirst()
                if buoyList.raceOrder.count == 0 {
                    nextMarkStackView.isHidden = true
                } else {
                    nextMarkLabel.text = buoyList.raceOrder.first!.identifier
                }
            }
        }
        
        // Point A:  latitude: 27.90366667, longitude: -82.45466667
        // Point B:  latitude: 27.89766667, longitude: -82.44383333
        // Point C:  latitude: 27.8805,  longitude: -82.44466667,
        // Point E:  latitude: 27.88816667, longitude: -82.45283333
    }
    
    private func updateSpeedDisplay() {
        guard let speed = locationManager.location?.speed else { return }
        speedLabel.text = speed > 0 ? String((speed * UnitConversions.metersPerSecondToKnots * 10).rounded() / 10) : "0.0"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        latestLocation = userLocation
        
        updateSpeedDisplay()
    
        if mapIsFollowingUser {
            setMapRegion(location: userLocation)
        }
        
        if trackingInProgress {
            addNewRouteLocations(locations: locations)
        }
    }
    
    private func setMapRegion(location: CLLocation) {
        let viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                            Settings.shared.mapViewDistance,
                                                            Settings.shared.mapViewDistance)
        mapView.setRegion(viewRegion, animated: true)
    }
    
    
    
    private func lookupLocationName(location: CLLocation)
    {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { [weak self] (placemarks, error) in
            if error == nil {
                self?.currentRoute.placemark = placemarks?[0]
            }
        })
    }
    
    private func addNewRouteLocations(locations: [CLLocation])
    {
        guard locations.count != 0 else { return }
        
        currentRoute.endDate = Date()
        if currentRoute.locations.count == 0 {
            lookupLocationName(location: locations.first!)
        }
        
        for location in locations {
            currentRoute.locations.append(location)
            currentRouteOverlay = currentRoute.polyline
            updateMap()
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .otherNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 10.0
        
        locationManager.headingFilter = kCLHeadingFilterNone
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.requestLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location could not be found")
    }
    
}







