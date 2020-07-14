//
//  Artwork.swift
//  MapAndLocationManager
//
//  Created by Shawn Li on 7/1/20.
//

import Foundation
import MapKit

class ArtworkAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let locationName: String?
    let discipline: String?
    var subtitle: String? {
        return locationName
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String?, locationName: String?, discipline: String?) {
        self.coordinate = coordinate
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        super.init()
    }
    
    init(artwork: ArtWork, point: [Double]) {
        self.coordinate = CLLocationCoordinate2D(latitude: point[0], longitude: point[1])
        self.title = artwork.title
        self.locationName = artwork.location
        self.discipline = artwork.discipline
        super.init()
    }
    
}
