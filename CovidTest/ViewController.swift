//
//  ViewController.swift
//  CovidTest
//
//  Created by shihab on 4/16/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps



class ViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView?
    @IBOutlet weak var mapViewCity: GMSMapView?
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    
    var locationManager: CLLocationManager!
    var defaultLocation = CLLocation(latitude: 23.777176, longitude: 90.399452)
    var defaultLocationCity = CLLocation(latitude: 23.746402, longitude: 90.374574)
    var defaultZoomLevel: Float = 7.0
    var markers: [GMSMarker] = []
    var markersForCity: [GMSMarker] = []
    var locations: [String:LocationInfo] = [:]
    var locationsForCity: [String:LocationInfo] = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("viewWillAppear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .kDidLoadLocationInformation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDataForCity(_:)), name: .kDidLoadLocationInformationForCity, object: nil)
        
        mapView?.delegate = self
        mapViewCity?.delegate = self
        segmentedControl?.setTitle("District", forSegmentAt: 0)
        segmentedControl?.setTitle("Dhaka City", forSegmentAt: 1)
        
        loadInitialData()
        loadInitialDataForCity()
        
        loadLocationManager()
        //print("viewDidLoad")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("viewDidDisappear")
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //print("viewWillDisappear")
    }
    
    
    // MARK: - Helper
    
    @objc private func onDidReceiveData(_ notification: Notification) {
        print("onDidReceiveData...")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadLocationInformation, object: nil)
            self.loadInitialData()
        }
    }
    
    @objc private func onDidReceiveDataForCity(_ notification: Notification) {
        print("onDidReceiveDataForCity...")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadLocationInformationForCity, object: nil)
            self.loadInitialDataForCity()
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: Any) {
        switch segmentedControl?.selectedSegmentIndex
        {
        case 0:
            print("Segment 0")
            self.mapView?.isHidden = false
            self.mapViewCity?.isHidden = true
        case 1:
            print("Segment 1")
            self.mapView?.isHidden = true
            self.mapViewCity?.isHidden = false
        default:
            break
        }
    }
    
    private func loadInitialData() {
        //self.mapView?.camera = GMSCameraPosition.camera(withLatitude: self.defaultLocation.coordinate.latitude, longitude: self.defaultLocation.coordinate.longitude, zoom: self.defaultZoomLevel)
        
        if LocationManager.shared.dictForDistrictLocation.count > 0 {
            do {
                //print("loadInitialData")
                self.locations = LocationManager.shared.dictForDistrictLocation
                self.mapView?.clear()
                for (key, location) in self.locations{
                    let m = GMSMarker()
                    m.position = CLLocationCoordinate2D(latitude: location.latitude ?? self.defaultLocation.coordinate.latitude, longitude: location.longitude ?? self.defaultLocation.coordinate.longitude)
                    m.title = location.name
                    m.snippet = "Current Patients=\(location.cases)"
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
    
    private func loadInitialDataForCity(){
        //self.mapViewCity?.camera = GMSCameraPosition.camera(withLatitude: self.defaultLocationCity.coordinate.latitude, longitude: self.defaultLocationCity.coordinate.longitude, zoom: self.defaultZoomLevel*2)
        
        if LocationManager.shared.dictForCityLocation.count > 0 {
            self.locationsForCity = LocationManager.shared.dictForCityLocation
            do {
                //print("loadInitialData")
                self.mapViewCity?.clear()
                for (key, location) in self.locationsForCity{
                    let m = GMSMarker()
                    m.position = CLLocationCoordinate2D(latitude: location.latitude ?? self.defaultLocationCity.coordinate.latitude, longitude: location.longitude ?? self.defaultLocationCity.coordinate.longitude)
                    m.title = location.name
                    m.snippet = "Current Patients=\(location.cases)"
                    self.markersForCity.append(m)
                }
                //print("loadMarkerPositions")
                for item in self.markersForCity {
                    item.map = self.mapViewCity
                }
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }
    
    private func loadLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            print("#locationServicesEnabled")
            locationManager.startUpdatingLocation()
        }
    }
    
    
} //End of Class


// MARK: - GMSMapViewDelegate
extension ViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
      print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        //print("marker tapped! \(String(describing: marker.title))")
        var tappedLocation: LocationInfo?
        tappedLocation = self.mapView?.isHidden == false ? self.locations[marker.title!] : self.locationsForCity[marker.title!]
        
        print("Location selected: \(tappedLocation?.name)")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let barVC = storyboard.instantiateViewController(withIdentifier: "barChartVC") as! BarChartViewController
        barVC.location = tappedLocation
        self.present(barVC, animated: true, completion: nil)
        return true
    }
}


// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
          print("Location access was restricted.")
        case .denied:
          print("User denied access to location.")
          // Display the map using the default location.
          mapView?.isHidden = false
        case .notDetermined:
          print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
          print("Location status is OK.")
          locationManager.startUpdatingLocation()
          mapView?.isMyLocationEnabled = true
          mapView?.settings.myLocationButton = true
        @unknown default:
          fatalError()
        }
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("#Showing default location")
            self.mapView?.camera = GMSCameraPosition(target: defaultLocation.coordinate, zoom: defaultZoomLevel, bearing: 0, viewingAngle: 0)
            self.mapViewCity?.camera = GMSCameraPosition(target: defaultLocationCity.coordinate, zoom: defaultZoomLevel*2, bearing: 0, viewingAngle: 0)
            return
        }
        
        self.mapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: defaultZoomLevel, bearing: 0, viewingAngle: 0)
        self.mapViewCity?.camera = GMSCameraPosition(target: location.coordinate, zoom: defaultZoomLevel*2, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
        print("#Current Location: Lat=\(location.coordinate.latitude), Long=\(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        locationManager.stopUpdatingLocation()
        print("Error \(error)")
    }
    
}
