//
//  MapViewController.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/19/17.
//  Copyright © 2017 jtrent. All rights reserved.
//
// Use JLTGradientPathRenderer in the future? Rainbow bezier paths

import UIKit
import MapKit
import IVBezierPathRenderer

class MapViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var leftHudView: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var compassHudView: UIView!
    @IBOutlet weak var arrowImage: UIImageView!
    
    @IBOutlet weak var rightHudView: UIView!
    @IBOutlet weak var bearingLabel: UILabel!
    @IBOutlet weak var distanceToMarkLabel: UILabel!
    @IBOutlet weak var nextMarkLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    var delegate = MapDelegate()
    
    var buoyList: BuoyList = BuoyList()
    
    private var mapIsFollowingUser = true
    private var trackingInProgress = false
    
    var currentRoute = TraveledRoute()
    var currentRouteOverlay: MKPolyline?
    var currentRaceRouteOverlay: MKGeodesicPolyline?
    
    var nextMarkLocation: CLLocation { return buoyList.used.first?.location ?? CLLocation(latitude: 90, longitude: 0) }
    
    var latestHeading: CLLocationDirection?
    var latestLocation: CLLocation?
    var latestBearing: CLLocationDirection { return latestLocation?.bearingToLocationRadian(nextMarkLocation).toDouble ?? 0 }
    
    
    @objc func toggleFollow()
    {
        navigationItem.rightBarButtonItem?.title = mapIsFollowingUser ? "Follow" : "Unfollow"
        mapIsFollowingUser = !mapIsFollowingUser
    }
    
    @objc func toggleTracking()
    {
        if !trackingInProgress {
            resetRoute()
            
            mapIsFollowingUser = true
            trackingInProgress = true
        } else {
            trackingInProgress = false
            saveRoute()
        }
        navigationItem.rightBarButtonItem?.title = trackingInProgress ? "Unfollow" : ""
        navigationItem.leftBarButtonItem?.title = trackingInProgress ? "Stop" : "Start"
        
    }
    
    private func saveRoute() {
        guard currentRoute.locations.count > 0 else { return }
            
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
        mapView.delegate = delegate
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

        setupHuds()
    }

    private func setupHuds() {
        let huds = [leftHudView, compassHudView, rightHudView]
        huds.forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderColor = UIColor.black.cgColor
            $0?.layer.borderWidth = 1.0
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self
        rightHudView.addGestureRecognizer(longPressGesture)
    }
    
    private func toggleRaceHud(state: Bool) {
        rightHudView.isHidden = !state
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            goToNextMark()
        }
    }
    
    // MARK: - Racing

    func goToNextMark() {
        guard let currentMark = buoyList.used.first else { return }
        buoyList.moveBuoyToUnused(buoy: currentMark)
        
        updateMap()
    }

    
    private func setRaceRoute() {
        guard Settings.shared.raceMode else { return }
        
        let raceOrder = buoyList.used
        if raceOrder.count > 0 {
            var routeLocations = raceOrder.map { $0.location }
            if latestLocation != nil {
                routeLocations.insert(latestLocation!, at: 0)
            }
            let route = Route(locations: routeLocations)
            nextMarkLabel.text = raceOrder.first!.identifier.uppercased()
            currentRaceRouteOverlay = route.geodesicPolyline
            monitorRegionAtLocation(center: raceOrder.first!.coordinate, identifier: raceOrder.first!.identifier)
            drawRaceRoute()
            updateDistanceToNextMark()
        }
    }
    

    // MARK: - Drawing
    
    private func updateMap() {
        mapView.removeOverlays(mapView.overlays)
        setRaceRoute()
        drawTraveledRoute()
        mapView.drawBuoys(buoyList: buoyList)
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
    
    private func updateDistanceToNextMark() {
        guard Settings.shared.raceMode, let location = latestLocation,
            let mark = buoyList.used.first  else { return }
        
        let distance = mark.location.distance(from: location) * UnitConversions.meterToNauticalMile
        distanceToMarkLabel.text = distance.distanceToString
    }
    
    
    private func updateSpeedDisplay() {
        guard let speed = locationManager.location?.speed else { return }
        speedLabel.text = speed > 0 ? String((speed * UnitConversions.metersPerSecondToKnots * 10).rounded() / 10) : "0.0"
    }
    
    
    private func setMapRegion(location: CLLocation) {
        let span = Settings.shared.mapViewDistance
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, span, span)
        mapView.setRegion(region, animated: true)
    }
    
    
    private func lookupLocationName(location: CLLocation)
    {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { [weak self] (placemarks, error) in
            if error == nil {
                self?.currentRoute.placemarkName = placemarks?[0].name ?? ""
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
    
    private func updateNavBarTitle(relativeBearing: CLLocationDirection)
    {
        //        l= relativeBearing >
        let title = Settings.shared.raceMode ? relativeBearing.degreesToString : ""
        navigationItem.title = title
        
    }

    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let coordinate = buoyList.used.first?.coordinate, latestLocation != nil else { return }
        
        print(newHeading.trueHeading.degreesToString)
        
        leftHudView.isHidden = false
        compassHudView.isHidden = false
        rightHudView.isHidden = !Settings.shared.raceMode

        updateDegreeLabels(coordinate:  coordinate, heading: newHeading)
        
        UIView.animate(withDuration: 0.5) {
            let angle = computeRotation(with: newHeading.trueHeading)
            self.arrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
            self.updateNavBarTitle(relativeBearing: angle.toDegrees)
        }
        
        func computeRotation(with newAngle: CLLocationDirection) -> CLLocationDirection
        {
            let angle = Settings.shared.raceMode ?  0 : self.latestBearing
            return angle - newAngle.toRadians
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let firstBuoy = buoyList.used.first else { return }
        
        if let region = region as? CLCircularRegion {
            if region.identifier == firstBuoy.identifier {
                buoyList.used.removeFirst()
                if buoyList.used.count == 0 {
                    rightHudView.isHidden = true
                } else {
                    nextMarkLabel.text = buoyList.used.first!.identifier
                }
            }
        }
        
        // Point A:  latitude: 27.90366667, longitude: -82.45466667
        // Point B:  latitude: 27.89766667, longitude: -82.44383333
        // Point C:  latitude: 27.8805,  longitude: -82.44466667,
        // Point E:  latitude: 27.88816667, longitude: -82.45283333
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
    
    
    private func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String) {
        guard CLLocationManager.authorizationStatus() == .authorizedAlways,
            CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        
        let regionRadius: CLLocationDistance = 30.0
        let region = CLCircularRegion(center: center, radius: regionRadius, identifier: identifier)
        
        region.notifyOnExit = false
        region.notifyOnEntry = true
        
        locationManager.startMonitoring(for: region)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .otherNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 10.0
        locationManager.headingFilter = kCLHeadingFilterNone
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.requestLocation()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location could not be found")
    }
    
    // MARK: - Compass
    
    private func updateDegreeLabels(coordinate: CLLocationCoordinate2D, heading: CLHeading) {
        bearingLabel.text = latestLocation!.coordinate.direction(to: coordinate).to360Scale.degreesToString
        headingLabel.text = heading.trueHeading.degreesToString
    }
}








