//
//  MapViewController.swift
//  BD-Sta-Viz
//
//  Created by shihab on 5/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import SideMenu

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView?
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    let myActivityIndicator = UIActivityIndicatorView()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var defaultLocation = CLLocation(latitude: Constants.LocationConstants.defaultLocationLatitude,
                                     longitude: Constants.LocationConstants.defaultLocationLongitude)
    var defaultLocationCity = CLLocation(latitude: Constants.LocationConstants.defaultLocationCityLatitude,
                                         longitude: Constants.LocationConstants.defaultLocationCityLongitude)
    var defaultZoomLevel: Float = 7.0
    var markers: [GMSMarker] = []
    var locations = [DemographyInfo]()
    
    var isDemographicInfo: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Constants.appName
        
        mapView?.delegate = self
        segmentedControl?.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .kDidLoadDemographyDataNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveLocationServiceNotification(_:)), name: .kDidLoadLocationServiceNotification, object: nil)
        showActivityIndicator()
        loadInitialData()
        loadLocationManager()
    }
    
    // MARK: - Helper
    
    @objc private func onDidReceiveData(_ notification: Notification) {
        print("onDidReceiveData...Map")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadDemographyDataNotification, object: nil)
            self.loadInitialData()
            self.removeActivityIndicator()
        }
    }
    
    @objc private func onDidReceiveLocationServiceNotification(_ notification: Notification) {
        print("onDidReceiveLocationServiceNotification...")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadLocationServiceNotification, object: nil)
            self.loadLocationManager()
        }
    }
    
    private func loadInitialData() {
        if LocationManager.shared.dictForDemographicInfo.count > 0 {
            do {
                //print("loadInitialData")
                self.locations = LocationManager.shared.getDemographicData()
                self.mapView?.clear()
                for location in self.locations{
                    let m = GMSMarker()
                    m.position = CLLocationCoordinate2D(latitude: location.latitude ?? self.defaultLocation.coordinate.latitude, longitude: location.longitude ?? self.defaultLocation.coordinate.longitude)
                    m.title = location.name
                    //m.snippet = "Current Patients=\(location.cases)"
                    self.markers.append(m)
                }
                //print("loadMarkerPositions")
                for item in self.markers {
                    item.map = self.mapView
                }
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }
    
    private func loadLocationManager(){
        //self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            print("#locationServicesEnabled")
            locationManager.startUpdatingLocation()
        }
    }
    
    private func showAlertForLocation(){
        let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        return
    }
    
    private func showDefaultLocationOnMap(){
        self.mapView?.camera = GMSCameraPosition(target: defaultLocation.coordinate, zoom: defaultZoomLevel, bearing: 0, viewingAngle: 0)
    }
    
    func showActivityIndicator() {
        myActivityIndicator.style = .medium
        myActivityIndicator.center = self.view.center
        myActivityIndicator.hidesWhenStopped = false
        //myActivityIndicator.frame = self.view.frame
        myActivityIndicator.startAnimating()
        self.mapView?.addSubview(myActivityIndicator)
    }
    
    func removeActivityIndicator() {
        self.myActivityIndicator.stopAnimating()
        self.myActivityIndicator.removeFromSuperview()
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        //print("marker tapped! \(String(describing: marker.title))")
        if let tappedLocation = self.locations.first(where: {$0.name == marker.title}){
            print("Location selected: \(tappedLocation.name)")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let barVC = storyboard.instantiateViewController(withIdentifier: "barChartVC") as! BarChartViewController
            barVC.demoLocation = tappedLocation
            barVC.isDemographicData = true
            self.present(barVC, animated: true, completion: nil)
        }
        return true
    }
}


// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .restricted:
                print("#Location access was restricted.")
            case .denied:
                print("#User denied access to location.")
                showAlertForLocation()
                showDefaultLocationOnMap()
            case .notDetermined:
                print("#Location status not determined.")
                showAlertForLocation()
                showDefaultLocationOnMap()
            case .authorizedAlways: fallthrough
            case .authorizedWhenInUse:
                print("#Location status is OK.")
                //showDefaultLocationOnMap()
                locationManager.startUpdatingLocation()
            @unknown default:
                fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("#Showing default location")
            showDefaultLocationOnMap()
            return
        }
        self.mapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: defaultZoomLevel, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
        print("#Current Location: Lat=\(location.coordinate.latitude), Long=\(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        locationManager.stopUpdatingLocation()
        print("Error \(error)")
    }
}

// MARK: - SideMenuNavigationControllerDelegate
extension MapViewController: SideMenuNavigationControllerDelegate {
    private func setupSideMenuFromStoryboard() {
        // Define the menus
        SideMenuManager.default.rightMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardConstants.sideMenuNavigationControllerID) as? SideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        //SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
    }
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
}
