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
    var lat = 40.567508
    var long = -105.081794
    var altitude = 0.0
    var accuracy = 0.0
    private var pendingRequestWorkItem: DispatchWorkItem?
    var artWorks: [ArtworkAnnotation] = []
    var artworkVM = ArtworkViewModel()
    
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
        loadAndPlaceArtWorkAnnotations()
//        processPlacemarks(location: nil, address: "Bei Jing")
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
    
    func transferCoordinatesAndAddress(location: CLLocation?, address: String?, transferResultHandler: @escaping (String?,CLLocation?)->()) {
        let geoCoder = CLGeocoder()
        
        if let location = location {
            geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
                let completeAddress = placeMarks?.first?.completeAddress
                transferResultHandler(completeAddress,nil)
            }
        }
        
        if let address = address {
            geoCoder.geocodeAddressString(address) { (placeMarks, error) in
                let location = placeMarks?.first?.location
                transferResultHandler(nil,location)
            }
        }
    }
    
    func processPlacemarks(location: CLLocation?, address: String?) {
        transferCoordinatesAndAddress(location: location, address: address) { (completeAddress, transferedLocation) in
            if let completeAddress = completeAddress {
                guard let coordinate = location?.coordinate else { return }
                self.addAnnotation(coordinate: coordinate, address: completeAddress)
            }
            
            if let transferedCoordinate = transferedLocation?.coordinate {
                guard let address = address else { return }
                self.addAnnotation(coordinate: transferedCoordinate, address: address)
            }
        }
    }
    
    func findMostAccurateLocationAlert(location: CLLocation) {
        let alertController = UIAlertController(title: "Find The Most Accurate Location!", message: "This is the most accurate location. \nlatitude: \(location.coordinate.latitude). \nlongtitude: \(location.coordinate.longitude)", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func loadAndPlaceArtWorkAnnotations() {
        for artwork in artworkVM.artworks {
            let artworkAnnotation = ArtworkAnnotation(artwork: artwork, point: (artwork.artloc?.coordinates)!)
            artWorks.append(artworkAnnotation)
            
        }
//        let validWorks = artworkVM.artworks.compactMap(ArtworkAnnotation.init)
//        artWorks.append(contentsOf: validWorks)
        mapView.addAnnotations(artWorks)
//        mapView.showAnnotations(artWorks, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get the most updated and accurate result then stops the location services.
        guard let lastLocation = locations.last else { return }
        let locationAge = -(lastLocation.timestamp.timeIntervalSinceNow)
        
        if locationAge > 5.0 {
            print("Old Location \(lastLocation)")
            return
        }
        
        if lastLocation.horizontalAccuracy < 0 {
            self.locationManager.stopUpdatingLocation()
            self.locationManager.startUpdatingLocation()
            return
        }
        
        findMostAccurateLocationAlert(location: lastLocation)
    }
    
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
        
        guard let customAnnotation = annotation as? CustomAnnotation else { return nil }
        //TODO: Custom Annotation view as we disussed in class
        var view: MKMarkerAnnotationView
        
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifier) as? MKMarkerAnnotationView {
            dequeueView.annotation = customAnnotation
            view = dequeueView
        } else {
            view = MKMarkerAnnotationView(annotation: customAnnotation, reuseIdentifier: ReuseIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            
            let customCallOutView = CustomAnnotationView()
            
            
            customCallOutView.displayAddressHandler = {
                customCallOutView.titleLabel.text = "Address"
                customCallOutView.displayLabel.text = customAnnotation.subtitle
            }
            
            customCallOutView.displayCoordinateHandler = {
                customCallOutView.titleLabel.text = "Coordinate"
                customCallOutView.displayLabel.text = customAnnotation.title
            }
            view.detailCalloutAccessoryView = customCallOutView
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
        //Cancel/Invalidate the pending item if user type another letter within 3 seconds
        pendingRequestWorkItem?.cancel()
        // Get search text and remove whitespace and newlines
        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespaces), !searchText.isEmpty else { return }
        //Creating a new dispatchWorkItem that will get dispatch later
        let workItem = DispatchWorkItem { [weak self] in
            print(searchText)
            self?.performSearch(using: searchText)
        }
        // Save the new work item
        pendingRequestWorkItem = workItem
        // execute it after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: workItem)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespaces), !searchText.isEmpty else { return }
        performSearch(using: searchText)
    }
    
    func performSearch(using searchText: String) {
        //TODO: Annotation Cluster - self check
        
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
