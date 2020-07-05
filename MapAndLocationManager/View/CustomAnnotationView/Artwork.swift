//
//  Artwork.swift
//  MapAndLocationManager
//
//  Created by Shawn Li on 7/1/20.
//

import Foundation
import MapKit

class Artwork: NSObject, MKAnnotation {
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
}
