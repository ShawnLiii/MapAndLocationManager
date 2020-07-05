//
//  ViewController.swift
//  MapAndLocationManager
//
//  Created by Shawn Li on 6/29/20.
//

import UIKit
import CoreLocation
import MapKit

private let ReuseIdentifier = "annotation"

class ViewController: UIViewController {

    let locationManager = CLLocationManager()
    var items = [MKMapItem]()
    var lat = 40.567508
    var long = -105.081794
    var altitude = 0.0
    var accuracy = 0.0
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupGesture()
        setupSearchBar()
    }

    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    func setupGesture() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let locationInView = sender.location(in: mapView)
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

            processPlacemarks(location: location, address: nil)
        }
    }

    func centerTo(location: CLLocation, regionRadius: CLLocationDistance) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        self.mapView.setRegion(region, animated: true)
    }
    
    func setCamera(positionFor location: CLLocation, regionRadius: CLLocationDistance) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        let cameraBoundry = MKMapView.CameraBoundary(coordinateRegion: region)
        self.mapView.setCameraBoundary(cameraBoundry, animated: true)
        
        let zoom = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 10050000)
        self.mapView.setCameraZoomRange(zoom, animated: true)
        
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, address: String) {
        let annotation = CustomAnnotation(coordinate: coordinate, title: "\(coordinate.latitude), \(coordinate.longitude)", subtitle: address)
        self.mapView.addAnnotation(annotation)
    }
    
    func processPlacemarks(location: CLLocation?, address: String?) {
        let geoCoder = CLGeocoder()
        guard let location = location else { return }
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placeMarks, error) in
            guard let completeAddress = placeMarks?.first?.completeAddress, error == nil else { return }
            self?.addAnnotation(coordinate: location.coordinate, address: completeAddress)
        }
        //TODO: Pass an complete string address and try to fet the co-ordinates using CLGeocoder class. This process is called geo-coding.
        guard let address = address else { return }
        geoCoder.geocodeAddressString(address) { [weak self] (placeMarks, error) in
            guard let location = placeMarks?.first?.location else { return }
            self?.addAnnotation(coordinate: location.coordinate, address: address)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get the most updated and accurate result then stops the location services.
        guard let lastLocation = locations.last else { return }
        lat = lastLocation.coordinate.latitude
        long = lastLocation.coordinate.longitude
        altitude = lastLocation.altitude
        accuracy = lastLocation.horizontalAccuracy
    }
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//
//    }
//
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Can't get location")
    }
}

//MARK: - MapKit Implementation
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let location = userLocation.location else { return }
        self.centerTo(location: location, regionRadius: 50000)
//        self.setCamera(positionFor: location, regionRadius: 2000000)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? CustomAnnotation else { return nil }
        //TODO: Custom Annotation view as we disussed in class
        var view: MKMarkerAnnotationView
        
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifier) as? MKMarkerAnnotationView {
            dequeueView.annotation = annotation
            view = dequeueView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: ReuseIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
            leftIconView.image = UIImage(named: "dog")
            view.leftCalloutAccessoryView = leftIconView
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? CustomAnnotation else { return }
        let name = annotation.subtitle
        let coordinate = annotation.title
        
        let alertController = UIAlertController(title: name, message: coordinate, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    
}

//MARK: - Search Bar Implementation
extension ViewController: UISearchBarDelegate {

    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //TODO: Search Part
        //Cancel the pending item
        pendingRequestWorkItem?.cancel()
        // Get search text and remove whitespace and newlines
        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespaces), !searchText.isEmpty else { return }
        // Wait for user to stop typing for 3 seconds else invalidate - dispatchWorkitem, timer
        let workItem = DispatchWorkItem { [weak self] in
            print(searchText)
            self?.performSearch(using: searchText)
        }
        // Save the new work item and execute it after 3 seconds
        pendingRequestWorkItem = workItem
        // Then make a request else invalidate
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: workItem)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespaces), !searchText.isEmpty else { return }
        performSearch(using: searchText)
    }
    
    func performSearch(using searchText: String) {
        items.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = self.mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response,
                  error == nil,
                  !response.mapItems.isEmpty else { return }
            for item in response.mapItems {
                let coordinate = item.placemark.coordinate
                let address = item.placemark.completeAddress
                self.addAnnotation(coordinate: coordinate, address: address ?? "Default Address")
            }
        }
    }
}
